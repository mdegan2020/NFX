classdef SyntheticTRE < nfx.TRE
    %SyntheticTRE - Test the abstract envelope contract with binary content
    properties (Constant)
        cetag = 'BINARY'
    end
    properties
        content
    end
    methods
        function obj = SyntheticTRE(content)
            obj.content = content;
        end
        function report = validate(~)
            report = struct('valid',true);
        end
        function value = payload(obj)
            value = obj.content;
        end
    end
end
