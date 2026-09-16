classdef (Sealed) CONTXA < nfx.MetadataWrapper
    %CONTXA - Associate TRE snapshots with explicit NITF/MIE contexts
    %   OBJ = CONTXA(context_type=TYPE,index_list=LIST) + TRE applies TRE
    %   independently to the specified indices. AGGREGATION_MODE='A' applies
    %   eligible metadata to the combined set. IS context requires 'I'.
    %
    %   TYPE is IS, FR, FH, CS, CM, TI, or TB. LIST retains its supplied text,
    %   including optional trailing spaces/comma and a final open range.
    %   For example, '2,4-7,10-' specifies index 2, 4 through 7, and 10 onward.
    %   Nest CONTXA values to specify camera sets, cameras and intervals.
    %   Collection validation resolves actual index bounds and associations.
    %
    %   See also FSYNWA, FASYWA, CAMSDA, MTIMFA

    properties (Constant)
        cetag = 'CONTXA'
    end
    properties
        context_type {mustBeAscii(context_type,2)} = ''
        aggregation_mode {mustBeAscii(aggregation_mode,1)} = 'I'
        index_list {mustBeAscii(index_list,9999)} = ''
    end
    properties (Dependent, SetAccess = private)
        index_list_length
    end
    methods
        function obj = CONTXA(options) %#codegen
            %CONTXA - Construct an editable indexed context
            arguments
                options.?nfx.CONTXA
            end
            if isfield(options,'context_type'), obj.context_type = options.context_type; end
            if isfield(options,'aggregation_mode'), obj.aggregation_mode = options.aggregation_mode; end
            if isfield(options,'index_list'), obj.index_list = options.index_list; end
        end
        function value = get.index_list_length(obj) %#codegen
            %get.index_list_length - Derive the byte length including padding
            value = numel(char(obj.index_list));
        end
        function report = validate(obj) %#codegen
            %VALIDATE - Check context, index grammar, nesting and payload length
            report = newReport('STDI-0002 Appendix AF CONTXA');
            reference = 'STDI-0002-1 Appendix AF, AF5.11-AF5.13 and Tables AF-11 to AF-14';
            typeValid = any(strcmp(obj.context_type,{'IS','FR','FH','CS','CM','TI','TB'}));
            report = addIssue(report,~typeValid,'ContextType','context_type','Supply a defined context type.',reference);
            report = addIssue(report,~any(strcmp(obj.aggregation_mode,{'I','A'})) || ...
                (strcmp(obj.context_type,'IS') && ~strcmp(obj.aggregation_mode,'I')), ...
                'AggregationMode','aggregation_mode','Use I or A; IS context requires I.',reference);
            [valid,~] = contextIndices(obj.index_list,obj.context_type);
            report = addIssue(report,~valid,'IndexList','index_list', ...
                'Use positive indices, ordered ranges, and at most one final open range.',reference);
            report = wrapperReport(obj,report,7+obj.index_list_length);
        end
    end
    methods (Access = protected)
        function value = wrapperPrefix(obj) %#codegen
            %wrapperPrefix - Encode context type, aggregation and exact index text
            value = [textField(obj.context_type,2) textField(obj.aggregation_mode,1) ...
                decimalField(obj.index_list_length,4,0,false) textField(obj.index_list,obj.index_list_length)];
        end
    end
end
