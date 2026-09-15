classdef (Sealed) FREESA < nfx.TRE
    %FREESA - Free-space bytes in a permitted NITF metadata area
    %   OBJ = FREESA(COUNT) creates COUNT bytes of 0xFF stuffing, where
    %   COUNT is an integer double in [1, 99985]. Edit COUNT before attachment.
    %
    %   See also TRE, File, ImageSegment, TextSegment

    properties (Constant)
        cetag = 'FREESA'
    end
    properties
        count {mustBeMetadata(count, 1, 99985, 1), mustBeFinite} = 1
    end
    methods
        function obj = FREESA(count) %#codegen
            %FREESA - Construct a stuffing record
            arguments
                count = 1
            end
            obj.count = count;
        end
        function report = validate(~) %#codegen
            %VALIDATE - Report valid stuffing metadata
            report = newReport('STDI-0002 Appendix AF FREESA');
        end
        function value = payload(obj) %#codegen
            %PAYLOAD - Encode the STUFFING field as 0xFF bytes
            value = repmat(uint8(255), 1, obj.count);
        end
    end
end
