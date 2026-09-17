classdef (Sealed) J2KLRA < nfx.TRE
    %J2KLRA - Inspect original NPJE or EPJE layer information
    %   IMAGE.J2KLRA returns an editable copy of the record derived by
    %   OpenJPEG compression. ORIG is 0 for NPJE or 2 for EPJE. LAYER_ID
    %   and BITRATE are matching row vectors in encoded layer order.
    %   This inspection type supports NFX's original-encoding layout.
    %   The image regenerates its stored record when it is compressed;
    %   a decoded copy cannot replace that derived attachment with +.
    %
    %   See also ImageSegment.J2KLRA, JPEG2000, TRERecord

    properties (Constant)
        cetag = 'J2KLRA'
    end
    properties
        orig {mustBeMetadata(orig,0,2,1)} = NaN
        nlevels_o {mustBeMetadata(nlevels_o,0,32,1)} = NaN
        nbands_o {mustBeMetadata(nbands_o,1,99999,1)} = NaN
        layer_id {mustBeMetadataArray(layer_id,0,999,1)} = []
        bitrate {mustBeMetadataArray(bitrate,0,37,0)} = []
    end
    properties (Dependent, SetAccess = private)
        nlayers_o
    end
    methods
        function value = get.nlayers_o(obj) %#codegen
            %get.nlayers_o - Count encoded original quality layers
            value = numel(obj.layer_id);
        end

        function report = validate(obj) %#codegen
            %validate - Check the supported original-encoding field layout
            report = newReport('STDI-0002 Appendix Y original J2KLRA');
            valid = any(obj.orig == [0 2]) && ...
                all(isfinite([obj.nlevels_o obj.nbands_o])) && ...
                isrow(obj.layer_id) && isrow(obj.bitrate) && ...
                obj.nlayers_o >= 1 && obj.nlayers_o <= 999 && ...
                numel(obj.bitrate) == obj.nlayers_o && ...
                all(isfinite([obj.layer_id obj.bitrate])) && ...
                isequal(obj.layer_id, 0:obj.nlayers_o - 1);
            report = addIssue(report, ~valid, 'LayerDefinition', ...
                'orig/nlevels_o/nbands_o/layer_id/bitrate', ...
                'Supply original NPJE/EPJE metadata and ordered layers.', ...
                'STDI-0002-1 Appendix Y J2KLRA');
        end

        function value = payload(obj) %#codegen
            %payload - Re-encode an independently decoded original record
            requireValid(obj.validate());
            value = [decimalField(obj.orig, 1, 0, false) ...
                decimalField(obj.nlevels_o, 2, 0, false) ...
                decimalField(obj.nbands_o, 5, 0, false) ...
                decimalField(obj.nlayers_o, 3, 0, false)];
            for k = 1:obj.nlayers_o
                value = [value decimalField(obj.layer_id(k), 3, 0, false) ...
                    decimalField(obj.bitrate(k), 9, 6, false)]; %#ok<AGROW>
            end
        end
    end
    methods (Static)
        function [obj, ok, status] = deserialize(data) %#codegen
            %deserialize - Decode original NPJE or EPJE layer metadata
            %   [OBJ, OK, STATUS] = nfx.J2KLRA.deserialize(PAYLOAD)
            %   returns an independent scalar object. Failure returns the
            %   default scalar and OK=false, including unsupported layouts.
            %
            %   See also ImageSegment.J2KLRA, J2KLRA.payload
            arguments
                data
            end
            obj = nfx.J2KLRA();
            reader = nfx.internal.TREReader(data);
            [orig, reader] = reader.number(1, 0, 2, true);
            [levels, reader] = reader.number(2, 0, 32, true);
            [bands, reader] = reader.number(5, 1, 99999, true);
            [count, reader] = reader.count(3, 12, 999);
            ids = zeros(1, count);
            rates = zeros(1, count);
            for k = 1:count
                [ids(k), reader] = reader.number(3, 0, 999, true);
                [rates(k), reader] = reader.number(9, 0, 37);
            end
            if reader.ok
                obj.orig = orig;
                obj.nlevels_o = levels;
                obj.nbands_o = bands;
                obj.layer_id = ids;
                obj.bitrate = rates;
            end
            [obj, ok, status] = finishTREDecode(obj, reader, nfx.J2KLRA());
        end
    end
end
