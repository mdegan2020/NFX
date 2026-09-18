classdef (Sealed) PIXQLA < nfx.TRE
    %PIXQLA - Pixel quality bit meanings and associated image levels
    %   OBJ = PIXQLA(Name=VALUE) defines PQ_CONDITION in least-significant
    %   bit order. Supply a character matrix or string vector of condition
    %   names, with optional spatial and temporal modifiers. AISDLVL is
    %   a double row of display levels; ALL_IMAGES=true omits that list.
    %
    %   Image-level checks require an unsigned pixel-quality image with
    %   ICAT=PIXQUAL, IREP=NODISPLY, and lossless storage.
    %
    %   See also TRE, ImageSegment

    properties (Constant)
        cetag = 'PIXQLA'
        pq_bit_value = 1
    end
    properties
        aisdlvl {mustBeQualityLevels} = zeros(1, 0)
        all_images {mustBeLogicalScalar} = false
    end
    properties (Dependent)
        pq_condition
    end
    properties (Dependent, SetAccess = private)
        numais
        npixqual
    end
    properties (Access = private)
        conditions = repmat(' ', 64, 40)
        conditionCount = 0
    end
    methods (Static)
        function [obj, ok, status] = deserialize(data) %#codegen
            %deserialize - Decode independently editable pixel quality data
            %   [OBJ, OK, STATUS] = nfx.PIXQLA.deserialize(PAYLOAD)
            %   returns an unset scalar object on failure.
            %
            %   See also PIXQLA, PIXQLA.payload
            arguments
                data
            end
            obj = nfx.PIXQLA();
            reader = nfx.internal.TREReader(data);
            [count, reader] = reader.text(3, false);
            if reader.ok && strcmp(count, 'ALL')
                obj.all_images = true;
            elseif reader.ok
                n = str2double(count);
                if any(count < '0' | count > '9') || ...
                        ~isfinite(n) || n < 1 || n > 998
                    reader = reader.fail('InvalidField', ...
                        'NUMAIS must be ALL or 001..998.');
                else
                    [levels, reader] = reader.numbers( ...
                        n, 3, 1, 999, true, false);
                    if reader.ok, obj.aisdlvl = levels; end
                end
            end
            [n, reader] = reader.count(4, 40, 64);
            reader = reader.literal(uint8('1'));
            [rows, reader] = reader.textRows(40, n, false);
            if reader.ok, obj.pq_condition = rows; end
            [obj, ok, status] = finishTREDecode( ...
                obj, reader, nfx.PIXQLA());
        end
    end
    methods
        function obj = PIXQLA(options) %#codegen
            %PIXQLA - Construct quality conditions and display associations
            arguments
                options.?nfx.PIXQLA
            end
            if isfield(options, 'aisdlvl'), obj.aisdlvl = options.aisdlvl; end
            if isfield(options, 'all_images')
                obj.all_images = options.all_images;
            end
            if isfield(options, 'pq_condition')
                obj.pq_condition = options.pq_condition;
            end
        end
        function obj = set.pq_condition(obj, value) %#codegen
            %set.pq_condition - Store bounded homogeneous condition rows
            rows = metadataRows(value, 40, 64, false);
            obj.conditions(:) = ' ';
            obj.conditionCount = size(rows, 1);
            obj.conditions(1:obj.conditionCount, :) = rows;
        end
        function value = get.pq_condition(obj) %#codegen
            %get.pq_condition - Return the active fixed-width text rows
            value = obj.conditions(1:obj.conditionCount, :);
        end
        function value = get.npixqual(obj) %#codegen
            %get.npixqual - Derive the number of encoded bit conditions
            value = obj.conditionCount;
        end
        function value = get.numais(obj) %#codegen
            %get.numais - Return the encoded three-character count or ALL
            value = 'ALL';
            if ~obj.all_images
                value = char(decimalField(numel(obj.aisdlvl), 3, 0, false));
            end
        end
        function report = validate(obj) %#codegen
            %validate - Check associations and registered condition syntax
            reference = 'STDI-0002-1 Appendix AA, Tables AA-1 through AA-5';
            report = newReport(reference);
            report = addIssue(report, ...
                (obj.all_images && ~isempty(obj.aisdlvl)) || ...
                (~obj.all_images && isempty(obj.aisdlvl)) || ...
                numel(unique(obj.aisdlvl)) ~= numel(obj.aisdlvl), ...
                'AssociatedImages', 'aisdlvl/all_images', ...
                'Supply ALL_IMAGES or distinct associated display levels.', ...
                reference);
            report = addIssue(report, obj.npixqual < 1, ...
                'QualityConditions', 'pq_condition', ...
                'Supply at least one pixel quality condition.', reference);
            for k = 1:obj.npixqual
                report = addIssue(report, ...
                    ~validQualityCondition(strtrim(obj.conditions(k, :))), ...
                    'QualityCondition', 'pq_condition', ...
                    'Use a published case-sensitive condition and modifiers.', ...
                    reference);
                for j = 1:k - 1
                    report = addIssue(report, ...
                        strcmp(obj.conditions(k, :), obj.conditions(j, :)), ...
                        'DuplicateCondition', 'pq_condition', ...
                        'Each bit must describe a distinct condition.', reference);
                end
            end
        end
        function value = payload(obj) %#codegen
            %payload - Encode image associations and ordered bit meanings
            requireValid(obj.validate());
            value = uint8(obj.numais);
            for k = 1:numel(obj.aisdlvl)
                value = [value decimalField(obj.aisdlvl(k), 3, 0, false)]; %#ok<AGROW>
            end
            rows = obj.pq_condition;
            value = [value decimalField(obj.npixqual, 4, 0, false) ...
                uint8('1') reshape(uint8(rows).', 1, [])];
        end
    end
end

function mustBeQualityLevels(value) %#codegen
    %mustBeQualityLevels - Validate storage without silently converting data
    mustBeMetadataArray(value, 1, 999, true);
    if ~(isrow(value) || isequal(size(value), [0 0])) || ...
            numel(value) > 998 || any(isnan(value))
        error('nfx:QualityLevels', ...
            'Supply a double row with at most 998 finite display levels.');
    end
end
