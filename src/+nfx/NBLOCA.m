classdef (Sealed) NBLOCA < nfx.TRE
    %NBLOCA - Relative byte offsets of image blocks or frames
    %   OBJ = NBLOCA(frame_1_offset=HEADER_BYTES, offsets=OFFSETS) stores
    %   the first frame offset from the image subheader start and subsequent
    %   offsets from the previous frame. Counts derive from OFFSETS.
    %   This metadata does not add an image-compression codec.
    %
    %   See also TRE, ImageSegment

    properties (Constant)
        cetag = 'NBLOCA'
    end
    properties
        frame_1_offset {mustBeMetadata(frame_1_offset, 439, 999999, 1)} = NaN
        offsets {mustBeMetadataArray(offsets, 1, 4294967295, 1)} = zeros(1, 0)
    end
    properties (Dependent, SetAccess = private)
        number_of_frames
    end
    methods
        function obj = NBLOCA(options) %#codegen
            arguments
                options.?nfx.NBLOCA
            end
            if isfield(options, 'frame_1_offset')
                obj.frame_1_offset = options.frame_1_offset;
            end
            if isfield(options, 'offsets')
                obj.offsets = options.offsets;
            end
        end
        function count = get.number_of_frames(obj) %#codegen
            count = 1 + numel(obj.offsets);
        end
        function report = validate(obj) %#codegen
            reference = 'STDI-0002-1 Appendix I, Table I-1 (2021-10)';
            report = newReport(reference);
            report = addIssue(report, isnan(obj.frame_1_offset), ...
                'Required', 'frame_1_offset', ...
                'Supply the image subheader byte length.', reference);
            report = addIssue(report, ...
                ~(isrow(obj.offsets) || isempty(obj.offsets)) || ...
                any(isnan(obj.offsets(:))) || obj.number_of_frames > 24996, ...
                'Offsets', 'offsets', ...
                'Supply at most 24995 finite subsequent frame offsets.', ...
                reference);
        end
        function data = payload(obj) %#codegen
            requireValid(obj.validate());
            values = [obj.frame_1_offset obj.number_of_frames obj.offsets];
            data = zeros(1, 4 * numel(values), 'uint8');
            for k = 1:numel(values)
                for j = 1:4
                    data(4 * (k - 1) + j) = uint8(bitand( ...
                        bitshift(uint32(values(k)), -8 * (4 - j)), 255));
                end
            end
        end
    end
    methods (Static)
        function [obj, ok, status] = deserialize(data) %#codegen
            %deserialize - Decode an independent block-offset table
            %   [OBJ, OK, STATUS] = deserialize(DATA) returns a default
            %   scalar object and diagnostic on malformed input.
            obj = nfx.NBLOCA();
            reader = nfx.internal.TREReader(data, 99988);
            [first, reader] = reader.unsigned(4);
            [count, reader] = reader.unsigned(4);
            if reader.ok
                if first < 439 || first > 999999 || count < 1 || count > 24996
                    reader = reader.fail('InvalidNumber', ...
                        'Invalid header offset or frame count.');
                else
                    [offsets, reader] = reader.unsigned(4, double(count) - 1);
                    if reader.ok && any(offsets < 1)
                        reader = reader.fail('InvalidNumber', ...
                            'Frame offsets must be positive.');
                    end
                    if reader.ok
                        obj.frame_1_offset = double(first);
                        obj.offsets = double(offsets);
                    end
                end
            end
            [obj, ok, status] = finishTREDecode(obj, reader, nfx.NBLOCA());
        end
    end
end
