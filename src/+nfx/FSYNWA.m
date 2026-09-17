classdef (Sealed) FSYNWA < nfx.MetadataWrapper
    %FSYNWA - Associate ordered TRE snapshots with consecutive image frames
    %   OBJ = FSYNWA(start_frame_number=FIRST,end_frame_number=LAST) + TRE
    %   captures TRE for the inclusive frame range. LAST=0 extends through
    %   the final frame of the owning image segment. Frame indices are
    %   relative to that segment, starting at one.
    %
    %   See also FASYWA, CONTXA, MTIMSA

    properties (Constant)
        cetag = 'FSYNWA'
    end
    properties
        start_frame_number {mustBeMetadata(start_frame_number,1,999999999,1)} = 1
        end_frame_number {mustBeMetadata(end_frame_number,0,999999999,1)} = 0
    end
    methods (Static)
        function [obj, ok, status] = deserialize(data) %#codegen
            %deserialize - Decode an independent editable FSYNWA value
            %   [OBJ, OK, STATUS] = nfx.FSYNWA.deserialize(PAYLOAD)
            %   reads a uint8 row without its tag/length envelope. Failure
            %   returns a default scalar OBJ and a diagnostic STATUS.
            %   Encoded values retain their stored precision.
            %
            %   See also FSYNWA, FSYNWA.payload
            arguments
                data
            end
            obj = nfx.FSYNWA();
            reader = nfx.internal.TREReader(data);
            [value, reader] = reader.number( ...
                9, 1, 999999999, 1, false);
            if reader.ok
                obj.start_frame_number = value;
            end
            [value, reader] = reader.number( ...
                9, 0, 999999999, 1, false);
            if reader.ok
                obj.end_frame_number = value;
            end
            [records, reader] = readWrappedRecords(reader);
            if reader.ok
                [valid, childStatus] = validateWrappedRecords(records);
                if valid
                    obj = obj.restoreSnapshots(records);
                else
                    reader = reader.fail(childStatus.code, childStatus.message);
                end
            end
            [obj, ok, status] = finishTREDecode( ...
                obj, reader, nfx.FSYNWA());
        end
    end
    methods
        function obj = FSYNWA(options) %#codegen
            %FSYNWA - Construct an editable frame range
            arguments
                options.?nfx.FSYNWA
            end
            if isfield(options,'start_frame_number'), obj.start_frame_number = options.start_frame_number; end
            if isfield(options,'end_frame_number'), obj.end_frame_number = options.end_frame_number; end
        end
        function report = validate(obj) %#codegen
            %VALIDATE - Check range order, wrapped records and complete length
            report = newReport('STDI-0002 Appendix AF FSYNWA');
            report = addIssue(report,any(isnan([obj.start_frame_number obj.end_frame_number])) || ...
                (obj.end_frame_number ~= 0 && obj.end_frame_number < obj.start_frame_number), ...
                'FrameRange','start_frame_number/end_frame_number', ...
                'Supply an ordered inclusive range, or end zero for the remaining frames.', ...
                'STDI-0002-1 Appendix AF, AF5.10 and Table AF-10');
            report = wrapperReport(obj,report,18);
        end
    end
    methods (Access = protected)
        function value = wrapperPrefix(obj) %#codegen
            %wrapperPrefix - Encode the relative frame limits
            value = [decimalField(obj.start_frame_number,9,0,false) decimalField(obj.end_frame_number,9,0,false)];
        end
    end
end
