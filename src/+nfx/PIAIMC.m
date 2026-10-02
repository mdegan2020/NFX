classdef (Sealed) PIAIMC < nfx.TRE
    %PIAIMC - Imagery access image metadata
    %   OBJ = PIAIMC(Name=VALUE) supplies editable metadata.
    %   Field names follow specification mnemonics. Counts derive
    %   from supplied values. Numeric metadata uses double.
    %
    %   PIAIMC functions:
    %       deserialize - Decode an independent concrete value
    %       validate    - Check fields and encoded limits
    %       payload     - Encode the metadata payload
    %
    %   PIAIMC properties:
    %       cetag - Constant tag identifier
    %       cloudcvr - CLOUDCVR metadata
    %       srp - SRP metadata
    %       sensmode - SENSMODE metadata
    %       sensname - SENSNAME metadata
    %       source - SOURCE metadata
    %       comgen - COMGEN metadata
    %       subqual - SUBQUAL metadata
    %       piamsnnum - PIAMSNNUM metadata
    %       camspecs - CAMSPECS metadata
    %       projid - PROJID metadata
    %       generation - GENERATION metadata
    %       esd - ESD metadata
    %       othercond - OTHERCOND metadata
    %       meangsd - MEANGSD metadata
    %       idatum - IDATUM metadata
    %       iellip - IELLIP metadata
    %       preproc - PREPROC metadata
    %       iproj - IPROJ metadata
    %       sattrack - SATTRACK metadata
    %
    %   See also TRE, TRERecord

    properties (Constant)
        cetag = 'PIAIMC' % Registered tag identifier
    end
    properties
        % CLOUDCVR metadata
        cloudcvr {mustBeMetadata(cloudcvr, ...
            0, 999, 1)} = NaN
        srp {mustBeAscii(srp, 1)} = '' % SRP metadata
        sensmode {mustBeAscii(sensmode, 12)} = '' % SENSMODE metadata
        sensname {mustBeAscii(sensname, 18)} = '' % SENSNAME metadata
        source {mustBeAscii(source, 255)} = '' % SOURCE metadata
        % COMGEN metadata
        comgen {mustBeMetadata(comgen, ...
            0, 99, 1)} = NaN
        subqual {mustBeAscii(subqual, 1)} = '' % SUBQUAL metadata
        piamsnnum {mustBeAscii(piamsnnum, 7)} = '' % PIAMSNNUM metadata
        camspecs {mustBeAscii(camspecs, 32)} = '' % CAMSPECS metadata
        projid {mustBeAscii(projid, 2)} = '' % PROJID metadata
        % GENERATION metadata
        generation {mustBeMetadata(generation, ...
            0, 9, 1)} = NaN
        esd {mustBeAscii(esd, 1)} = '' % ESD metadata
        othercond {mustBeAscii(othercond, 2)} = '' % OTHERCOND metadata
        % MEANGSD metadata
        meangsd {mustBeMetadata(meangsd, ...
            0, 99999.9, 0)} = NaN
        idatum {mustBeAscii(idatum, 3)} = '' % IDATUM metadata
        iellip {mustBeAscii(iellip, 3)} = '' % IELLIP metadata
        preproc {mustBeAscii(preproc, 2)} = '' % PREPROC metadata
        iproj {mustBeAscii(iproj, 2)} = '' % IPROJ metadata
        sattrack {mustBeAscii(sattrack, 8)} = '' % SATTRACK metadata
    end
    methods
        function obj = PIAIMC(options) %#codegen
            arguments
                options.?nfx.PIAIMC
            end
            if isfield(options, 'cloudcvr')
                obj.cloudcvr = options.cloudcvr;
            end
            if isfield(options, 'srp')
                obj.srp = options.srp;
            end
            if isfield(options, 'sensmode')
                obj.sensmode = options.sensmode;
            end
            if isfield(options, 'sensname')
                obj.sensname = options.sensname;
            end
            if isfield(options, 'source')
                obj.source = options.source;
            end
            if isfield(options, 'comgen')
                obj.comgen = options.comgen;
            end
            if isfield(options, 'subqual')
                obj.subqual = options.subqual;
            end
            if isfield(options, 'piamsnnum')
                obj.piamsnnum = options.piamsnnum;
            end
            if isfield(options, 'camspecs')
                obj.camspecs = options.camspecs;
            end
            if isfield(options, 'projid')
                obj.projid = options.projid;
            end
            if isfield(options, 'generation')
                obj.generation = options.generation;
            end
            if isfield(options, 'esd')
                obj.esd = options.esd;
            end
            if isfield(options, 'othercond')
                obj.othercond = options.othercond;
            end
            if isfield(options, 'meangsd')
                obj.meangsd = options.meangsd;
            end
            if isfield(options, 'idatum')
                obj.idatum = options.idatum;
            end
            if isfield(options, 'iellip')
                obj.iellip = options.iellip;
            end
            if isfield(options, 'preproc')
                obj.preproc = options.preproc;
            end
            if isfield(options, 'iproj')
                obj.iproj = options.iproj;
            end
            if isfield(options, 'sattrack')
                obj.sattrack = options.sattrack;
            end
        end

        function report = validate(obj) %#codegen
            reference = 'STDI-0002-1 Appendix C, Table C-2 (2025-06)';
            report = newReport(reference);
            [~, valid] = treNumber(obj.cloudcvr, 3, 0, false, true, false);
            report = addIssue(report, ~valid, 'Encoding', 'cloudcvr', ...
                'Supply a value fitting the encoded precision.', reference);
            report = addIssue(report, ...
                ~any(strcmp(obj.srp, {'', 'Y', 'N'})), ...
                'Enumeration', 'srp', 'Use a defined SRP value.', reference);
            [~, valid] = treNumber(obj.comgen, 2, 0, false, true, false);
            report = addIssue(report, ~valid, 'Encoding', 'comgen', ...
                'Supply a value fitting the encoded precision.', reference);
            report = addIssue(report, ...
                ~any(strcmp(obj.subqual, {'', 'P', 'F', 'G', 'E'})), ...
                'Enumeration', 'subqual', 'Use a defined SUBQUAL value.', reference);
            [~, valid] = treNumber(obj.generation, 1, 0, false, true, false);
            report = addIssue(report, ~valid, 'Encoding', 'generation', ...
                'Supply a value fitting the encoded precision.', reference);
            report = addIssue(report, ...
                ~any(strcmp(obj.esd, {'', 'Y', 'N'})), ...
                'Enumeration', 'esd', 'Use a defined ESD value.', reference);
            [~, valid] = treNumber(obj.meangsd, 7, 1, false, true, false);
            report = addIssue(report, ~valid, 'Encoding', 'meangsd', ...
                'Supply a value fitting the encoded precision.', reference);
            report = addIssue(report, obj.cloudcvr > 100 && obj.cloudcvr ~= 999, ...
                'Metadata', 'cloudcvr', 'Use 0 through 100, 999 for unknown, or blank.', reference);
            track = char(obj.sattrack);
            valid = isempty(track);
            if numel(track) == 8 && all(track >= '0' & track <= '9')
                valid = str2double(track(1:4)) >= 1 && ...
                    str2double(track(5:8)) >= 1;
            end
            report = addIssue(report, ~valid, ...
                'Metadata', 'sattrack', 'Supply four-digit path and row numbers or blank.', reference);
            payloadLength = 3 + ...
                1 + ...
                12 + ...
                18 + ...
                255 + ...
                2 + ...
                1 + ...
                7 + ...
                32 + ...
                2 + ...
                1 + ...
                1 + ...
                2 + ...
                7 + ...
                3 + ...
                3 + ...
                2 + ...
                2 + ...
                8;
            report = addIssue(report, payloadLength < 1 || ...
                payloadLength > 99985, ...
                'Length', 'cel', 'Payload must fit the TRE length limit.', ...
                reference);
        end

        function data = payload(obj) %#codegen
            requireValid(obj.validate());
            data = zeros(1, 0, 'uint8');
            data = [data treNumber(obj.cloudcvr, 3, 0, false, true, false)];
            data = [data textField(obj.srp, 1)];
            data = [data textField(obj.sensmode, 12)];
            data = [data textField(obj.sensname, 18)];
            data = [data textField(obj.source, 255)];
            data = [data treNumber(obj.comgen, 2, 0, false, true, false)];
            data = [data textField(obj.subqual, 1)];
            data = [data textField(obj.piamsnnum, 7)];
            data = [data textField(obj.camspecs, 32)];
            data = [data textField(obj.projid, 2)];
            data = [data treNumber(obj.generation, 1, 0, false, true, false)];
            data = [data textField(obj.esd, 1)];
            data = [data textField(obj.othercond, 2)];
            data = [data treNumber(obj.meangsd, 7, 1, false, true, false)];
            data = [data textField(obj.idatum, 3)];
            data = [data textField(obj.iellip, 3)];
            data = [data textField(obj.preproc, 2)];
            data = [data textField(obj.iproj, 2)];
            data = [data textField(obj.sattrack, 8)];
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
            obj = nfx.PIAIMC();
            reader = nfx.internal.TREReader(data);
            [value, reader] = reader.number(3, 0, 999, ...
                true, true);
            if reader.ok, obj.cloudcvr = value; end
            [value, reader] = reader.text(1, true, false);
            if reader.ok, obj.srp = value; end
            [value, reader] = reader.text(12, true, false);
            if reader.ok, obj.sensmode = value; end
            [value, reader] = reader.text(18, true, false);
            if reader.ok, obj.sensname = value; end
            [value, reader] = reader.text(255, true, false);
            if reader.ok, obj.source = value; end
            [value, reader] = reader.number(2, 0, 99, ...
                true, true);
            if reader.ok, obj.comgen = value; end
            [value, reader] = reader.text(1, true, false);
            if reader.ok, obj.subqual = value; end
            [value, reader] = reader.text(7, true, false);
            if reader.ok, obj.piamsnnum = value; end
            [value, reader] = reader.text(32, true, false);
            if reader.ok, obj.camspecs = value; end
            [value, reader] = reader.text(2, true, false);
            if reader.ok, obj.projid = value; end
            [value, reader] = reader.number(1, 0, 9, ...
                true, true);
            if reader.ok, obj.generation = value; end
            [value, reader] = reader.text(1, true, false);
            if reader.ok, obj.esd = value; end
            [value, reader] = reader.text(2, true, false);
            if reader.ok, obj.othercond = value; end
            [value, reader] = reader.number(7, 0, 99999.9, ...
                false, true);
            if reader.ok, obj.meangsd = value; end
            [value, reader] = reader.text(3, true, false);
            if reader.ok, obj.idatum = value; end
            [value, reader] = reader.text(3, true, false);
            if reader.ok, obj.iellip = value; end
            [value, reader] = reader.text(2, true, false);
            if reader.ok, obj.preproc = value; end
            [value, reader] = reader.text(2, true, false);
            if reader.ok, obj.iproj = value; end
            [value, reader] = reader.text(8, true, false);
            if reader.ok, obj.sattrack = value; end
            [obj, ok, status] = finishTREDecode( ...
                obj, reader, nfx.PIAIMC());
        end
    end
end
