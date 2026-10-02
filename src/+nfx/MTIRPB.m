classdef (Sealed) MTIRPB < nfx.TRE
    %MTIRPB - Moving target reports
    %   OBJ = MTIRPB(Name=VALUE) supplies editable metadata.
    %   Field names follow specification mnemonics. Counts derive
    %   from supplied values. Numeric metadata uses double.
    %
    %   MTIRPB functions:
    %       deserialize - Decode an independent concrete value
    %       validate    - Check fields and encoded limits
    %       payload     - Encode the metadata payload
    %
    %   MTIRPB properties:
    %       cetag - Constant tag identifier
    %       mti_dp - MTI_DP metadata
    %       mti_packet_id - MTI_PACKET_ID metadata
    %       patch_no - PATCH_NO metadata
    %       wamti_frame_no - WAMTI_FRAME_NO metadata
    %       wamti_bar_no - WAMTI_BAR_NO metadata
    %       datime - DATIME metadata
    %       acft_loc - ACFT_LOC metadata
    %       acft_alt - ACFT_ALT metadata
    %       acft_alt_unit - ACFT_ALT_UNIT metadata
    %       acft_heading - ACFT_HEADING metadata
    %       mti_lr - MTI_LR metadata
    %       squint_angle - SQUINT_ANGLE metadata
    %       cosgrz - COSGRZ metadata
    %       targets - TARGETS metadata
    %
    %   See also TRE, TRERecord

    properties (Constant)
        cetag = 'MTIRPB' % Registered tag identifier
    end
    properties
        % MTI_DP metadata
        mti_dp {mustBeMetadata(mti_dp, ...
            1, 99, 1)} = NaN
        % MTI_PACKET_ID metadata
        mti_packet_id {mustBeMetadata(mti_packet_id, ...
            1, 999, 1)} = NaN
        % PATCH_NO metadata
        patch_no {mustBeMetadata(patch_no, ...
            1, 999, 1)} = NaN
        % WAMTI_FRAME_NO metadata
        wamti_frame_no {mustBeMetadata(wamti_frame_no, ...
            1, 32767, 1)} = NaN
        % WAMTI_BAR_NO metadata
        wamti_bar_no {mustBeMetadata(wamti_bar_no, ...
            1, 7, 1)} = NaN
        datime {mustBeAscii(datime, 14)} = '' % DATIME metadata
        acft_loc {mustBeAscii(acft_loc, 21)} = '' % ACFT_LOC metadata
        % ACFT_ALT metadata
        acft_alt {mustBeMetadata(acft_alt, ...
            0, 999999, 1)} = NaN
        acft_alt_unit {mustBeAscii(acft_alt_unit, 1)} = '' % ACFT_ALT_UNIT metadata
        % ACFT_HEADING metadata
        acft_heading {mustBeMetadata(acft_heading, ...
            0, 359, 1)} = NaN
        mti_lr {mustBeAscii(mti_lr, 1)} = '' % MTI_LR metadata
        % SQUINT_ANGLE metadata
        squint_angle {mustBeMetadata(squint_angle, ...
            -60, 85, 0)} = NaN
        % COSGRZ metadata
        cosgrz {mustBeMetadata(cosgrz, ...
            0, 9.99999, 0)} = NaN
        % TARGETS repeated entries
        targets {mustBetargets} = repmat(newtargets(), 1, 0)
    end
    methods
        function obj = MTIRPB(options) %#codegen
            arguments
                options.?nfx.MTIRPB
            end
            if isfield(options, 'mti_dp')
                obj.mti_dp = options.mti_dp;
            end
            if isfield(options, 'mti_packet_id')
                obj.mti_packet_id = options.mti_packet_id;
            end
            if isfield(options, 'patch_no')
                obj.patch_no = options.patch_no;
            end
            if isfield(options, 'wamti_frame_no')
                obj.wamti_frame_no = options.wamti_frame_no;
            end
            if isfield(options, 'wamti_bar_no')
                obj.wamti_bar_no = options.wamti_bar_no;
            end
            if isfield(options, 'datime')
                obj.datime = options.datime;
            end
            if isfield(options, 'acft_loc')
                obj.acft_loc = options.acft_loc;
            end
            if isfield(options, 'acft_alt')
                obj.acft_alt = options.acft_alt;
            end
            if isfield(options, 'acft_alt_unit')
                obj.acft_alt_unit = options.acft_alt_unit;
            end
            if isfield(options, 'acft_heading')
                obj.acft_heading = options.acft_heading;
            end
            if isfield(options, 'mti_lr')
                obj.mti_lr = options.mti_lr;
            end
            if isfield(options, 'squint_angle')
                obj.squint_angle = options.squint_angle;
            end
            if isfield(options, 'cosgrz')
                obj.cosgrz = options.cosgrz;
            end
            if isfield(options, 'targets')
                obj.targets = options.targets;
            end
        end

        function report = validate(obj) %#codegen
            reference = 'STDI-0002-1 Appendix E, Table E-19 (2025-02)';
            report = newReport(reference);
            [~, valid] = treNumber(obj.mti_dp, 2, 0, false, true, false);
            report = addIssue(report, ~valid, 'Encoding', 'mti_dp', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.mti_packet_id, 3, 0, false, false, false);
            report = addIssue(report, ~valid, 'Encoding', 'mti_packet_id', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.patch_no, 4, 0, false, false, false);
            report = addIssue(report, ~valid, 'Encoding', 'patch_no', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.wamti_frame_no, 5, 0, false, true, false);
            report = addIssue(report, ~valid, 'Encoding', 'wamti_frame_no', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.wamti_bar_no, 1, 0, false, true, false);
            report = addIssue(report, ~valid, 'Encoding', 'wamti_bar_no', ...
                'Supply a value fitting the encoded precision.', reference);
            report = addIssue(report, isempty(strtrim(char(obj.datime))), ...
                'Required', 'datime', 'Supply DATIME.', reference);
            report = addIssue(report, isempty(strtrim(char(obj.acft_loc))), ...
                'Required', 'acft_loc', 'Supply ACFT_LOC.', reference);
            [~, valid] = treNumber(obj.acft_alt, 6, 0, false, false, false);
            report = addIssue(report, ~valid, 'Encoding', 'acft_alt', ...
                'Supply a value fitting the encoded precision.', reference);
            report = addIssue(report, ...
                ~any(strcmp(obj.acft_alt_unit, {'f', 'm'})), ...
                'Enumeration', 'acft_alt_unit', 'Use a defined ACFT_ALT_UNIT value.', reference);
            [~, valid] = treNumber(obj.acft_heading, 3, 0, false, false, false);
            report = addIssue(report, ~valid, 'Encoding', 'acft_heading', ...
                'Supply a value fitting the encoded precision.', reference);
            report = addIssue(report, ...
                ~any(strcmp(obj.mti_lr, {'', 'R', 'L'})), ...
                'Enumeration', 'mti_lr', 'Use a defined MTI_LR value.', reference);
            [~, valid] = treNumber(obj.squint_angle, 6, 2, true, true, false);
            report = addIssue(report, ~valid, 'Encoding', 'squint_angle', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.cosgrz, 7, 5, false, false, false);
            report = addIssue(report, ~valid, 'Encoding', 'cosgrz', ...
                'Supply a value fitting the encoded precision.', reference);
            report = addIssue(report, numel(obj.targets) < 1 || ...
                numel(obj.targets) > 999, ...
                'Count', 'targets', 'Entry count is outside the defined range.', reference);
            for k = 1:numel(obj.targets)
                report = validatetargets(obj.targets(k), report, reference);
            end
            report = addIssue(report, ~knownDate(obj.datime, 14), ...
                'Metadata', 'datime', 'Supply a valid UTC timestamp.', reference);
            report = addIssue(report, ~validLocation21(obj.acft_loc, false, false, false), ...
                'Metadata', 'acft_loc', 'Supply a valid geographic location.', reference);
            report = addIssue(report, obj.cosgrz > 1 && obj.cosgrz ~= 9.99999, ...
                'Metadata', 'cosgrz', 'Supply a cosine from zero to one or the unknown sentinel.', reference);
            payloadLength = 2 + ...
                3 + ...
                4 + ...
                5 + ...
                1 + ...
                14 + ...
                21 + ...
                6 + ...
                1 + ...
                3 + ...
                1 + ...
                6 + ...
                7 + ...
                lengthtargets(obj.targets);
            report = addIssue(report, payloadLength < 1 || ...
                payloadLength > 99985, ...
                'Length', 'cel', 'Payload must fit the TRE length limit.', ...
                reference);
        end

        function data = payload(obj) %#codegen
            requireValid(obj.validate());
            data = zeros(1, 0, 'uint8');
            data = [data treNumber(obj.mti_dp, 2, 0, false, true, false)];
            data = [data treNumber(obj.mti_packet_id, 3, 0, false, false, false)];
            data = [data treNumber(obj.patch_no, 4, 0, false, false, false)];
            data = [data treNumber(obj.wamti_frame_no, 5, 0, false, true, false)];
            data = [data treNumber(obj.wamti_bar_no, 1, 0, false, true, false)];
            data = [data textField(obj.datime, 14)];
            data = [data textField(obj.acft_loc, 21)];
            data = [data treNumber(obj.acft_alt, 6, 0, false, false, false)];
            data = [data textField(obj.acft_alt_unit, 1)];
            data = [data treNumber(obj.acft_heading, 3, 0, false, false, false)];
            data = [data textField(obj.mti_lr, 1)];
            data = [data treNumber(obj.squint_angle, 6, 2, true, true, false)];
            data = [data treNumber(obj.cosgrz, 7, 5, false, false, false)];
            data = [data decimalField(numel(obj.targets), 3, 0, false)];
            for k = 1:numel(obj.targets)
                data = [data writetargets(obj.targets(k))]; %#ok<AGROW>
            end
        end
    end
    methods (Static)
        function entry = targetsEntry() %#codegen
            %targetsEntry - Create one editable repeated entry
            %   ENTRY = nfx.MTIRPB.targetsEntry() supplies the field
            %   structure. Fill its required fields before attachment.
            entry = newtargets();
        end

        function [obj, ok, status] = deserialize(data) %#codegen
            %deserialize - Decode an independent metadata value
            %   OBJ = deserialize(DATA) reads a uint8 payload row.
            %   [OBJ, OK, STATUS] = deserialize(DATA) also returns success
            %   and a diagnostic. Failure returns a default scalar object.
            arguments
                data
            end
            obj = nfx.MTIRPB();
            reader = nfx.internal.TREReader(data);
            [value, reader] = reader.number(2, 1, 99, ...
                true, true);
            if reader.ok, obj.mti_dp = value; end
            [value, reader] = reader.number(3, 1, 999, ...
                true, false);
            if reader.ok, obj.mti_packet_id = value; end
            [value, reader] = reader.number(4, 1, 999, ...
                true, false);
            if reader.ok, obj.patch_no = value; end
            [value, reader] = reader.number(5, 1, 32767, ...
                true, true);
            if reader.ok, obj.wamti_frame_no = value; end
            [value, reader] = reader.number(1, 1, 7, ...
                true, true);
            if reader.ok, obj.wamti_bar_no = value; end
            [value, reader] = reader.text(14, true, false);
            if reader.ok, obj.datime = value; end
            [value, reader] = reader.text(21, true, false);
            if reader.ok, obj.acft_loc = value; end
            [value, reader] = reader.number(6, 0, 999999, ...
                true, false);
            if reader.ok, obj.acft_alt = value; end
            [value, reader] = reader.text(1, true, false);
            if reader.ok, obj.acft_alt_unit = value; end
            [value, reader] = reader.number(3, 0, 359, ...
                true, false);
            if reader.ok, obj.acft_heading = value; end
            [value, reader] = reader.text(1, true, false);
            if reader.ok, obj.mti_lr = value; end
            [value, reader] = reader.number(6, -60, 85, ...
                false, true);
            if reader.ok, obj.squint_angle = value; end
            [value, reader] = reader.number(7, 0, 9.99999, ...
                false, false);
            if reader.ok, obj.cosgrz = value; end
            [count, reader] = reader.count(3, 42, 999);
            entries = repmat(newtargets(), 1, 0);
            for k = 1:count
                [entry, reader] = readtargets(reader);
                if ~reader.ok, break; end
                entries(end + 1) = entry;
            end
            if reader.ok, obj.targets = entries; end
            [obj, ok, status] = finishTREDecode( ...
                obj, reader, nfx.MTIRPB());
        end
    end
end

function entry = newtargets() %#codegen
    entry = struct( ...
        'tgt_loc', '', ...
        'tgt_loc_accy', NaN, ...
        'tgt_vel_r', NaN, ...
        'tgt_speed', NaN, ...
        'tgt_heading', NaN, ...
        'tgt_amplitude', NaN, ...
        'tgt_cat', '');
end

function mustBetargets(entries) %#codegen
    if ~isstruct(entries) || ~(isrow(entries) || isempty(entries)) || ...
            numel(fieldnames(entries)) ~= 7 || ...
            ~all(isfield(entries, { ...
                'tgt_loc', ...
                'tgt_loc_accy', ...
                'tgt_vel_r', ...
                'tgt_speed', ...
                'tgt_heading', ...
                'tgt_amplitude', ...
                'tgt_cat'}))
        error('nfx:TREEntries', 'Supply a row with the defined entry fields.');
    end
    for k = 1:numel(entries)
        entry = entries(k);
        mustBeAscii(entry.tgt_loc, 23);
        mustBeMetadata(entry.tgt_loc_accy, 0, 999.99, false);
        mustBeMetadata(entry.tgt_vel_r, -200, 200, true);
        mustBeMetadata(entry.tgt_speed, 0, 200, true);
        mustBeMetadata(entry.tgt_heading, 0, 359, true);
        mustBeMetadata(entry.tgt_amplitude, 0, 15, true);
        mustBeAscii(entry.tgt_cat, 1);
    end
end

function report = validatetargets(entry, report, reference) %#codegen
    report = addIssue(report, isempty(strtrim(char(entry.tgt_loc))), ...
        'Required', 'tgt_loc', 'Supply TGT_LOC.', reference);
    [~, valid] = treNumber(entry.tgt_loc_accy, 6, 2, false, false, false);
    report = addIssue(report, ~valid, 'Encoding', 'tgt_loc_accy', ...
        'Supply a value fitting the encoded precision.', reference);
    [~, valid] = treNumber(entry.tgt_vel_r, 4, 0, true, true, false);
    report = addIssue(report, ~valid, 'Encoding', 'tgt_vel_r', ...
        'Supply a value fitting the encoded precision.', reference);
    [~, valid] = treNumber(entry.tgt_speed, 3, 0, false, true, false);
    report = addIssue(report, ~valid, 'Encoding', 'tgt_speed', ...
        'Supply a value fitting the encoded precision.', reference);
    [~, valid] = treNumber(entry.tgt_heading, 3, 0, false, true, false);
    report = addIssue(report, ~valid, 'Encoding', 'tgt_heading', ...
        'Supply a value fitting the encoded precision.', reference);
    [~, valid] = treNumber(entry.tgt_amplitude, 2, 0, false, true, false);
    report = addIssue(report, ~valid, 'Encoding', 'tgt_amplitude', ...
        'Supply a value fitting the encoded precision.', reference);
    report = addIssue(report, ...
        ~any(strcmp(entry.tgt_cat, {'', 'H', 'T', 'U', 'W'})), ...
        'Enumeration', 'tgt_cat', 'Use a defined field value.', reference);
    report = addIssue(report, ~validLocation23(entry.tgt_loc), ...
        'Metadata', 'tgt_loc', 'Supply a valid geographic location.', reference);
end

function data = writetargets(entry) %#codegen
    data = zeros(1, 0, 'uint8');
    data = [data textField(entry.tgt_loc, 23)];
    data = [data treNumber(entry.tgt_loc_accy, 6, 2, false, false, false)];
    data = [data treNumber(entry.tgt_vel_r, 4, 0, true, true, false)];
    data = [data treNumber(entry.tgt_speed, 3, 0, false, true, false)];
    data = [data treNumber(entry.tgt_heading, 3, 0, false, true, false)];
    data = [data treNumber(entry.tgt_amplitude, 2, 0, false, true, false)];
    data = [data textField(entry.tgt_cat, 1)];
end

function [entry, reader] = readtargets(reader) %#codegen
    entry = newtargets();
    [value, reader] = reader.text(23, true, false);
    if reader.ok, entry.tgt_loc = value; end
    [value, reader] = reader.number(6, 0, 999.99, ...
        false, false);
    if reader.ok, entry.tgt_loc_accy = value; end
    [value, reader] = reader.number(4, -200, 200, ...
        true, true);
    if reader.ok, entry.tgt_vel_r = value; end
    [value, reader] = reader.number(3, 0, 200, ...
        true, true);
    if reader.ok, entry.tgt_speed = value; end
    [value, reader] = reader.number(3, 0, 359, ...
        true, true);
    if reader.ok, entry.tgt_heading = value; end
    [value, reader] = reader.number(2, 0, 15, ...
        true, true);
    if reader.ok, entry.tgt_amplitude = value; end
    [value, reader] = reader.text(1, true, false);
    if reader.ok, entry.tgt_cat = value; end
end

function count = lengthtargets(entries) %#codegen
    count = 3 + 42 * numel(entries);
end
