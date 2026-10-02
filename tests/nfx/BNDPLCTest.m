classdef BNDPLCTest < NfxTest
    %BNDPLCTest - Appendix P Table P-9a encodings and physical boundaries
    properties (TestParameter)
        format = {'%+015.1f', '%015.6f', '%015.8E'}
        dimensions = {2, 3}
        owner = {'file', 'image', 'wrapper'}
        badCount = {'+01', '1E0', ' 01'}
        badPoints = {'+003', '3.00', '3E00', '   3'}
        badDimensions = {'1', '4', ' '}
        badCoordinate = {'            NaN', '           +Inf', ...
            '1.00000000E+999', '1.00000000E-999', ...
            '+1.00000000E+14', '               ', '0000000000001i0'}
    end
    methods (Test)
        function alternateCoordinateFormats(t, format, dimensions)
            [bytes, rings] = independentPayload(format, dimensions);
            [polygon, ok, status] = nfx.BNDPLC.deserialize(bytes);
            t.assertTrue(ok, status.message);
            t.verifyEqual(polygon.rings, rings);
            t.verifyEqual(polygon.num_rings, 1);
            t.verifyEqual(polygon.num_pts, 3);
            t.verifyEqual(polygon.dimensions, dimensions);
            [again, ok, status] = ...
                nfx.BNDPLC.deserialize(polygon.payload());
            t.assertTrue(ok, status.message);
            t.verifyEqual(again.rings, rings);
        end

        function originalBytesSurviveFileRoundTrip(t, owner)
            [payload, rings] = independentPayload('%+015.1f', 3);
            polygon = nfx.BNDPLC(rings);
            [base, image] = fixtureFile();
            file = nfx.File(header=base.header) + nfx.GEOPSB();
            switch owner
                case 'file'
                    file = file + polygon + image;
                case 'image'
                    file = file + (image + polygon);
                case 'wrapper'
                    wrapper = nfx.CONTXA( ...
                        context_type='IS', index_list='1') + polygon;
                    file = file + image + wrapper;
            end
            source = fullfile(t.folder, 'polygon.ntf');
            file.write(source);
            bytes = readBytes(source);
            at = strfind(char(bytes), 'BNDPLC00143');
            t.assertNumElements(at, 1);
            bytes(at + (11:153)) = payload;
            [copy, ok, status] = nfx.internal.FileReader.readBytes(bytes);
            t.assertTrue(ok, status.message);
            t.verifyTrue(status.metadata_complete);
            switch owner
                case 'file', attached = copy;
                case 'image', attached = copy.images(1);
                case 'wrapper', attached = copy.CONTXA();
            end
            [decoded, ok, status] = attached.BNDPLC();
            t.assertTrue(ok, status.message);
            t.verifyEqual(decoded.rings, rings);
            records = attached.tre_records;
            record = records(strcmp({records.tag}, 'BNDPLC'));
            t.verifyEqual(record.payload, payload);
            decoded.rings.height(1) = 25;
            t.verifyEqual(attached.BNDPLC().rings.height, rings.height);
            output = fullfile(t.folder, 'copy.ntf');
            copy.write(output);
            t.verifyEqual(readBytes(output), bytes);
        end

        function ringCountsRequireDigits(t, badCount)
            bytes = independentPayload('%015.6f', 2);
            bytes(1:3) = uint8(badCount);
            verifyRejected(t, bytes);
        end

        function pointCountsRequireDigits(t, badPoints)
            bytes = independentPayload('%015.6f', 2);
            bytes(5:8) = uint8(badPoints);
            verifyRejected(t, bytes);
        end

        function dimensionsRequireTwoOrThree(t, badDimensions)
            bytes = independentPayload('%015.6f', 2);
            bytes(4) = uint8(badDimensions);
            verifyRejected(t, bytes);
        end

        function coordinatesRequireFiniteNumbers(t, badCoordinate)
            bytes = independentPayload('%015.6f', 2);
            t.assertNumElements(badCoordinate, 15);
            bytes(9:23) = uint8(badCoordinate);
            verifyRejected(t, bytes);
        end

        function lengthsAndRequiredRingCounts(t)
            bytes = independentPayload('%015.6f', 2);
            verifyRejected(t, bytes(1:end - 1));
            verifyRejected(t, [bytes uint8('0')]);
            verifyRejected(t, uint8('0002'));
            verifyRejected(t, uint8('9992'));
            verifyRejected(t, uint8('00129999'));
            bytes(5:8) = uint8('0002');
            verifyRejected(t, bytes(1:68));
        end

        function unsignedPositiveRange(t)
            bytes = independentPayload('%015.6f', 2);
            bytes(9:23) = uint8('01.00000000E+14');
            [polygon, ok, status] = nfx.BNDPLC.deserialize(bytes);
            t.assertTrue(ok, status.message);
            t.verifyEqual(polygon.rings.lon(1), 1e14);
        end

        function vertexAndPayloadLimits(t, dimensions)
            count = min(3332, floor((99985 - 8) / (15 * dimensions)));
            ring = struct('lon', double(1:count), ...
                'lat', zeros(1, count), 'height', zeros(1, 0));
            if dimensions == 3, ring.height = zeros(1, count); end
            polygon = nfx.BNDPLC(ring);
            bytes = polygon.payload();
            t.verifyEqual(numel(bytes), 8 + 15 * dimensions * count);
            [copy, ok, status] = nfx.BNDPLC.deserialize(bytes);
            t.assertTrue(ok, status.message);
            t.verifyEqual(copy.num_pts, count);
            % Structural limits are separate from file-level topology.
            polygon.rings(2) = ring;
            t.verifyFalse(polygon.validate().valid);
        end

        function maximumRingCount(t)
            [~, ring] = independentPayload('%015.6f', 2);
            polygon = nfx.BNDPLC(repmat(ring, 1, 999));
            bytes = polygon.payload();
            t.verifyEqual(numel(bytes), 4 + 999 * 94);
            [copy, ok, status] = nfx.BNDPLC.deserialize(bytes);
            t.assertTrue(ok, status.message);
            t.verifyEqual(copy.num_rings, 999);
            t.verifyError(@() nfx.BNDPLC(repmat(ring, 1, 1000)), ...
                'nfx:PolygonRings');
        end
    end
end

function [bytes, ring] = independentPayload(format, dimensions)
    % Table P-9a: 3-byte ring count, dimension, 4-byte vertex count,
    % then longitude/latitude/optional height, each 15 bytes per vertex.
    ring = struct('lon', [0 0 1], 'lat', [0 1 0], ...
        'height', zeros(1, 0));
    fields = [ring.lon; ring.lat];
    prefix = '00120003';
    if dimensions == 3
        ring.height = [-1 0 2];
        fields(3, :) = ring.height;
        prefix = '00130003';
    end
    bytes = uint8([prefix sprintf(format, fields)]);
end

function verifyRejected(t, bytes)
    [polygon, ok, status] = nfx.BNDPLC.deserialize(bytes);
    t.verifyFalse(ok);
    t.verifyNotEqual(status.code, 'OK');
    t.verifyEmpty(polygon.rings);
end
