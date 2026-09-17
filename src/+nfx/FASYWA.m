classdef (Sealed) FASYWA < nfx.MetadataWrapper
    %FASYWA - Associate asynchronous metadata with an exact time interval
    %   OBJ = FASYWA(start_timestamp=START,end_timestamp=END) + TRE snapshots
    %   a supported asynchronous TRE. END is exclusive; 24 dashes mean the
    %   end of the image segment's temporal block. Timestamps take precedence
    %   over those in wrapped records. Their original precision is preserved.
    %
    %   ILLUMB and FREESA are supported asynchronous contents. Metadata tied
    %   directly to image frames belongs in a synchronous/context wrapper.
    %
    %   See also FSYNWA, CONTXA, ILLUMB

    properties (Constant)
        cetag = 'FASYWA'
    end
    properties
        start_timestamp {mustBeAscii(start_timestamp,24)} = ''
        end_timestamp {mustBeAscii(end_timestamp,24)} = ''
    end
    methods (Static)
        function [obj, ok, status] = deserialize(data) %#codegen
            %deserialize - Decode an independent editable FASYWA value
            %   [OBJ, OK, STATUS] = nfx.FASYWA.deserialize(PAYLOAD)
            %   reads a uint8 row without its tag/length envelope. Failure
            %   returns a default scalar OBJ and a diagnostic STATUS.
            %   Encoded values retain their stored precision.
            %
            %   See also FASYWA, FASYWA.payload
            arguments
                data
            end
            obj = nfx.FASYWA();
            reader = nfx.internal.TREReader(data);
            [value, reader] = reader.text(24, true, false);
            if reader.ok
                obj.start_timestamp = value;
            end
            [value, reader] = reader.text(24, true, false);
            if reader.ok
                obj.end_timestamp = value;
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
                obj, reader, nfx.FASYWA());
        end
    end
    methods
        function obj = FASYWA(options) %#codegen
            %FASYWA - Construct an editable asynchronous time association
            arguments
                options.?nfx.FASYWA
            end
            if isfield(options,'start_timestamp'), obj.start_timestamp = options.start_timestamp; end
            if isfield(options,'end_timestamp'), obj.end_timestamp = options.end_timestamp; end
        end
        function report = validate(obj) %#codegen
            %VALIDATE - Check timestamp syntax, order, child scopes and length
            report = newReport('STDI-0002 Appendix AF FASYWA');
            reference = 'STDI-0002-1 Appendix AF, AF5.9 and Table AF-9';
            startValid = validMieTimestamp(obj.start_timestamp);
            endValid = validMieTimestamp(obj.end_timestamp);
            openEnd = strcmp(obj.end_timestamp,repmat('-',1,24));
            report = addIssue(report,~startValid || ~(endValid || openEnd), ...
                'Timestamp','start_timestamp/end_timestamp', ...
                'Supply valid UTC timestamps, or 24 end dashes for the remaining temporal block.',reference);
            if startValid && endValid
                report = addIssue(report,mieTimeEarlier(obj.end_timestamp,obj.start_timestamp), ...
                    'TimeOrder','end_timestamp','The end cannot precede the start.',reference);
            end
            report = wrapperReport(obj,report,48);
        end
    end
    methods (Access = protected)
        function value = wrapperPrefix(obj) %#codegen
            %wrapperPrefix - Encode exact start/end timestamp text
            value = [textField(obj.start_timestamp,24) textField(obj.end_timestamp,24)];
        end
    end
end
