classdef (Hidden) NITFReader
    %NITFReader - Checked byte cursor with source-relative diagnostics
    properties (SetAccess = private)
        data = zeros(1, 0, 'uint8')
        ranges = zeros(0, 3)
        sourceLength = 0
        position = 1
        last = 0
        ok = true
        status
    end
    methods
        function obj = NITFReader(data, first, last, scope, index) %#codegen
            arguments
                data
                first = 1
                last = nfx.internal.sourceLength(data)
                scope = 'file'
                index = 0
            end
            obj.status = nfx.internal.readStatus();
            obj.status.scope = scope;
            obj.status.index = index;
            if isstruct(data)
                buffer = data.bytes;
                obj.ranges = data.ranges;
            else
                buffer = data;
            end
            obj.sourceLength = nfx.internal.sourceLength(data);
            if ~isa(buffer, 'uint8') || ~isrow(buffer) || ...
                    ~isscalar(first) || ~isscalar(last) || ...
                    ~isreal(first) || ~isreal(last) || ...
                    ~isfinite(first) || ~isfinite(last) || ...
                    first < 1 || last < first - 1 || ...
                    last > obj.sourceLength || fix(first) ~= first || ...
                    fix(last) ~= last
                obj = obj.fail('InvalidInput', 'Invalid byte buffer bounds.');
                return
            end
            obj.data = buffer;
            obj.position = first;
            obj.last = last;
        end

        function [value, obj] = take(obj, count) %#codegen
            %take - Check available bytes before extracting a field
            value = zeros(1, 0, 'uint8');
            if ~obj.ok, return; end
            if ~isscalar(count) || ~isreal(count) || ~isfinite(count) || ...
                    count < 0 || fix(count) ~= count || ...
                    count > obj.last - obj.position + 1
                obj = obj.fail('MalformedFile', ...
                    'A field extends beyond its declared container.');
                return
            end
            [value, available] = nfx.internal.rangeBytes( ...
                obj.data, obj.ranges, obj.position - 1, count);
            if ~available
                obj = obj.fail('MalformedFile', ...
                    'A requested metadata range is unavailable.');
                return
            end
            obj.position = obj.position + count;
        end

        function [value, obj] = text(obj, width, trim) %#codegen
            %text - Accept printable ASCII and optionally remove right padding
            arguments
                obj
                width
                trim = true
            end
            at = obj.position;
            [raw, obj] = obj.take(width);
            value = '';
            if ~obj.ok, return; end
            if any(raw < 32 | raw > 126)
                obj = obj.fail('MalformedFile', ...
                    'A text field contains non-ASCII characters.', at);
                return
            end
            value = char(raw);
            if trim
                lastNonblank = find(raw ~= 32, 1, 'last');
                if isempty(lastNonblank), value = '';
                else, value = value(1:lastNonblank);
                end
            end
        end

        function [value, obj] = integer(obj, width, lower, upper) %#codegen
            %integer - Read a fixed-width decimal integer without coercion
            arguments
                obj
                width
                lower = 0
                upper = Inf
            end
            at = obj.position;
            [raw, obj] = obj.take(width);
            value = 0;
            if ~obj.ok, return; end
            digits = raw;
            if lower < 0 && ~isempty(raw) && raw(1) == '-'
                digits = raw(2:end);
            end
            valid = ~isempty(digits) && all(digits >= '0' & digits <= '9');
            parsed = str2double(char(raw));
            if ~valid || ~isfinite(parsed) || parsed < lower || parsed > upper
                obj = obj.fail('MalformedFile', ...
                    'A decimal integer field has invalid syntax or range.', at);
                return
            end
            value = parsed;
        end

        function obj = expect(obj, expected, field) %#codegen
            %expect - Require a supported constant field value
            at = obj.position;
            [raw, obj] = obj.take(numel(expected));
            if obj.ok && ~isequal(raw, uint8(expected))
                obj = obj.fail('UnsupportedFeature', ...
                    ['Unsupported ' field ' value.'], at);
            end
        end

        function obj = finish(obj) %#codegen
            %finish - Reject unconsumed subheader bytes
            if obj.ok && obj.position ~= obj.last + 1
                obj = obj.fail('MalformedFile', ...
                    'Declared length disagrees with the parsed fields.');
            end
        end

        function obj = fail(obj, code, message, at) %#codegen
            %fail - Preserve the first failure and its zero-based byte offset
            arguments
                obj
                code
                message
                at = obj.position
            end
            if obj.ok
                obj.ok = false;
                obj.status.code = code;
                obj.status.message = message;
                obj.status.offset = at - 1;
            end
        end
    end
end
