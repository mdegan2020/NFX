classdef (Sealed) COMNTA < nfx.TRE
    %COMNTA - Unicode comments associated with a file or segment
    %   OBJ = COMNTA(comment=TEXT) stores Unicode text as UTF-8 on the wire.
    %   Separate lines with CR/LF pairs. Do not include a byte-order mark.
    %
    %   COMNTA functions:
    %       deserialize - Decode an independent editable comment
    %       validate    - Check Unicode, line endings and encoded length
    %       payload     - Encode the comment as UTF-8
    %
    %   COMNTA properties:
    %       cetag       - Constant tag identifier
    %       comment     - Original Unicode text
    %
    %   See also TRE, TRERecord, SYSIDA

    properties (Constant)
        cetag = 'COMNTA' % Registered tag identifier
    end
    properties
        comment {mustBeTextScalar} = '' % Unicode comment with CR/LF lines
    end
    methods
        function obj = COMNTA(options) %#codegen
            arguments
                options.?nfx.COMNTA
            end
            if isfield(options, 'comment')
                obj.comment = options.comment;
            end
        end

        function report = validate(obj) %#codegen
            reference = 'STDI-0002-1 Appendix AU, COMNTA-001 through -004';
            report = newReport(reference);
            [data, ok] = encodeUTF8(obj.comment);
            report = addIssue(report, ~ok, 'Unicode', 'comment', ...
                'Supply Unicode scalar values without unpaired surrogates.', ...
                reference);
            report = addIssue(report, isempty(data) || numel(data) > 99985, ...
                'Length', 'comment', 'Encode between 1 and 99985 UTF-8 bytes.', ...
                reference);
            word = char(obj.comment);
            report = addIssue(report, ~isempty(word) && word(1) == char(65279), ...
                'ByteOrderMark', 'comment', 'Omit the Unicode BOM.', reference);
            cr = find(data == 13);
            lf = find(data == 10);
            report = addIssue(report, ~isequal(cr + 1, lf), ...
                'LineEnding', 'comment', 'Separate lines with CR/LF pairs.', ...
                reference);
        end

        function data = payload(obj) %#codegen
            requireValid(obj.validate());
            data = encodeUTF8(obj.comment);
        end
    end
    methods (Static)
        function [obj, ok, status] = deserialize(data) %#codegen
            %deserialize - Decode an independent Unicode comment
            %   OBJ = deserialize(DATA) decodes a uint8 payload row.
            %   [OBJ, OK, STATUS] = deserialize(DATA) also returns success
            %   and a diagnostic. Failure returns a default scalar object.
            arguments
                data
            end
            obj = nfx.COMNTA();
            reader = nfx.internal.TREReader(data);
            [raw, reader] = reader.take(numel(reader.data));
            [value, valid] = decodeUTF8(raw);
            if reader.ok && valid
                obj.comment = value;
            elseif reader.ok
                reader = reader.fail('InvalidText', 'Invalid UTF-8 comment.');
            end
            [obj, ok, status] = finishTREDecode(obj, reader, nfx.COMNTA());
        end
    end
end
