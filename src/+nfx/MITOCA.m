classdef (Sealed) MITOCA < nfx.TRE
    %MITOCA - Multiple-image table of contents
    %   OBJ = MITOCA(Name=VALUE) supplies editable metadata.
    %   Field names follow specification mnemonics. Counts derive
    %   from supplied values. Numeric metadata uses double.
    %   All component IDs share a width and COMPONENT_INDEX_TYPE; their
    %   common layout is encoded once before the component list.
    %
    %   MITOCA functions:
    %       deserialize - Decode an independent concrete value
    %       validate    - Check fields and encoded limits
    %       payload     - Encode the metadata payload
    %
    %   MITOCA properties:
    %       cetag - Constant tag identifier
    %       scene_type - SCENE_TYPE metadata
    %       scene_id - SCENE_ID metadata
    %       look_composite_index - LOOK_COMPOSITE_INDEX metadata
    %       look_composite_id - LOOK_COMPOSITE_ID metadata
    %       look_corner_1 - LOOK_CORNER_1 metadata
    %       look_corner_2 - LOOK_CORNER_2 metadata
    %       look_corner_3 - LOOK_CORNER_3 metadata
    %       look_corner_4 - LOOK_CORNER_4 metadata
    %       num_volumes - NUM_VOLUMES metadata
    %       look_instance - LOOK_INSTANCE metadata
    %       volume_num - VOLUME_NUM metadata
    %       sensor_id - SENSOR_ID metadata
    %       sensor_id_type - SENSOR_ID_TYPE metadata
    %       mplan - MPLAN metadata
    %       volume_composite_index - VOLUME_COMPOSITE_INDEX metadata
    %       volume_composite_id - VOLUME_COMPOSITE_ID metadata
    %       volume_corner_1 - VOLUME_CORNER_1 metadata
    %       volume_corner_2 - VOLUME_CORNER_2 metadata
    %       volume_corner_3 - VOLUME_CORNER_3 metadata
    %       volume_corner_4 - VOLUME_CORNER_4 metadata
    %       components_flag - COMPONENTS_FLAG metadata
    %       num_rows - NUM_ROWS metadata
    %       num_cols - NUM_COLS metadata
    %       dsr - DSR metadata
    %       components - COMPONENTS metadata
    %
    %   See also TRE, TRERecord

    properties (Constant)
        cetag = 'MITOCA' % Registered tag identifier
    end
    properties
        % SCENE_TYPE metadata
        scene_type {mustBeMetadata(scene_type, ...
            0, 999, 1)} = NaN
        scene_id {mustBeAscii(scene_id, 999)} = '' % SCENE_ID metadata
        % LOOK_COMPOSITE_INDEX metadata
        look_composite_index {mustBeMetadata(look_composite_index, ...
            0, 999, 1)} = NaN
        look_composite_id {mustBeAscii(look_composite_id, 999)} = '' % LOOK_COMPOSITE_ID metadata
        look_corner_1 {mustBeAscii(look_corner_1, 21)} = '' % LOOK_CORNER_1 metadata
        look_corner_2 {mustBeAscii(look_corner_2, 21)} = '' % LOOK_CORNER_2 metadata
        look_corner_3 {mustBeAscii(look_corner_3, 21)} = '' % LOOK_CORNER_3 metadata
        look_corner_4 {mustBeAscii(look_corner_4, 21)} = '' % LOOK_CORNER_4 metadata
        % NUM_VOLUMES metadata
        num_volumes {mustBeMetadata(num_volumes, ...
            1, 999999, 1)} = NaN
        % LOOK_INSTANCE metadata
        look_instance {mustBeMetadata(look_instance, ...
            1, 999999, 1)} = NaN
        % VOLUME_NUM metadata
        volume_num {mustBeMetadata(volume_num, ...
            1, 999999, 1)} = NaN
        sensor_id {mustBeAscii(sensor_id, 6)} = '' % SENSOR_ID metadata
        sensor_id_type {mustBeAscii(sensor_id_type, 4)} = '' % SENSOR_ID_TYPE metadata
        mplan {mustBeAscii(mplan, 3)} = '' % MPLAN metadata
        % VOLUME_COMPOSITE_INDEX metadata
        volume_composite_index {mustBeMetadata(volume_composite_index, ...
            0, 999, 1)} = NaN
        volume_composite_id {mustBeAscii(volume_composite_id, 999)} = '' % VOLUME_COMPOSITE_ID metadata
        volume_corner_1 {mustBeAscii(volume_corner_1, 21)} = '' % VOLUME_CORNER_1 metadata
        volume_corner_2 {mustBeAscii(volume_corner_2, 21)} = '' % VOLUME_CORNER_2 metadata
        volume_corner_3 {mustBeAscii(volume_corner_3, 21)} = '' % VOLUME_CORNER_3 metadata
        volume_corner_4 {mustBeAscii(volume_corner_4, 21)} = '' % VOLUME_CORNER_4 metadata
        % COMPONENTS_FLAG metadata
        components_flag {mustBeMetadata(components_flag, ...
            0, 1, 1)} = NaN
        % NUM_ROWS metadata
        num_rows {mustBeMetadata(num_rows, ...
            1, 99999999, 1)} = NaN
        % NUM_COLS metadata
        num_cols {mustBeMetadata(num_cols, ...
            1, 99999999, 1)} = NaN
        % DSR metadata
        dsr {mustBeMetadata(dsr, ...
            1, 9999.99, 0)} = NaN
        % COMPONENTS repeated entries
        components {mustBecomponents} = repmat(newcomponents(), 1, 0)
    end
    methods
        function obj = MITOCA(options) %#codegen
            arguments
                options.?nfx.MITOCA
            end
            if isfield(options, 'scene_type')
                obj.scene_type = options.scene_type;
            end
            if isfield(options, 'scene_id')
                obj.scene_id = options.scene_id;
            end
            if isfield(options, 'look_composite_index')
                obj.look_composite_index = options.look_composite_index;
            end
            if isfield(options, 'look_composite_id')
                obj.look_composite_id = options.look_composite_id;
            end
            if isfield(options, 'look_corner_1')
                obj.look_corner_1 = options.look_corner_1;
            end
            if isfield(options, 'look_corner_2')
                obj.look_corner_2 = options.look_corner_2;
            end
            if isfield(options, 'look_corner_3')
                obj.look_corner_3 = options.look_corner_3;
            end
            if isfield(options, 'look_corner_4')
                obj.look_corner_4 = options.look_corner_4;
            end
            if isfield(options, 'num_volumes')
                obj.num_volumes = options.num_volumes;
            end
            if isfield(options, 'look_instance')
                obj.look_instance = options.look_instance;
            end
            if isfield(options, 'volume_num')
                obj.volume_num = options.volume_num;
            end
            if isfield(options, 'sensor_id')
                obj.sensor_id = options.sensor_id;
            end
            if isfield(options, 'sensor_id_type')
                obj.sensor_id_type = options.sensor_id_type;
            end
            if isfield(options, 'mplan')
                obj.mplan = options.mplan;
            end
            if isfield(options, 'volume_composite_index')
                obj.volume_composite_index = options.volume_composite_index;
            end
            if isfield(options, 'volume_composite_id')
                obj.volume_composite_id = options.volume_composite_id;
            end
            if isfield(options, 'volume_corner_1')
                obj.volume_corner_1 = options.volume_corner_1;
            end
            if isfield(options, 'volume_corner_2')
                obj.volume_corner_2 = options.volume_corner_2;
            end
            if isfield(options, 'volume_corner_3')
                obj.volume_corner_3 = options.volume_corner_3;
            end
            if isfield(options, 'volume_corner_4')
                obj.volume_corner_4 = options.volume_corner_4;
            end
            if isfield(options, 'components_flag')
                obj.components_flag = options.components_flag;
            end
            if isfield(options, 'num_rows')
                obj.num_rows = options.num_rows;
            end
            if isfield(options, 'num_cols')
                obj.num_cols = options.num_cols;
            end
            if isfield(options, 'dsr')
                obj.dsr = options.dsr;
            end
            if isfield(options, 'components')
                obj.components = options.components;
            end
        end

        function report = validate(obj) %#codegen
            reference = 'STDI-0002-1 Appendix O, Table O-1 (2021-10)';
            report = newReport(reference);
            [~, valid] = treNumber(obj.scene_type, 3, 0, false, false, false);
            report = addIssue(report, ~valid, 'Encoding', 'scene_type', ...
                'Supply a value fitting the encoded precision.', reference);
            report = addIssue(report, isempty(strtrim(char(obj.scene_id))), ...
                'Required', 'scene_id', 'Supply SCENE_ID.', reference);
            [~, valid] = markedNumber(obj.look_composite_index, 3, 0, '---');
            report = addIssue(report, ~valid, 'Encoding', 'look_composite_index', ...
                'Supply a value fitting the encoded precision.', reference);
            if ~isnan(obj.look_composite_index)
                report = addIssue(report, isempty(strtrim(char(obj.look_corner_1))), ...
                    'Required', 'look_corner_1', 'Supply LOOK_CORNER_1.', reference);
            end
            report = addIssue(report, ~(~isnan(obj.look_composite_index)) && ~isempty(obj.look_corner_1), ...
                'AbsentField', 'look_corner_1', 'Leave the omitted field empty.', reference);
            if ~isnan(obj.look_composite_index)
                report = addIssue(report, isempty(strtrim(char(obj.look_corner_2))), ...
                    'Required', 'look_corner_2', 'Supply LOOK_CORNER_2.', reference);
            end
            report = addIssue(report, ~(~isnan(obj.look_composite_index)) && ~isempty(obj.look_corner_2), ...
                'AbsentField', 'look_corner_2', 'Leave the omitted field empty.', reference);
            if ~isnan(obj.look_composite_index)
                report = addIssue(report, isempty(strtrim(char(obj.look_corner_3))), ...
                    'Required', 'look_corner_3', 'Supply LOOK_CORNER_3.', reference);
            end
            report = addIssue(report, ~(~isnan(obj.look_composite_index)) && ~isempty(obj.look_corner_3), ...
                'AbsentField', 'look_corner_3', 'Leave the omitted field empty.', reference);
            if ~isnan(obj.look_composite_index)
                report = addIssue(report, isempty(strtrim(char(obj.look_corner_4))), ...
                    'Required', 'look_corner_4', 'Supply LOOK_CORNER_4.', reference);
            end
            report = addIssue(report, ~(~isnan(obj.look_composite_index)) && ~isempty(obj.look_corner_4), ...
                'AbsentField', 'look_corner_4', 'Leave the omitted field empty.', reference);
            [~, valid] = markedNumber(obj.num_volumes, 6, 0, '------');
            report = addIssue(report, ~valid, 'Encoding', 'num_volumes', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.look_instance, 6, 0, false, false, false);
            report = addIssue(report, ~valid, 'Encoding', 'look_instance', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.volume_num, 6, 0, false, false, false);
            report = addIssue(report, ~valid, 'Encoding', 'volume_num', ...
                'Supply a value fitting the encoded precision.', reference);
            report = addIssue(report, isempty(strtrim(char(obj.sensor_id))), ...
                'Required', 'sensor_id', 'Supply SENSOR_ID.', reference);
            report = addIssue(report, isempty(strtrim(char(obj.sensor_id_type))), ...
                'Required', 'sensor_id_type', 'Supply SENSOR_ID_TYPE.', reference);
            report = addIssue(report, isempty(strtrim(char(obj.mplan))), ...
                'Required', 'mplan', 'Supply MPLAN.', reference);
            [~, valid] = treNumber(obj.volume_composite_index, 3, 0, false, false, false);
            report = addIssue(report, ~valid, 'Encoding', 'volume_composite_index', ...
                'Supply a value fitting the encoded precision.', reference);
            report = addIssue(report, isempty(strtrim(char(obj.volume_composite_id))), ...
                'Required', 'volume_composite_id', 'Supply VOLUME_COMPOSITE_ID.', reference);
            report = addIssue(report, isempty(strtrim(char(obj.volume_corner_1))), ...
                'Required', 'volume_corner_1', 'Supply VOLUME_CORNER_1.', reference);
            report = addIssue(report, isempty(strtrim(char(obj.volume_corner_2))), ...
                'Required', 'volume_corner_2', 'Supply VOLUME_CORNER_2.', reference);
            report = addIssue(report, isempty(strtrim(char(obj.volume_corner_3))), ...
                'Required', 'volume_corner_3', 'Supply VOLUME_CORNER_3.', reference);
            report = addIssue(report, isempty(strtrim(char(obj.volume_corner_4))), ...
                'Required', 'volume_corner_4', 'Supply VOLUME_CORNER_4.', reference);
            [~, valid] = treNumber(obj.components_flag, 1, 0, false, false, false);
            report = addIssue(report, ~valid, 'Encoding', 'components_flag', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.num_rows, 8, 0, false, false, false);
            report = addIssue(report, ~valid, 'Encoding', 'num_rows', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.num_cols, 8, 0, false, false, false);
            report = addIssue(report, ~valid, 'Encoding', 'num_cols', ...
                'Supply a value fitting the encoded precision.', reference);
            [~, valid] = treNumber(obj.dsr, 7, 2, false, false, false);
            report = addIssue(report, ~valid, 'Encoding', 'dsr', ...
                'Supply a value fitting the encoded precision.', reference);
            report = addIssue(report, numel(obj.components) < 1 || ...
                numel(obj.components) > 999, ...
                'Count', 'components', 'Entry count is outside the defined range.', reference);
            for k = 1:numel(obj.components)
                report = validatecomponents(obj.components(k), report, reference, obj.volume_composite_index);
                report = addIssue(report, ...
                    numel(char(obj.components(k).component_id)) ~= ...
                        numel(char(obj.components(1).component_id)) || ...
                    obj.components(k).component_index_type ~= ...
                        obj.components(1).component_index_type, ...
                    'ComponentLayout', 'components', ...
                    'Components share one identifier width and index type.', reference);
            end
            report = addIssue(report, isnan(obj.look_composite_index) && ~isempty(char(obj.look_composite_id)), ...
                'Metadata', 'look_composite_id', 'Omit the identifier when the look index is unknown.', reference);
            report = addIssue(report, ~validLocation21(obj.volume_corner_1, true, false, false), ...
                'Metadata', 'volume_corner_1', 'Supply a valid geographic corner.', reference);
            report = addIssue(report, ~validLocation21(obj.volume_corner_2, true, false, false), ...
                'Metadata', 'volume_corner_2', 'Supply a valid geographic corner.', reference);
            report = addIssue(report, ~validLocation21(obj.volume_corner_3, true, false, false), ...
                'Metadata', 'volume_corner_3', 'Supply a valid geographic corner.', reference);
            report = addIssue(report, ~validLocation21(obj.volume_corner_4, true, false, false), ...
                'Metadata', 'volume_corner_4', 'Supply a valid geographic corner.', reference);
            report = addIssue(report, ~isnan(obj.look_composite_index) && ...
                ~validLocation21(obj.look_corner_1, true, false, false), ...
                'Metadata', 'look_corner_1', 'Supply a valid geographic corner.', reference);
            report = addIssue(report, ~isnan(obj.look_composite_index) && ...
                ~validLocation21(obj.look_corner_2, true, false, false), ...
                'Metadata', 'look_corner_2', 'Supply a valid geographic corner.', reference);
            report = addIssue(report, ~isnan(obj.look_composite_index) && ...
                ~validLocation21(obj.look_corner_3, true, false, false), ...
                'Metadata', 'look_corner_3', 'Supply a valid geographic corner.', reference);
            report = addIssue(report, ~isnan(obj.look_composite_index) && ...
                ~validLocation21(obj.look_corner_4, true, false, false), ...
                'Metadata', 'look_corner_4', 'Supply a valid geographic corner.', reference);
            payloadLength = 3 + ...
                3 + numel(char(obj.scene_id)) + ...
                3 + ...
                3 + numel(char(obj.look_composite_id)) + ...
                double(~isnan(obj.look_composite_index)) * (21) + ...
                double(~isnan(obj.look_composite_index)) * (21) + ...
                double(~isnan(obj.look_composite_index)) * (21) + ...
                double(~isnan(obj.look_composite_index)) * (21) + ...
                6 + ...
                6 + ...
                6 + ...
                6 + ...
                4 + ...
                3 + ...
                3 + ...
                3 + numel(char(obj.volume_composite_id)) + ...
                21 + ...
                21 + ...
                21 + ...
                21 + ...
                3 + ...
                1 + ...
                8 + ...
                8 + ...
                7 + ...
                lengthcomponents(obj.components, obj.volume_composite_index);
            report = addIssue(report, payloadLength < 1 || ...
                payloadLength > 99985, ...
                'Length', 'cel', 'Payload must fit the TRE length limit.', ...
                reference);
        end

        function data = payload(obj) %#codegen
            requireValid(obj.validate());
            data = zeros(1, 0, 'uint8');
            data = [data treNumber(obj.scene_type, 3, 0, false, false, false)];
            data = [data decimalField(numel(char(obj.scene_id)), 3, 0, false) ...
                uint8(char(obj.scene_id))];
            data = [data markedNumber(obj.look_composite_index, 3, 0, '---')];
            data = [data decimalField(numel(char(obj.look_composite_id)), 3, 0, false) ...
                uint8(char(obj.look_composite_id))];
            if ~isnan(obj.look_composite_index)
                data = [data textField(obj.look_corner_1, 21)];
            end
            if ~isnan(obj.look_composite_index)
                data = [data textField(obj.look_corner_2, 21)];
            end
            if ~isnan(obj.look_composite_index)
                data = [data textField(obj.look_corner_3, 21)];
            end
            if ~isnan(obj.look_composite_index)
                data = [data textField(obj.look_corner_4, 21)];
            end
            data = [data markedNumber(obj.num_volumes, 6, 0, '------')];
            data = [data treNumber(obj.look_instance, 6, 0, false, false, false)];
            data = [data treNumber(obj.volume_num, 6, 0, false, false, false)];
            data = [data textField(obj.sensor_id, 6)];
            data = [data textField(obj.sensor_id_type, 4)];
            data = [data textField(obj.mplan, 3)];
            data = [data treNumber(obj.volume_composite_index, 3, 0, false, false, false)];
            data = [data decimalField(numel(char(obj.volume_composite_id)), 3, 0, false) ...
                uint8(char(obj.volume_composite_id))];
            data = [data textField(obj.volume_corner_1, 21)];
            data = [data textField(obj.volume_corner_2, 21)];
            data = [data textField(obj.volume_corner_3, 21)];
            data = [data textField(obj.volume_corner_4, 21)];
            data = [data decimalField(numel(obj.components), 3, 0, false)];
            data = [data treNumber(obj.components_flag, 1, 0, false, false, false)];
            data = [data treNumber(obj.num_rows, 8, 0, false, false, false)];
            data = [data treNumber(obj.num_cols, 8, 0, false, false, false)];
            data = [data treNumber(obj.dsr, 7, 2, false, false, false)];
            data = [data decimalField( ...
                numel(char(obj.components(1).component_id)), 3, 0, false) ...
                treNumber(obj.components(1).component_index_type, ...
                    1, 0, false, false, false)];
            for k = 1:numel(obj.components)
                data = [data writecomponents(obj.components(k), obj.volume_composite_index)]; %#ok<AGROW>
            end
        end
    end
    methods (Static)
        function entry = componentsEntry() %#codegen
            %componentsEntry - Create one editable repeated entry
            %   ENTRY = nfx.MITOCA.componentsEntry() supplies the field
            %   structure. Fill its required fields before attachment.
            entry = newcomponents();
        end

        function [obj, ok, status] = deserialize(data) %#codegen
            %deserialize - Decode an independent metadata value
            %   OBJ = deserialize(DATA) reads a uint8 payload row.
            %   [OBJ, OK, STATUS] = deserialize(DATA) also returns success
            %   and a diagnostic. Failure returns a default scalar object.
            arguments
                data
            end
            obj = nfx.MITOCA();
            reader = nfx.internal.TREReader(data, 99985);
            [value, reader] = reader.number(3, 0, 999, ...
                true, false);
            if reader.ok, obj.scene_type = value; end
            [count, reader] = reader.count(3, 1, 999);
            [value, reader] = reader.text(count, false, false);
            if reader.ok, obj.scene_id = value; end
            [value, reader] = readMarkedNumber(reader, 3, '---', 0, 999, true);
            if reader.ok, obj.look_composite_index = value; end
            [count, reader] = reader.count(3, 1, 999);
            [value, reader] = reader.text(count, false, false);
            if reader.ok, obj.look_composite_id = value; end
            if ~isnan(obj.look_composite_index)
                [value, reader] = reader.text(21, true, false);
                if reader.ok, obj.look_corner_1 = value; end
            end
            if ~isnan(obj.look_composite_index)
                [value, reader] = reader.text(21, true, false);
                if reader.ok, obj.look_corner_2 = value; end
            end
            if ~isnan(obj.look_composite_index)
                [value, reader] = reader.text(21, true, false);
                if reader.ok, obj.look_corner_3 = value; end
            end
            if ~isnan(obj.look_composite_index)
                [value, reader] = reader.text(21, true, false);
                if reader.ok, obj.look_corner_4 = value; end
            end
            [value, reader] = readMarkedNumber(reader, 6, '------', 1, 999999, true);
            if reader.ok, obj.num_volumes = value; end
            [value, reader] = reader.number(6, 1, 999999, ...
                true, false);
            if reader.ok, obj.look_instance = value; end
            [value, reader] = reader.number(6, 1, 999999, ...
                true, false);
            if reader.ok, obj.volume_num = value; end
            [value, reader] = reader.text(6, true, false);
            if reader.ok, obj.sensor_id = value; end
            [value, reader] = reader.text(4, true, false);
            if reader.ok, obj.sensor_id_type = value; end
            [value, reader] = reader.text(3, true, false);
            if reader.ok, obj.mplan = value; end
            [value, reader] = reader.number(3, 0, 999, ...
                true, false);
            if reader.ok, obj.volume_composite_index = value; end
            [count, reader] = reader.count(3, 1, 999);
            [value, reader] = reader.text(count, false, false);
            if reader.ok, obj.volume_composite_id = value; end
            [value, reader] = reader.text(21, true, false);
            if reader.ok, obj.volume_corner_1 = value; end
            [value, reader] = reader.text(21, true, false);
            if reader.ok, obj.volume_corner_2 = value; end
            [value, reader] = reader.text(21, true, false);
            if reader.ok, obj.volume_corner_3 = value; end
            [value, reader] = reader.text(21, true, false);
            if reader.ok, obj.volume_corner_4 = value; end
            [componentsCount, reader] = reader.count(3, 85, 999);
            [value, reader] = reader.number(1, 0, 1, ...
                true, false);
            if reader.ok, obj.components_flag = value; end
            [value, reader] = reader.number(8, 1, 99999999, ...
                true, false);
            if reader.ok, obj.num_rows = value; end
            [value, reader] = reader.number(8, 1, 99999999, ...
                true, false);
            if reader.ok, obj.num_cols = value; end
            [value, reader] = reader.number(7, 1, 9999.99, ...
                false, false);
            if reader.ok, obj.dsr = value; end
            [componentWidth, reader] = reader.number(3, 1, 999, true);
            [componentType, reader] = reader.number(1, 0, 2, true);
            count = componentsCount;
            entries = repmat(newcomponents(), 1, 0);
            for k = 1:count
                [entry, reader] = readcomponents(reader, ...
                    obj.volume_composite_index, componentWidth, componentType);
                if ~reader.ok, break; end
                entries(end + 1) = entry;
            end
            if reader.ok, obj.components = entries; end
            [obj, ok, status] = finishTREDecode( ...
                obj, reader, nfx.MITOCA());
        end
    end
end

function entry = newcomponents() %#codegen
    entry = struct( ...
        'component_index_type', NaN, ...
        'component_id', '', ...
        'ish_index', NaN, ...
        'component_corner_1', '', ...
        'component_corner_2', '', ...
        'component_corner_3', '', ...
        'component_corner_4', '', ...
        'upper_left_row', NaN, ...
        'upper_left_col', NaN, ...
        'upper_right_row', NaN, ...
        'upper_right_col', NaN, ...
        'lower_right_row', NaN, ...
        'lower_right_col', NaN, ...
        'lower_left_row', NaN, ...
        'lower_left_col', NaN);
end

function mustBecomponents(entries) %#codegen
    if ~isstruct(entries) || ~(isrow(entries) || isempty(entries)) || ...
            numel(fieldnames(entries)) ~= 15 || ...
            ~all(isfield(entries, { ...
                'component_index_type', ...
                'component_id', ...
                'ish_index', ...
                'component_corner_1', ...
                'component_corner_2', ...
                'component_corner_3', ...
                'component_corner_4', ...
                'upper_left_row', ...
                'upper_left_col', ...
                'upper_right_row', ...
                'upper_right_col', ...
                'lower_right_row', ...
                'lower_right_col', ...
                'lower_left_row', ...
                'lower_left_col'}))
        error('nfx:TREEntries', 'Supply a row with the defined entry fields.');
    end
    for k = 1:numel(entries)
        entry = entries(k);
        mustBeMetadata(entry.component_index_type, 0, 2, true);
        mustBeAscii(entry.component_id, 999);
        mustBeMetadata(entry.ish_index, 1, 999, true);
        mustBeAscii(entry.component_corner_1, 21);
        mustBeAscii(entry.component_corner_2, 21);
        mustBeAscii(entry.component_corner_3, 21);
        mustBeAscii(entry.component_corner_4, 21);
        mustBeMetadata(entry.upper_left_row, 0, 99999998, true);
        mustBeMetadata(entry.upper_left_col, 0, 99999998, true);
        mustBeMetadata(entry.upper_right_row, 0, 99999998, true);
        mustBeMetadata(entry.upper_right_col, 0, 99999998, true);
        mustBeMetadata(entry.lower_right_row, 0, 99999998, true);
        mustBeMetadata(entry.lower_right_col, 0, 99999998, true);
        mustBeMetadata(entry.lower_left_row, 0, 99999998, true);
        mustBeMetadata(entry.lower_left_col, 0, 99999998, true);
    end
end

function report = validatecomponents(entry, report, reference, context_volume_composite_index) %#codegen
    [~, valid] = treNumber(entry.component_index_type, 1, 0, false, false, false);
    report = addIssue(report, ~valid, 'Encoding', 'component_index_type', ...
        'Supply a value fitting the encoded precision.', reference);
    report = addIssue(report, numel(char(entry.component_id)) < 1, ...
        'Length', 'component_id', 'Supply the required text.', reference);
    if entry.component_index_type ~= 0
        [~, valid] = treNumber(entry.ish_index, 3, 0, false, false, false);
        report = addIssue(report, ~valid, 'Encoding', 'ish_index', ...
            'Supply a value fitting the encoded precision.', reference);
    end
    report = addIssue(report, ~(entry.component_index_type ~= 0) && ~isnan(entry.ish_index), ...
        'AbsentField', 'ish_index', 'Leave the omitted field unset.', reference);
    report = addIssue(report, isempty(strtrim(char(entry.component_corner_1))), ...
        'Required', 'component_corner_1', 'Supply COMPONENT_CORNER_1.', reference);
    report = addIssue(report, isempty(strtrim(char(entry.component_corner_2))), ...
        'Required', 'component_corner_2', 'Supply COMPONENT_CORNER_2.', reference);
    report = addIssue(report, isempty(strtrim(char(entry.component_corner_3))), ...
        'Required', 'component_corner_3', 'Supply COMPONENT_CORNER_3.', reference);
    report = addIssue(report, isempty(strtrim(char(entry.component_corner_4))), ...
        'Required', 'component_corner_4', 'Supply COMPONENT_CORNER_4.', reference);
    if context_volume_composite_index ~= 0
        [~, valid] = treNumber(entry.upper_left_row, 8, 0, false, false, false);
        report = addIssue(report, ~valid, 'Encoding', 'upper_left_row', ...
            'Supply a value fitting the encoded precision.', reference);
    end
    report = addIssue(report, ~(context_volume_composite_index ~= 0) && ~isnan(entry.upper_left_row), ...
        'AbsentField', 'upper_left_row', 'Leave the omitted field unset.', reference);
    if context_volume_composite_index ~= 0
        [~, valid] = treNumber(entry.upper_left_col, 8, 0, false, false, false);
        report = addIssue(report, ~valid, 'Encoding', 'upper_left_col', ...
            'Supply a value fitting the encoded precision.', reference);
    end
    report = addIssue(report, ~(context_volume_composite_index ~= 0) && ~isnan(entry.upper_left_col), ...
        'AbsentField', 'upper_left_col', 'Leave the omitted field unset.', reference);
    if context_volume_composite_index ~= 0
        [~, valid] = treNumber(entry.upper_right_row, 8, 0, false, false, false);
        report = addIssue(report, ~valid, 'Encoding', 'upper_right_row', ...
            'Supply a value fitting the encoded precision.', reference);
    end
    report = addIssue(report, ~(context_volume_composite_index ~= 0) && ~isnan(entry.upper_right_row), ...
        'AbsentField', 'upper_right_row', 'Leave the omitted field unset.', reference);
    if context_volume_composite_index ~= 0
        [~, valid] = treNumber(entry.upper_right_col, 8, 0, false, false, false);
        report = addIssue(report, ~valid, 'Encoding', 'upper_right_col', ...
            'Supply a value fitting the encoded precision.', reference);
    end
    report = addIssue(report, ~(context_volume_composite_index ~= 0) && ~isnan(entry.upper_right_col), ...
        'AbsentField', 'upper_right_col', 'Leave the omitted field unset.', reference);
    if context_volume_composite_index ~= 0
        [~, valid] = treNumber(entry.lower_right_row, 8, 0, false, false, false);
        report = addIssue(report, ~valid, 'Encoding', 'lower_right_row', ...
            'Supply a value fitting the encoded precision.', reference);
    end
    report = addIssue(report, ~(context_volume_composite_index ~= 0) && ~isnan(entry.lower_right_row), ...
        'AbsentField', 'lower_right_row', 'Leave the omitted field unset.', reference);
    if context_volume_composite_index ~= 0
        [~, valid] = treNumber(entry.lower_right_col, 8, 0, false, false, false);
        report = addIssue(report, ~valid, 'Encoding', 'lower_right_col', ...
            'Supply a value fitting the encoded precision.', reference);
    end
    report = addIssue(report, ~(context_volume_composite_index ~= 0) && ~isnan(entry.lower_right_col), ...
        'AbsentField', 'lower_right_col', 'Leave the omitted field unset.', reference);
    if context_volume_composite_index ~= 0
        [~, valid] = treNumber(entry.lower_left_row, 8, 0, false, false, false);
        report = addIssue(report, ~valid, 'Encoding', 'lower_left_row', ...
            'Supply a value fitting the encoded precision.', reference);
    end
    report = addIssue(report, ~(context_volume_composite_index ~= 0) && ~isnan(entry.lower_left_row), ...
        'AbsentField', 'lower_left_row', 'Leave the omitted field unset.', reference);
    if context_volume_composite_index ~= 0
        [~, valid] = treNumber(entry.lower_left_col, 8, 0, false, false, false);
        report = addIssue(report, ~valid, 'Encoding', 'lower_left_col', ...
            'Supply a value fitting the encoded precision.', reference);
    end
    report = addIssue(report, ~(context_volume_composite_index ~= 0) && ~isnan(entry.lower_left_col), ...
        'AbsentField', 'lower_left_col', 'Leave the omitted field unset.', reference);
    report = addIssue(report, ~validLocation21(entry.component_corner_1, true, false, false), ...
        'Metadata', 'component_corner_1', 'Supply a valid geographic corner.', reference);
    report = addIssue(report, ~validLocation21(entry.component_corner_2, true, false, false), ...
        'Metadata', 'component_corner_2', 'Supply a valid geographic corner.', reference);
    report = addIssue(report, ~validLocation21(entry.component_corner_3, true, false, false), ...
        'Metadata', 'component_corner_3', 'Supply a valid geographic corner.', reference);
    report = addIssue(report, ~validLocation21(entry.component_corner_4, true, false, false), ...
        'Metadata', 'component_corner_4', 'Supply a valid geographic corner.', reference);
end

function data = writecomponents(entry, context_volume_composite_index) %#codegen
    data = zeros(1, 0, 'uint8');
    data = [data uint8(char(entry.component_id))];
    if entry.component_index_type ~= 0
        data = [data treNumber(entry.ish_index, 3, 0, false, false, false)];
    end
    data = [data textField(entry.component_corner_1, 21)];
    data = [data textField(entry.component_corner_2, 21)];
    data = [data textField(entry.component_corner_3, 21)];
    data = [data textField(entry.component_corner_4, 21)];
    if context_volume_composite_index ~= 0
        data = [data treNumber(entry.upper_left_row, 8, 0, false, false, false)];
    end
    if context_volume_composite_index ~= 0
        data = [data treNumber(entry.upper_left_col, 8, 0, false, false, false)];
    end
    if context_volume_composite_index ~= 0
        data = [data treNumber(entry.upper_right_row, 8, 0, false, false, false)];
    end
    if context_volume_composite_index ~= 0
        data = [data treNumber(entry.upper_right_col, 8, 0, false, false, false)];
    end
    if context_volume_composite_index ~= 0
        data = [data treNumber(entry.lower_right_row, 8, 0, false, false, false)];
    end
    if context_volume_composite_index ~= 0
        data = [data treNumber(entry.lower_right_col, 8, 0, false, false, false)];
    end
    if context_volume_composite_index ~= 0
        data = [data treNumber(entry.lower_left_row, 8, 0, false, false, false)];
    end
    if context_volume_composite_index ~= 0
        data = [data treNumber(entry.lower_left_col, 8, 0, false, false, false)];
    end
end

function [entry, reader] = readcomponents(reader, context_volume_composite_index, ...
        componentWidth, componentType) %#codegen
    entry = newcomponents();
    if reader.ok, entry.component_index_type = componentType; end
    [value, reader] = reader.text(componentWidth, false);
    if reader.ok, entry.component_id = value; end
    if entry.component_index_type ~= 0
        [value, reader] = reader.number(3, 1, 999, ...
            true, false);
        if reader.ok, entry.ish_index = value; end
    end
    [value, reader] = reader.text(21, true, false);
    if reader.ok, entry.component_corner_1 = value; end
    [value, reader] = reader.text(21, true, false);
    if reader.ok, entry.component_corner_2 = value; end
    [value, reader] = reader.text(21, true, false);
    if reader.ok, entry.component_corner_3 = value; end
    [value, reader] = reader.text(21, true, false);
    if reader.ok, entry.component_corner_4 = value; end
    if context_volume_composite_index ~= 0
        [value, reader] = reader.number(8, 0, 99999998, ...
            true, false);
        if reader.ok, entry.upper_left_row = value; end
    end
    if context_volume_composite_index ~= 0
        [value, reader] = reader.number(8, 0, 99999998, ...
            true, false);
        if reader.ok, entry.upper_left_col = value; end
    end
    if context_volume_composite_index ~= 0
        [value, reader] = reader.number(8, 0, 99999998, ...
            true, false);
        if reader.ok, entry.upper_right_row = value; end
    end
    if context_volume_composite_index ~= 0
        [value, reader] = reader.number(8, 0, 99999998, ...
            true, false);
        if reader.ok, entry.upper_right_col = value; end
    end
    if context_volume_composite_index ~= 0
        [value, reader] = reader.number(8, 0, 99999998, ...
            true, false);
        if reader.ok, entry.lower_right_row = value; end
    end
    if context_volume_composite_index ~= 0
        [value, reader] = reader.number(8, 0, 99999998, ...
            true, false);
        if reader.ok, entry.lower_right_col = value; end
    end
    if context_volume_composite_index ~= 0
        [value, reader] = reader.number(8, 0, 99999998, ...
            true, false);
        if reader.ok, entry.lower_left_row = value; end
    end
    if context_volume_composite_index ~= 0
        [value, reader] = reader.number(8, 0, 99999998, ...
            true, false);
        if reader.ok, entry.lower_left_col = value; end
    end
end

function count = lengthcomponents(entries, context_volume_composite_index) %#codegen
    count = 4;
    for k = 1:numel(entries)
        entry = entries(k);
        count = count + numel(char(entry.component_id)) + ...
            double(entry.component_index_type ~= 0) * (3) + ...
            21 + ...
            21 + ...
            21 + ...
            21 + ...
            double(context_volume_composite_index ~= 0) * (8) + ...
            double(context_volume_composite_index ~= 0) * (8) + ...
            double(context_volume_composite_index ~= 0) * (8) + ...
            double(context_volume_composite_index ~= 0) * (8) + ...
            double(context_volume_composite_index ~= 0) * (8) + ...
            double(context_volume_composite_index ~= 0) * (8) + ...
            double(context_volume_composite_index ~= 0) * (8) + ...
            double(context_volume_composite_index ~= 0) * (8);
    end
end
