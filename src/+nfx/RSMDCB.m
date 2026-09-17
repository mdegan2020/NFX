classdef (Sealed) RSMDCB < nfx.TRE
    %RSMDCB - Store direct RSM covariance blocks in supplied image order
    %   OBJ = RSMDCB(Name=VALUE) accepts a row of BLOCKS constructed with
    %   nfx.RSMDCB.block(IIDI,CRSCOV). CRSCOV is a double matrix with one
    %   row per active parameter of IID and one column per active parameter
    %   of IIDI. All blocks share a row count. Column counts may differ.
    %
    %   PARAMETERS optionally supplies an nfx.RSMParameters value. An
    %   empty value omits that definition. Complete-set validation requires
    %   one definition and one auto-covariance block across the RSMDCB
    %   instances for each image. Blocks cannot be repeated within a set.
    %
    %   Auto-covariance matrices must be symmetric positive semidefinite.
    %   Cross-covariance matrices need not be symmetric. Complete multi-
    %   image covariance checks require the other referenced image sets.
    %   Each instance must fit 99985 bytes; blocks remain indivisible.
    %
    %   See also RSMParameters, RSMAPB, RSMECB, RSMIDA

    properties (Constant)
        cetag = 'RSMDCB'
    end
    properties
        iid {mustBeAscii(iid,80)} = ''
        edition {mustBeAscii(edition,40)} = ''
        tid {mustBeAscii(tid,40)} = ''
        parameters {mustBeOptionalRSMParameters} = nfx.RSMParameters.empty(1,0)
        blocks {mustBeCovarianceBlocks} = struct('iidi',{},'crscov',{})
    end
    properties (Dependent, SetAccess = private)
        nrowcb
        nimge
        incapd
    end
    methods (Static)
        function [obj, ok, status] = deserialize(data) %#codegen
            %deserialize - Decode an independent editable RSMDCB value
            %   [OBJ, OK, STATUS] = nfx.RSMDCB.deserialize(PAYLOAD)
            %   reads a uint8 row without its tag/length envelope. Failure
            %   returns a default scalar OBJ and a diagnostic STATUS.
            %   Encoded values retain their stored precision.
            %
            %   See also RSMDCB, RSMDCB.payload
            arguments
                data
            end
            obj = nfx.RSMDCB();
            reader = nfx.internal.TREReader(data);
            [value, reader] = reader.text(80, true, false);
            if reader.ok
                obj.iid = value;
            end
            [value, reader] = reader.text(40, true, false);
            if reader.ok
                obj.edition = value;
            end
            [value, reader] = reader.text(40, true, false);
            if reader.ok
                obj.tid = value;
            end
            [rows, reader] = reader.number(2, 1, 36, true);
            [count, reader] = reader.count(3, 82, 999);
            blocks = repmat(struct('iidi', '', 'crscov', []), 1, count);
            columns = zeros(1, count);
            for k = 1:count
                [blocks(k).iidi, reader] = reader.text(80);
                [columns(k), reader] = reader.number(2, 1, 36, true);
            end
            [included, reader] = reader.choice('YN');
            if strcmp(included, 'Y')
                [parameters, reader] = readRSMParameters(reader);
                if reader.ok
                    obj.parameters = parameters;
                end
            end
            for k = 1:count
                [values, reader] = reader.numbers(rows * columns(k), 21, ...
                    -9.99999999999999e99, 9.99999999999999e99);
                if reader.ok
                    blocks(k).crscov = reshape(values, columns(k), rows).';
                end
            end
            if reader.ok
                obj.blocks = blocks;
            end
            [obj, ok, status] = finishTREDecode( ...
                obj, reader, nfx.RSMDCB());
        end
    end
    methods
        function obj = RSMDCB(options) %#codegen
            %RSMDCB - Construct editable direct covariance blocks
            arguments
                options.?nfx.RSMDCB
            end
            if isfield(options,'iid'), obj.iid = options.iid; end
            if isfield(options,'edition'), obj.edition = options.edition; end
            if isfield(options,'tid'), obj.tid = options.tid; end
            if isfield(options,'parameters'), obj.parameters = options.parameters; end
            if isfield(options,'blocks'), obj.blocks = options.blocks; end
        end
        function value = get.nrowcb(obj) %#codegen
            %get.nrowcb - Derive the associated image's active parameter count
            value = 0;
            if ~isempty(obj.blocks), value = size(obj.blocks(1).crscov,1); end
        end
        function value = get.nimge(obj) %#codegen
            %get.nimge - Derive the number of covariance blocks
            value = numel(obj.blocks);
        end
        function value = get.incapd(obj) %#codegen
            %get.incapd - Derive whether parameter definitions are included
            if isempty(obj.parameters), value = 'N'; else, value = 'Y'; end
        end
        function report = validate(obj) %#codegen
            %VALIDATE - Check dimensions, identifiers and auto-covariances
            [~,report] = encode(obj);
        end
        function value = payload(obj) %#codegen
            %PAYLOAD - Serialize the image directory and row-major matrices
            [value,report] = encode(obj);
            requireValid(report);
        end
    end
    methods (Static)
        function value = block(iidi,crscov) %#codegen
            %BLOCK - Construct one covariance block for the named image
            arguments
                iidi
                crscov
            end
            value = struct('iidi',iidi,'crscov',crscov);
            mustBeCovarianceBlocks(value);
        end
    end
    methods (Access = private)
        function [value,report] = encode(obj) %#codegen
            %encode - Preserve indivisible blocks and avoid oversized buffers
            value = zeros(1,0,'uint8'); report = newReport('RSM direct covariance');
            report = rsmIssue(report,isempty(strtrim(char(obj.edition))) || isempty(strtrim(char(obj.tid))), ...
                'Required','edition/tid','Supply the common RSM edition and adjustment/covariance process identifier.');
            report = rsmIssue(report,obj.nimge < 1,'CovarianceCount','blocks','Supply at least one covariance block.');
            definition = zeros(1,0,'uint8');
            if ~isempty(obj.parameters)
                report = mergeReport(report,obj.parameters.validate(),'parameters');
                report = rsmIssue(report,obj.parameters.npar ~= obj.nrowcb,'ParameterCount','parameters', ...
                    'The active parameter count must match each covariance block row dimension.');
                if report.valid, definition = obj.parameters.bytes(); end
            end
            names = repmat(' ',obj.nimge,80); elementCount = 0;
            for k = 1:obj.nimge
                item = obj.blocks(k); names(k,:) = char(textField(item.iidi,80));
                elementCount = elementCount+numel(item.crscov);
                report = rsmIssue(report,isempty(strtrim(char(item.iidi))) || ...
                    size(item.crscov,1) ~= obj.nrowcb,'CovarianceBlock','blocks', ...
                    'Each block needs a known image identifier and the common row dimension.');
            end
            report = rsmIssue(report,size(unique(names,'rows'),1) ~= obj.nimge,'DuplicateCovariance','blocks', ...
                'An image pair may occur only once in a direct-covariance set.');
            length = 166+82*obj.nimge+numel(definition)+21*elementCount;
            report = rsmIssue(report,length > 99985,'CovarianceLength','blocks', ...
                'Supply fewer whole blocks in each RSMDCB instance to fit 99985 bytes.');
            if ~report.valid, return; end
            value = zeros(1,length,'uint8');
            value(1:165) = [textField(obj.iid,80) textField(obj.edition,40) textField(obj.tid,40) ...
                uint8(sprintf('%02.0f%03.0f',obj.nrowcb,obj.nimge))];
            at = 165;
            for k = 1:obj.nimge
                value(at+(1:82)) = [uint8(names(k,:)) uint8(sprintf('%02.0f',size(obj.blocks(k).crscov,2)))]; at = at+82;
            end
            value(at+1) = uint8(obj.incapd); at = at+1;
            value(at+(1:numel(definition))) = definition; at = at+numel(definition);
            associatedID = char(textField(obj.iid,80));
            for k = 1:obj.nimge
                covariance = obj.blocks(k).crscov;
                [matrixBytes,ok,rounded] = rsmNumbers(covariance',false);
                report = rsmIssue(report,~ok,'CovarianceElement','crscov', ...
                    'All covariance elements must be known and representable.');
                if strcmp(names(k,:),associatedID)
                    report = rsmIssue(report,~rsmCovariance(covariance) || ~rsmCovariance(rounded'), ...
                        'AutoCovariance','crscov','Auto-covariance blocks must be symmetric positive semidefinite before and after encoding.');
                end
                value(at+(1:numel(matrixBytes))) = matrixBytes; at = at+numel(matrixBytes);
            end
        end
    end
end

function mustBeCovarianceBlocks(value) %#codegen
    %mustBeCovarianceBlocks - Require concrete matrices paired with image IDs
    if ~isstruct(value) || ~(isrow(value) || isempty(value)) || numel(value) > 999 || ...
            ~all(isfield(value,{'iidi','crscov'})) || numel(fieldnames(value)) ~= 2
        error('nfx:RSMCovarianceBlocks','Supply up to 999 iidi/crscov row structs.');
    end
    for k = 1:numel(value)
        mustBeAscii(value(k).iidi,80); mustBeRSMMatrix(value(k).crscov,36,36);
    end
end
