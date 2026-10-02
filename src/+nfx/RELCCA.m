classdef (Sealed) RELCCA < nfx.TRE
    %RELCCA - Release authority and country codes
    %   OBJ = RELCCA(Name=VALUE) supplies editable metadata.
    %   Field names follow specification mnemonics. Counts derive
    %   from supplied values. Numeric metadata uses double.
    %
    %   RELCCA functions:
    %       deserialize - Decode an independent concrete value
    %       validate    - Check fields and encoded limits
    %       payload     - Encode the metadata payload
    %
    %   RELCCA properties:
    %       cetag - Constant tag identifier
    %       reldate - RELDATE metadata
    %       relsours - RELSOURS metadata
    %       relccstd - RELCCSTD metadata
    %       rcolstd - RCOLSTD metadata
    %       rorgstd - RORGSTD metadata
    %       coalid - COALID metadata
    %       coalcc - COALCC metadata
    %       relccodes - RELCCODES metadata
    %       relorg - RELORG metadata
    %
    %   See also TRE, TRERecord

    properties (Constant)
        cetag = 'RELCCA' % Registered tag identifier
    end
    properties
        reldate {mustBeAscii(reldate, 8)} = '--------' % RELDATE metadata
        relsours {mustBeTextScalar} = '' % RELSOURS metadata
        relccstd {mustBeTextScalar} = '' % RELCCSTD metadata
        rcolstd {mustBeTextScalar} = '' % RCOLSTD metadata
        rorgstd {mustBeTextScalar} = '' % RORGSTD metadata
        coalid {mustBeTextScalar} = '' % COALID metadata
        coalcc {mustBeTextScalar} = '' % COALCC metadata
        relccodes {mustBeTextScalar} = '' % RELCCODES metadata
        relorg {mustBeTextScalar} = '' % RELORG metadata
    end
    methods
        function obj = RELCCA(options) %#codegen
            arguments
                options.?nfx.RELCCA
            end
            if isfield(options, 'reldate')
                obj.reldate = options.reldate;
            end
            if isfield(options, 'relsours')
                obj.relsours = options.relsours;
            end
            if isfield(options, 'relccstd')
                obj.relccstd = options.relccstd;
            end
            if isfield(options, 'rcolstd')
                obj.rcolstd = options.rcolstd;
            end
            if isfield(options, 'rorgstd')
                obj.rorgstd = options.rorgstd;
            end
            if isfield(options, 'coalid')
                obj.coalid = options.coalid;
            end
            if isfield(options, 'coalcc')
                obj.coalcc = options.coalcc;
            end
            if isfield(options, 'relccodes')
                obj.relccodes = options.relccodes;
            end
            if isfield(options, 'relorg')
                obj.relorg = options.relorg;
            end
        end

        function report = validate(obj) %#codegen
            reference = 'STDI-0002-1 Appendix AD, Table AD-1 (2023-10)';
            report = newReport(reference);
            [~, valid] = utf8Field(obj.relsours, 4);
            report = addIssue(report, ~valid, 'Unicode', 'relsours', ...
                'Supply valid UTF-8 within the field byte limit.', reference);
            [~, valid] = utf8Field(obj.relccstd, 4);
            report = addIssue(report, ~valid, 'Unicode', 'relccstd', ...
                'Supply valid UTF-8 within the field byte limit.', reference);
            [~, valid] = utf8Field(obj.rcolstd, 4);
            report = addIssue(report, ~valid, 'Unicode', 'rcolstd', ...
                'Supply valid UTF-8 within the field byte limit.', reference);
            [~, valid] = utf8Field(obj.rorgstd, 4);
            report = addIssue(report, ~valid, 'Unicode', 'rorgstd', ...
                'Supply valid UTF-8 within the field byte limit.', reference);
            [~, valid] = utf8Field(obj.coalid, 4);
            report = addIssue(report, ~valid, 'Unicode', 'coalid', ...
                'Supply valid UTF-8 within the field byte limit.', reference);
            if ~isempty(char(obj.coalid))
                [~, valid] = utf8Field(obj.coalcc, 4);
                report = addIssue(report, ~valid, 'Unicode', 'coalcc', ...
                    'Supply valid UTF-8 within the field byte limit.', reference);
            end
            report = addIssue(report, ~(~isempty(char(obj.coalid))) && ~isempty(obj.coalcc), ...
                'AbsentField', 'coalcc', 'Leave the omitted field empty.', reference);
            [~, valid] = utf8Field(obj.relccodes, 4);
            report = addIssue(report, ~valid, 'Unicode', 'relccodes', ...
                'Supply valid UTF-8 within the field byte limit.', reference);
            [~, valid] = utf8Field(obj.relorg, 4);
            report = addIssue(report, ~valid, 'Unicode', 'relorg', ...
                'Supply valid UTF-8 within the field byte limit.', reference);
            report = addIssue(report, numel(char(obj.reldate)) ~= 8 || ...
                ~validDate([char(obj.reldate) '------']), ...
                'Metadata', 'reldate', 'Supply CCYYMMDD with unknown digit pairs as hyphens.', reference);
            report = addIssue(report, (~isempty(char(obj.coalcc)) || ~isempty(char(obj.relccodes))) && ...
                isempty(char(obj.relccstd)), ...
                'Metadata', 'relccstd', 'Specify the country-code standard when countries are listed.', reference);
            report = addIssue(report, ~isempty(char(obj.coalid)) && isempty(char(obj.rcolstd)), ...
                'Metadata', 'rcolstd', 'Specify the coalition-code standard.', reference);
            report = addIssue(report, ~isempty(char(obj.relorg)) && isempty(char(obj.rorgstd)), ...
                'Metadata', 'rorgstd', 'Specify the organization-code standard.', reference);
            payloadLength = 8 + ...
                4 + numel(encodeUTF8(obj.relsours)) + ...
                4 + numel(encodeUTF8(obj.relccstd)) + ...
                4 + numel(encodeUTF8(obj.rcolstd)) + ...
                4 + numel(encodeUTF8(obj.rorgstd)) + ...
                4 + numel(encodeUTF8(obj.coalid)) + ...
                double(~isempty(char(obj.coalid))) * (4 + numel(encodeUTF8(obj.coalcc))) + ...
                4 + numel(encodeUTF8(obj.relccodes)) + ...
                4 + numel(encodeUTF8(obj.relorg));
            report = addIssue(report, payloadLength < 1 || ...
                payloadLength > 99985, ...
                'Length', 'cel', 'Payload must fit the TRE length limit.', ...
                reference);
        end

        function data = payload(obj) %#codegen
            requireValid(obj.validate());
            data = zeros(1, 0, 'uint8');
            data = [data textField(obj.reldate, 8)];
            data = [data utf8Field(obj.relsours, 4)];
            data = [data utf8Field(obj.relccstd, 4)];
            data = [data utf8Field(obj.rcolstd, 4)];
            data = [data utf8Field(obj.rorgstd, 4)];
            data = [data utf8Field(obj.coalid, 4)];
            if ~isempty(char(obj.coalid))
                data = [data utf8Field(obj.coalcc, 4)];
            end
            data = [data utf8Field(obj.relccodes, 4)];
            data = [data utf8Field(obj.relorg, 4)];
        end
    end
    methods (Static)
        function [obj, ok, status] = deserialize(data) %#codegen
            %deserialize - Decode an independent metadata value
            %   OBJ = deserialize(DATA) reads a uint8 payload row.
            %   [OBJ, OK, STATUS] = deserialize(DATA) also returns success
            %   and a diagnostic. Failure returns a default scalar object.
            arguments
                data
            end
            obj = nfx.RELCCA();
            reader = nfx.internal.TREReader(data);
            [value, reader] = reader.text(8, true, false);
            if reader.ok, obj.reldate = value; end
            [value, reader] = readUTF8Field(reader, 4);
            if reader.ok, obj.relsours = value; end
            [value, reader] = readUTF8Field(reader, 4);
            if reader.ok, obj.relccstd = value; end
            [value, reader] = readUTF8Field(reader, 4);
            if reader.ok, obj.rcolstd = value; end
            [value, reader] = readUTF8Field(reader, 4);
            if reader.ok, obj.rorgstd = value; end
            [value, reader] = readUTF8Field(reader, 4);
            if reader.ok, obj.coalid = value; end
            if ~isempty(char(obj.coalid))
                [value, reader] = readUTF8Field(reader, 4);
                if reader.ok, obj.coalcc = value; end
            end
            [value, reader] = readUTF8Field(reader, 4);
            if reader.ok, obj.relccodes = value; end
            [value, reader] = readUTF8Field(reader, 4);
            if reader.ok, obj.relorg = value; end
            [obj, ok, status] = finishTREDecode( ...
                obj, reader, nfx.RELCCA());
        end
    end
end
