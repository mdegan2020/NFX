classdef (Hidden) TREReader
    %TREReader - Checked cursor for bounded physical TRE payloads

    properties (SetAccess = private)
        data = zeros(1, 0, 'uint8')
        position = 1
        ok = true
        code = 'OK'
        message = ''
    end

    methods
        function obj = TREReader(data) %#codegen
            if ~isa(data, 'uint8') || ~isrow(data) || ...
                    isempty(data) || numel(data) > 99985
                obj = obj.fail('InvalidPayload', ...
                    'Supply a uint8 row containing 1 to 99985 bytes.');
                return
            end
            obj.data = data;
        end

        function [value, obj] = take(obj, count) %#codegen
            %take - Consume bytes only after checking the remaining length
            value = zeros(1, 0, 'uint8');
            if ~obj.ok
                return
            end
            if ~isscalar(count) || ~isreal(count) || ~isfinite(count) || ...
                    count < 0 || fix(count) ~= count || ...
                    count > numel(obj.data) - obj.position + 1
                obj = obj.fail('TruncatedPayload', ...
                    'A field or repeated group exceeds the payload.');
                return
            end
            value = obj.data(obj.position:obj.position + count - 1);
            obj.position = obj.position + count;
        end

        function [value, obj] = text(obj, width, trim, ecs) %#codegen
            %text - Read printable text with optional right-padding removal
            arguments
                obj
                width
                trim = true
                ecs = false
            end
            [raw, obj] = obj.take(width);
            value = '';
            if ~obj.ok
                if isscalar(width) && isreal(width) && isfinite(width) && ...
                        width >= 0 && width <= 99985 && fix(width) == width
                    value = repmat(' ', 1, width);
                end
                return
            end
            if any(raw < 32 | (raw > 126 & raw < 160)) || ...
                    (~ecs && any(raw > 126))
                obj = obj.fail('InvalidText', ...
                    'A text field contains unsupported characters.');
                value = repmat(' ', 1, width);
                return
            end
            value = char(raw);
            if isempty(raw)
                value = '';
                return
            end
            if trim
                last = find(value ~= ' ', 1, 'last');
                if isempty(last)
                    value = '';
                else
                    value = value(1:last);
                end
            end
        end

        function [value, obj] = number(obj, width, lower, upper, ...
                integral, blank) %#codegen
            %number - Read a finite decimal value or an allowed blank field
            arguments
                obj
                width
                lower = -Inf
                upper = Inf
                integral = false
                blank = false
            end
            [raw, obj] = obj.take(width);
            value = NaN;
            if ~obj.ok
                return
            end
            if blank && all(raw == uint8(' '))
                return
            end
            valid = all((raw >= '0' & raw <= '9') | ...
                raw == '+' | raw == '-' | raw == '.' | ...
                raw == 'E' | raw == 'e' | raw == ' ');
            if valid
                value = str2double(char(raw));
                valid = isreal(value) && isfinite(value) && ...
                    value >= lower && value <= upper && ...
                    (~integral || fix(value) == value);
            end
            if ~valid
                value = NaN;
                obj = obj.fail('InvalidNumber', ...
                    'A numeric field has invalid syntax or range.');
            end
        end

        function [values, obj] = numbers(obj, count, width, ...
                lower, upper, integral, blank) %#codegen
            %numbers - Read a count bounded by the available payload bytes
            arguments
                obj
                count
                width
                lower = -Inf
                upper = Inf
                integral = false
                blank = false
            end
            values = zeros(1, 0);
            if ~obj.ok
                return
            end
            if ~isscalar(count) || ~isfinite(count) || count < 0 || ...
                    fix(count) ~= count || width < 1 || ...
                    count > floor((numel(obj.data) - obj.position + 1) ...
                                  / width)
                obj = obj.fail('TruncatedPayload', ...
                    'A numeric array exceeds the remaining payload.');
                return
            end
            values = zeros(1, count);
            for k = 1:count
                [values(k), obj] = obj.number( ...
                    width, lower, upper, integral, blank);
            end
        end

        function [values, obj] = unsigned(obj, width, count) %#codegen
            %unsigned - Decode exact big-endian integers without doubles
            arguments
                obj
                width
                count = 1
            end
            values = zeros(1, 0, 'uint64');
            if ~obj.ok
                return
            end
            if ~isscalar(width) || ~any(width == 1:8) || ...
                    ~isscalar(count) || ~isfinite(count) || count < 0 || ...
                    fix(count) ~= count
                obj = obj.fail('InvalidNumber', ...
                    'Unsupported binary integer width or count.');
                return
            end
            [raw, obj] = obj.take(width * count);
            if ~obj.ok
                return
            end
            values = zeros(1, count, 'uint64');
            for k = 1:count
                for j = 1:width
                    values(k) = bitor(bitshift(values(k), 8), ...
                        uint64(raw((k - 1) * width + j)));
                end
            end
        end

        function [values, obj] = float32(obj, count, lower, upper) %#codegen
            %float32 - Decode big-endian IEEE binary32 into double metadata
            arguments
                obj
                count = 1
                lower = -Inf
                upper = Inf
            end
            [bits, obj] = obj.unsigned(4, count);
            values = double(typecast(uint32(bits), 'single'));
            if obj.ok && any(~isfinite(values) | ...
                    values < lower | values > upper)
                obj = obj.fail('InvalidNumber', ...
                    'Binary floating-point metadata must be finite.');
            end
        end

        function obj = literal(obj, expected) %#codegen
            %literal - Check a fixed reserved field or format discriminator
            [raw, obj] = obj.take(numel(expected));
            if obj.ok && ~isequal(raw, uint8(expected))
                obj = obj.fail('InvalidField', ...
                    'A reserved field or discriminator is unsupported.');
            end
        end

        function [value, obj] = count(obj, width, minimum, maximum) %#codegen
            %count - Bound a repeated group before allocating its entries
            [value, obj] = obj.number(width, 0, maximum, true);
            if obj.ok && value * minimum > ...
                    numel(obj.data) - obj.position + 1
                obj = obj.fail('TruncatedPayload', ...
                    'The declared group count exceeds the payload.');
            end
            if ~obj.ok
                value = 0;
            end
        end

        function [value, obj] = ue13(obj) %#codegen
            %ue13 - Read an unsigned exponent or the MIE unknown sentinel
            [raw, obj] = obj.take(13);
            value = NaN;
            if ~obj.ok || isequal(raw, uint8('NaN          '))
                return
            end
            obj.position = obj.position - 13;
            [value, obj] = obj.number(13, 0, 3.4028234E38);
        end

        function [value, obj] = choice(obj, allowed) %#codegen
            %choice - Read one explicitly supported layout discriminator
            [value, obj] = obj.text(1, false);
            if obj.ok && ~any(value == allowed)
                obj = obj.fail('InvalidField', ...
                    'An optional-group discriminator is unsupported.');
            end
        end

        function [value, obj] = sizedText(obj, width, maximum) %#codegen
            %sizedText - Read a length-prefixed unpadded ASCII field
            [count, obj] = obj.count(width, 1, maximum);
            [value, obj] = obj.text(count, false);
        end

        function [value, obj] = textRows(obj, width, count, ecs) %#codegen
            %textRows - Read padded rows after checking every character
            [raw, obj] = obj.text(width * count, false, ecs);
            value = '';
            if obj.ok
                value = reshape(raw, width, count).';
            end
        end

        function [value, obj] = dashed(obj, width, ...
                lower, upper, integral) %#codegen
            %dashed - Read a numeric field with an all-dash unknown sentinel
            arguments
                obj
                width
                lower
                upper
                integral = false
            end
            [raw, obj] = obj.take(width);
            value = NaN;
            if ~obj.ok || all(raw == '-')
                return
            end
            obj.position = obj.position - width;
            [value, obj] = obj.number(width, lower, upper, integral);
        end

        function [value, places, obj] = decimal(obj, width, ...
                lower, upper, maximum) %#codegen
            %decimal - Preserve the encoded fractional precision of a field
            first = obj.position;
            [value, obj] = obj.number(width, lower, upper);
            places = 1;
            if ~obj.ok
                return
            end
            raw = obj.data(first:first + width - 1);
            point = find(raw == '.');
            if numel(point) ~= 1 || width - point < 1 || ...
                    width - point > maximum
                obj = obj.fail('InvalidNumber', ...
                    'The decimal field has unsupported precision.');
            else
                places = width - point;
            end
        end

        function [value, places, obj] = coordinate(obj, width, ...
                lower, upper) %#codegen
            %coordinate - Read a signed location and trailing precision dashes
            [raw, obj] = obj.take(width);
            value = NaN;
            places = 6;
            if ~obj.ok
                return
            end
            point = width - 6;
            fraction = raw(point + 1:end);
            firstDash = find(fraction == '-', 1);
            if ~isempty(firstDash)
                places = firstDash - 1;
            end
            valid = any(raw(1) == '+-') && raw(point) == '.' && ...
                all(raw(2:point - 1) >= '0' & ...
                    raw(2:point - 1) <= '9') && ...
                all(fraction(1:places) >= '0' & ...
                    fraction(1:places) <= '9') && ...
                all(fraction(places + 1:end) == '-');
            if valid
                value = str2double(char(raw(1:point + places)));
                valid = isfinite(value) && value >= lower && value <= upper;
            end
            if ~valid
                obj = obj.fail('InvalidNumber', ...
                    'Invalid coordinate or precision suffix.');
            end
        end

        function obj = finish(obj) %#codegen
            %finish - Reject unconsumed trailing bytes
            if obj.ok && obj.position ~= numel(obj.data) + 1
                obj = obj.fail('TrailingData', ...
                    'Unconsumed bytes follow the decoded TRE.');
            end
        end

        function obj = fail(obj, code, message) %#codegen
            %fail - Retain the first parsing failure
            if obj.ok
                obj.ok = false;
                obj.code = code;
                obj.message = message;
            end
        end
    end
end
