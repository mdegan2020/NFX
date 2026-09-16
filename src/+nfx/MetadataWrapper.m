classdef (Abstract, Hidden) MetadataWrapper < nfx.TRE
    %MetadataWrapper - Shared snapshot composition for concrete wrapper TREs
    %   Concrete wrappers use + to capture validated TRE values and
    %   removeTRE to remove an attachment. Ordering is retained exactly;
    %   later metadata therefore retains its standard-defined precedence.
    %
    %   See also FSYNWA, FASYWA, CONTXA

    properties (Dependent, SetAccess = private)
        tre_ids
        tre_tags
        tre_records
    end
    properties (Access = private)
        store = nfx.internal.TREStore()
    end
    methods
        function value = get.tre_ids(obj) %#codegen
            %get.tre_ids - Return logical attachment identities
            value = obj.store.ids;
        end
        function value = get.tre_tags(obj) %#codegen
            %get.tre_tags - Return attached tags in insertion order
            value = obj.store.tags;
        end
        function value = get.tre_records(obj) %#codegen
            %get.tre_records - Inspect encoded value snapshots
            value = obj.store.records;
        end
        function obj = plus(obj,tre) %#codegen
            %PLUS - Snapshot a concrete TRE in this wrapper
            arguments
                obj (1,1) nfx.MetadataWrapper
                tre (1,1) nfx.TRE
            end
            obj.store = obj.store.attach(tre,'wrapped');
        end
        function obj = removeTRE(obj,id) %#codegen
            %REMOVETRE - Remove a logical attachment without reordering others
            arguments
                obj (1,1) nfx.MetadataWrapper
                id {mustBeMetadata(id,1,9007199254740991,1),mustBeFinite}
            end
            obj.store = obj.store.remove(id);
        end
        function value = payload(obj) %#codegen
            %PAYLOAD - Serialize wrapper fields followed by complete TREs
            requireValid(validate(obj));
            value = [wrapperPrefix(obj) wrappedBytes(obj)];
        end
        function value = allowsPlacement(obj,owner) %#codegen
            %ALLOWSPLACEMENT - Check concrete child scopes and context hierarchy
            arguments
                obj (1,1) nfx.MetadataWrapper
                owner {mustBeMember(owner,{'file','image'})}
            end
            value = wrapperLegal(obj.cetag,[wrapperPrefix(obj) wrappedBytes(obj)],owner);
        end
    end
    methods (Access = protected)
        function value = wrappedBytes(obj) %#codegen
            %wrappedBytes - Encode children without padding or an extra count
            [value,~] = obj.store.areas(Inf);
        end
        function report = wrapperReport(obj,report,prefixLength) %#codegen
            %wrapperReport - Check containment length and supported semantics
            records = obj.store.records;
            total = prefixLength;
            largest = 0;
            for k = 1:numel(records)
                total = total+11+numel(records(k).payload);
                largest = max(largest,numel(records(k).payload));
            end
            reference = 'STDI-0002-1 Appendix AF, AF5.9-AF5.13';
            report = addIssue(report,isempty(records),'WrappedTRERequired','tre_ids', ...
                'A wrapper must contain at least one complete TRE.',reference);
            report = addIssue(report,total > 99985,'TRELength','tre_ids', ...
                'Wrapper fields and complete child envelopes must fit 99985 bytes.',reference);
            maximumChild = 99956;
            if strcmp(obj.cetag,'FASYWA'), maximumChild = 99926; end
            report = addIssue(report,largest > maximumChild,'WrappedTRELength','tre_ids', ...
                'A child payload exceeds the wrapper table field limit.',reference);
            if report.valid
                legal = allowsPlacement(obj,'file') || allowsPlacement(obj,'image');
                report = addIssue(report,~legal,'WrapperContext','tre_ids', ...
                    'The wrapped records have no supported legal owner/context combination.',reference);
            end
        end
    end
    methods (Abstract, Access = protected)
        value = wrapperPrefix(obj)
    end
end
