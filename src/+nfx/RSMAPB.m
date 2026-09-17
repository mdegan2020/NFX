classdef (Sealed) RSMAPB < nfx.TRE
    %RSMAPB - Store supplied active RSM parameter adjustments
    %   OBJ = RSMAPB(Name=VALUE) accepts a PARAMETERS value of class
    %   nfx.RSMParameters and a double row PARVAL in its active parameter
    %   order. With a basis matrix, PARVAL is in the new active basis.
    %
    %   IID identifies the original full image. EDITION and TID identify
    %   the support-data edition and latest adjustment/covariance process.
    %   This class does not estimate or apply parameter adjustments.
    %   The published RSMAPB payload limit is 28411 bytes.
    %
    %   See also RSMParameters, RSMDCB, RSMECB, RSMIDA

    properties (Constant)
        cetag = 'RSMAPB'
    end
    properties
        iid {mustBeAscii(iid,80)} = ''
        edition {mustBeAscii(edition,40)} = ''
        tid {mustBeAscii(tid,40)} = ''
        parameters {mustBeRSMParameters} = nfx.RSMParameters()
        parval {mustBeRSMVector} = []
    end
    properties (Dependent, SetAccess = private)
        npar
    end
    methods (Static)
        function [obj, ok, status] = deserialize(data) %#codegen
            %deserialize - Decode an independent editable RSMAPB value
            %   [OBJ, OK, STATUS] = nfx.RSMAPB.deserialize(PAYLOAD)
            %   reads a uint8 row without its tag/length envelope. Failure
            %   returns a default scalar OBJ and a diagnostic STATUS.
            %   Encoded values retain their stored precision.
            %
            %   See also RSMAPB, RSMAPB.payload
            arguments
                data
            end
            obj = nfx.RSMAPB();
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
            [parameters, reader] = readRSMParameters(reader);
            [values, reader] = reader.numbers(parameters.npar, 21, ...
                -9.99999999999999e99, 9.99999999999999e99);
            if reader.ok
                obj.parameters = parameters;
                obj.parval = values;
            end
            [obj, ok, status] = finishTREDecode( ...
                obj, reader, nfx.RSMAPB());
        end
    end
    methods
        function obj = RSMAPB(options) %#codegen
            %RSMAPB - Construct editable RSM adjustments
            arguments
                options.?nfx.RSMAPB
            end
            if isfield(options,'iid'), obj.iid = options.iid; end
            if isfield(options,'edition'), obj.edition = options.edition; end
            if isfield(options,'tid'), obj.tid = options.tid; end
            if isfield(options,'parameters'), obj.parameters = options.parameters; end
            if isfield(options,'parval'), obj.parval = options.parval; end
        end
        function value = get.npar(obj) %#codegen
            %get.npar - Derive the number of active parameter adjustments
            value = obj.parameters.npar;
        end
        function report = validate(obj) %#codegen
            %VALIDATE - Check parameter order, value count and payload size
            [~,report] = encode(obj);
        end
        function value = payload(obj) %#codegen
            %PAYLOAD - Serialize definitions followed by the adjustment vector
            [value,report] = encode(obj);
            requireValid(report);
        end
    end
    methods (Access = private)
        function [value,report] = encode(obj) %#codegen
            %encode - Preserve supplied adjustment order and native doubles
            value = zeros(1,0,'uint8'); report = obj.parameters.validate();
            report = rsmIssue(report,isempty(strtrim(char(obj.edition))) || isempty(strtrim(char(obj.tid))), ...
                'Required','edition/tid','Supply the common RSM edition and adjustment/covariance process identifier.');
            [adjustment,ok] = rsmNumbers(obj.parval,false);
            report = rsmIssue(report,~ok || numel(obj.parval) ~= obj.npar,'AdjustmentVector','parval', ...
                'Supply one known representable value for each active parameter.');
            if ~report.valid, return; end
            definition = obj.parameters.bytes();
            report = rsmIssue(report,160+numel(definition)+numel(adjustment) > 28411, ...
                'AdjustmentLength','parameters/parval','The complete RSMAPB payload must fit the published 28411-byte limit.');
            if ~report.valid, return; end
            value = [textField(obj.iid,80) textField(obj.edition,40) textField(obj.tid,40) definition adjustment];
        end
    end
end
