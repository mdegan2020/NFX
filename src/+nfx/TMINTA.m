classdef (Sealed) TMINTA < nfx.TRE
    %TMINTA - Explicit time interval definitions for a motion collection
    %   OBJ = TMINTA(INTERVALS) accepts row structs with fields
    %   time_interval_index, start_timestamp, and end_timestamp. Times use
    %   YYYYMMDDhhmmss.sssssssss, with trailing dashes for unused precision.
    %
    %   Index zero marks an ignored entry and requires blank times. A nonzero
    %   index with both times blank describes an empty scheduled interval.
    %   Counts derive from the supplied intervals; their order is preserved.
    %
    %   See also TRE, File, MIMCSA

    properties (Constant)
        cetag = 'TMINTA'
    end
    properties
        intervals {mustBeIntervals} = struct('time_interval_index', {}, 'start_timestamp', {}, 'end_timestamp', {})
    end
    properties (Dependent, SetAccess = private)
        num_time_int
    end
    methods (Static)
        function [obj, ok, status] = deserialize(data) %#codegen
            %deserialize - Decode an independent editable TMINTA value
            %   [OBJ, OK, STATUS] = nfx.TMINTA.deserialize(PAYLOAD)
            %   reads a uint8 row without its tag/length envelope. Failure
            %   returns a default scalar OBJ and a diagnostic STATUS.
            %   Encoded values retain their stored precision.
            %
            %   See also TMINTA, TMINTA.payload
            arguments
                data
            end
            obj = nfx.TMINTA();
            reader = nfx.internal.TREReader(data);
            [count, reader] = reader.count(4, 54, 1851);
            entry = struct('time_interval_index', NaN, ...
                'start_timestamp', '', 'end_timestamp', '');
            entries = repmat(entry, 1, count);
            for k = 1:count
                [entries(k).time_interval_index, reader] = ...
                    reader.number(6, 0, 999999, true);
                [entries(k).start_timestamp, reader] = reader.text(24);
                [entries(k).end_timestamp, reader] = reader.text(24);
            end
            if reader.ok
                obj.intervals = entries;
            end
            [obj, ok, status] = finishTREDecode( ...
                obj, reader, nfx.TMINTA());
        end
    end
    methods
        function obj = TMINTA(intervals) %#codegen
            %TMINTA - Construct editable interval definitions
            arguments
                intervals = struct('time_interval_index', {}, 'start_timestamp', {}, 'end_timestamp', {})
            end
            obj.intervals = intervals;
        end
        function value = get.num_time_int(obj) %#codegen
            %get.num_time_int - Derive the number of interval definitions
            value = numel(obj.intervals);
        end
        function report = validate(obj) %#codegen
            %VALIDATE - Check indices, precision, temporal order and empty entries
            report = newReport('STDI-0002 Appendix AF TMINTA');
            reference = 'STDI-0002-1 Appendix AF, AF4.2, AF5.4 and Table AF-5';
            report = addIssue(report, obj.num_time_int < 1 || obj.num_time_int > 1851, ...
                'TimeIntervalCount', 'intervals', 'Each instance permits 1 to 1851 interval definitions.', reference);
            indices = [obj.intervals.time_interval_index];
            positive = indices(indices > 0);
            report = addIssue(report, numel(unique(positive)) ~= numel(positive), ...
                'DuplicateTimeInterval', 'intervals', 'An interval index must identify one definition per instance.', reference);
            for k = 1:obj.num_time_int
                item = obj.intervals(k);
                startBlank = isempty(strtrim(char(item.start_timestamp)));
                endBlank = isempty(strtrim(char(item.end_timestamp)));
                startValid = validMieTimestamp(item.start_timestamp);
                endValid = validMieTimestamp(item.end_timestamp);
                valid = ~isnan(item.time_interval_index) && ...
                    ((startBlank && endBlank) || (item.time_interval_index > 0 && startValid && endValid));
                report = addIssue(report, ~valid, 'TimeInterval', sprintf('intervals(%d)',k), ...
                    'Supply valid UTC times, or blank both times for an ignored/empty interval.', reference);
                if startValid && endValid
                    report = addIssue(report, mieTimeEarlier(item.end_timestamp,item.start_timestamp), ...
                        'TimeOrder', sprintf('intervals(%d)',k), 'An interval cannot end before it starts.', reference);
                end
            end
        end
        function value = payload(obj) %#codegen
            %PAYLOAD - Serialize fixed-width interval definitions
            requireValid(validate(obj));
            value = zeros(1,4+54*obj.num_time_int,'uint8');
            value(1:4) = decimalField(obj.num_time_int,4,0,false);
            for k = 1:obj.num_time_int
                item = obj.intervals(k);
                at = 4+54*(k-1);
                value(at+1:at+54) = [decimalField(item.time_interval_index,6,0,false) ...
                    textField(item.start_timestamp,24) textField(item.end_timestamp,24)];
            end
        end
    end
end

function mustBeIntervals(value) %#codegen
    %mustBeIntervals - Validate concrete interval structs without conversions
    if ~isstruct(value) || ~(isrow(value) || isempty(value)) || ...
            ~all(isfield(value, {'time_interval_index','start_timestamp','end_timestamp'})) || numel(fieldnames(value)) ~= 3
        error('nfx:TimeIntervals', 'Supply time_interval_index/start_timestamp/end_timestamp row structs.');
    end
    for k = 1:numel(value)
        mustBeMetadata(value(k).time_interval_index,0,999999,true);
        mustBeAscii(value(k).start_timestamp,24);
        mustBeAscii(value(k).end_timestamp,24);
    end
end
