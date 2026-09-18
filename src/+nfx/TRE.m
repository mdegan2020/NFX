classdef (Abstract) TRE
    %TRE - Base contract for tagged record extensions
    %   Concrete subclasses provide an editable metadata object, validation,
    %   and a byte payload. Attachment stores a serialized value snapshot.
    %
    %   TRE functions:
    %       validate - Check fields and relationships
    %       payload  - Serialize the payload without its envelope
    %       bytes    - Serialize the complete tagged record
    %
    %   TRE properties:
    %       cetag - Six-character extension identifier
    %       cel   - Payload length in bytes
    %
    %   See also RPC00B, ImageSegment

    properties (Abstract, Constant)
        cetag % Extension identifier
    end
    properties (Dependent, SetAccess = private)
        cel % Derived payload length
    end
    methods (Abstract)
        report = validate(obj)
        bytes = payload(obj)
    end
    methods
        function value = physicalRecords(obj) %#codegen
            %PHYSICALRECORDS - Capture complete physical payload snapshots
            %   VALUE contains tag/payload structs in serialization order.
            %   A concrete TRE may expand one logical attachment into several
            %   records when its standard defines continuation instances.
            data = payload(obj);
            limit = 99985 + 3 * strcmp(obj.cetag, 'SECURA');
            if isempty(data) || numel(data) > limit
                error('nfx:TRELength', 'TRE payload exceeds its supported physical length.');
            end
            value = struct('tag',obj.cetag,'payload',data);
        end
        function value = get.cel(obj) %#codegen
            %get.cel - Derive the payload length
            value = numel(payload(obj));
        end
        function value = bytes(obj) %#codegen
            %BYTES - Serialize the complete tagged record
            %   VALUE = BYTES(OBJ) returns a uint8 row containing the six-byte
            %   tag, five-byte length, and payload. Invalid metadata errors.
            arguments
                obj (1,1) nfx.TRE
            end
            data = payload(obj);
            limit = 99985 + 3 * strcmp(obj.cetag, 'SECURA');
            if isempty(data) || numel(data) > limit
                error('nfx:TRELength', 'TRE payload exceeds its supported physical length.');
            end
            value = [uint8(obj.cetag) decimalField(numel(data), 5, 0, false) data];
        end
    end
end
