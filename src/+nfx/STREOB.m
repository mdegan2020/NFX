classdef (Sealed) STREOB < nfx.TRE
    %STREOB - Stereo mate identification and geometry
    %   OBJ = STREOB(Name=VALUE) supplies editable metadata.
    %   Field names follow specification mnemonics. Counts derive
    %   from supplied values. Numeric metadata uses double.
    %
    %   STREOB functions:
    %       deserialize - Decode an independent concrete value
    %       validate    - Check fields and encoded limits
    %       payload     - Encode the metadata payload
    %
    %   STREOB properties:
    %       cetag - Constant tag identifier
    %       st_id - ST_ID metadata
    %       n_mates - N_MATES metadata
    %       mate_instance - MATE_INSTANCE metadata
    %       b_conv - B_CONV metadata
    %       e_conv - E_CONV metadata
    %       b_asym - B_ASYM metadata
    %       e_asym - E_ASYM metadata
    %       b_bie - B_BIE metadata
    %       e_bie - E_BIE metadata
    %
    %   See also TRE, TRERecord

    properties (Constant)
        cetag = 'STREOB' % Registered tag identifier
    end
    properties
        st_id {mustBeAscii(st_id, 60)} = '' % ST_ID metadata
        % N_MATES metadata
        n_mates {mustBeMetadata(n_mates, ...
            1, 3, 1)} = 1
        % MATE_INSTANCE metadata
        mate_instance {mustBeMetadata(mate_instance, ...
            1, 3, 1)} = 1
        % B_CONV metadata
        b_conv {mustBeMetadata(b_conv, ...
            0, 179.9, 0)} = NaN
        % E_CONV metadata
        e_conv {mustBeMetadata(e_conv, ...
            0, 179.9, 0)} = NaN
        % B_ASYM metadata
        b_asym {mustBeMetadata(b_asym, ...
            0, 90, 0)} = NaN
        % E_ASYM metadata
        e_asym {mustBeMetadata(e_asym, ...
            0, 90, 0)} = NaN
        % B_BIE metadata
        b_bie {mustBeMetadata(b_bie, ...
            -90, 90, 0)} = NaN
        % E_BIE metadata
        e_bie {mustBeMetadata(e_bie, ...
            -90, 90, 0)} = NaN
    end
    methods
        function obj = STREOB(options) %#codegen
            arguments
                options.?nfx.STREOB
            end
            if isfield(options, 'st_id')
                obj.st_id = options.st_id;
            end
            if isfield(options, 'n_mates')
                obj.n_mates = options.n_mates;
            end
            if isfield(options, 'mate_instance')
                obj.mate_instance = options.mate_instance;
            end
            if isfield(options, 'b_conv')
                obj.b_conv = options.b_conv;
            end
            if isfield(options, 'e_conv')
                obj.e_conv = options.e_conv;
            end
            if isfield(options, 'b_asym')
                obj.b_asym = options.b_asym;
            end
            if isfield(options, 'e_asym')
                obj.e_asym = options.e_asym;
            end
            if isfield(options, 'b_bie')
                obj.b_bie = options.b_bie;
            end
            if isfield(options, 'e_bie')
                obj.e_bie = options.e_bie;
            end
        end

        function report = validate(obj) %#codegen
            reference = 'STDI-0002-1 Appendix E, Table E-25 (2025-02)';
            report = newReport(reference);
            report = addIssue(report, isempty(strtrim(char(obj.st_id))), ...
                'Required', 'st_id', 'Supply ST_ID.', reference);
            [~, valid] = treNumber(obj.n_mates, 1, 0, false, false, false);
            report = addIssue(report, ~valid, 'Encoding', 'n_mates', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.mate_instance, 1, 0, false, false, false);
            report = addIssue(report, ~valid, 'Encoding', 'mate_instance', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = stereoConvergenceNumber(obj.b_conv);
            report = addIssue(report, ~valid, 'Encoding', 'b_conv', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = stereoConvergenceNumber(obj.e_conv);
            report = addIssue(report, ~valid, 'Encoding', 'e_conv', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.b_asym, 5, 2, false, true, false);
            report = addIssue(report, ~valid, 'Encoding', 'b_asym', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.e_asym, 5, 2, false, true, false);
            report = addIssue(report, ~valid, 'Encoding', 'e_asym', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.b_bie, 6, 2, true, true, false);
            report = addIssue(report, ~valid, 'Encoding', 'b_bie', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.e_bie, 6, 2, true, true, false);
            report = addIssue(report, ~valid, 'Encoding', 'e_bie', ...
                'Supply a value fitting the encoded precision.', reference);
            report = addIssue(report, obj.mate_instance > obj.n_mates, ...
                'Metadata', 'mate_instance', 'The mate instance cannot exceed N_MATES.', reference);
            payloadLength = 60 + ...
                1 + ...
                1 + ...
                5 + ...
                5 + ...
                5 + ...
                5 + ...
                6 + ...
                6;
            report = addIssue(report, payloadLength < 1 || ...
                payloadLength > 99985, ...
                'Length', 'cel', 'Payload must fit the TRE length limit.', ...
                reference);
        end

        function data = payload(obj) %#codegen
            requireValid(obj.validate());
            data = zeros(1, 0, 'uint8');
            data = [data textField(obj.st_id, 60)];
            data = [data treNumber(obj.n_mates, 1, 0, false, false, false)];
            data = [data treNumber(obj.mate_instance, 1, 0, false, false, false)];
            data = [data stereoConvergenceNumber(obj.b_conv)];
            data = [data stereoConvergenceNumber(obj.e_conv)];
            data = [data treNumber(obj.b_asym, 5, 2, false, true, false)];
            data = [data treNumber(obj.e_asym, 5, 2, false, true, false)];
            data = [data treNumber(obj.b_bie, 6, 2, true, true, false)];
            data = [data treNumber(obj.e_bie, 6, 2, true, true, false)];
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
            obj = nfx.STREOB();
            reader = nfx.internal.TREReader(data, 99985);
            [value, reader] = reader.text(60, true, false);
            if reader.ok, obj.st_id = value; end
            [value, reader] = reader.number(1, 1, 3, ...
                true, false);
            if reader.ok, obj.n_mates = value; end
            [value, reader] = reader.number(1, 1, 3, ...
                true, false);
            if reader.ok, obj.mate_instance = value; end
            [value, reader] = reader.number(5, 0, 179.9, ...
                false, true);
            if reader.ok, obj.b_conv = value; end
            [value, reader] = reader.number(5, 0, 179.9, ...
                false, true);
            if reader.ok, obj.e_conv = value; end
            [value, reader] = reader.number(5, 0, 90, ...
                false, true);
            if reader.ok, obj.b_asym = value; end
            [value, reader] = reader.number(5, 0, 90, ...
                false, true);
            if reader.ok, obj.e_asym = value; end
            [value, reader] = reader.number(6, -90, 90, ...
                false, true);
            if reader.ok, obj.b_bie = value; end
            [value, reader] = reader.number(6, -90, 90, ...
                false, true);
            if reader.ok, obj.e_bie = value; end
            [obj, ok, status] = finishTREDecode( ...
                obj, reader, nfx.STREOB());
        end
    end
end
