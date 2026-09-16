classdef (Sealed) HISTOA < nfx.TRE
    %HISTOA - Chronological history of supplied image processing events
    %   OBJ = HISTOA(systype=SYSTEM,event=EVENTS) records one to 99
    %   HistoryEvent values. Counts and lengths derive from the event array.
    %   The caller supplies actual history; NFX does not invent processing.
    %
    %   PC contains up to three four-character compression codes followed by
    %   zero groups. REMAP_FLAG=NaN encodes a blank for inapplicable systems.
    %   Use the registered sensor identifier or TBD when the system is Other.
    %
    %   See also HistoryEvent, CSDIDA, ACFTB

    properties (Constant)
        cetag = 'HISTOA'
    end
    properties
        systype {mustBeAscii(systype,20)} = ''
        pc {mustBeAscii(pc,12)} = 'UNKC00000000'
        pe {mustBeAscii(pe,4)} = 'UNKP'
        remap_flag {mustBeMetadata(remap_flag,0,1,1)} = NaN
        lutid {mustBeMetadata(lutid,0,64,1)} = 0
        event {mustBeEvents} = nfx.HistoryEvent.empty(1,0)
    end
    properties (Dependent, SetAccess = private)
        nevents
    end
    methods
        function obj = HISTOA(options) %#codegen
            %HISTOA - Construct an editable processing history
            arguments
                options.?nfx.HISTOA
            end
            if isfield(options,'systype'), obj.systype = options.systype; end
            if isfield(options,'pc'), obj.pc = options.pc; end
            if isfield(options,'pe'), obj.pe = options.pe; end
            if isfield(options,'remap_flag'), obj.remap_flag = options.remap_flag; end
            if isfield(options,'lutid'), obj.lutid = options.lutid; end
            if isfield(options,'event'), obj.event = options.event; end
        end
        function value = get.nevents(obj) %#codegen
            %get.nevents - Derive the number of chronological events
            value = numel(obj.event);
        end
        function report = validate(obj) %#codegen
            %VALIDATE - Check history codes, events, chronology and continuity
            report = newReport('STDI-0002 Appendix L HISTOA');
            reference = 'STDI-0002-1 Appendix L, L.4 and Tables L-1 to L-4';
            report = addIssue(report,~systemCode(obj.systype),'SystemType','systype', ...
                'Supply a published system code, a derived NCDRD identifier, or TBD.',reference);
            [valid,~] = historyCompression(obj.pc,true);
            report = addIssue(report,~valid,'PriorCompression','pc','Supply published four-byte codes and trailing zero groups.',reference);
            report = addIssue(report,~any(strcmp(obj.pe,{'EH08','EH11','UE08','UE11','DGHC','UNKP','NONE','GEOR','ORTH'})), ...
                'PriorEnhancement','pe','Supply a published prior-enhancement code.',reference);
            report = addIssue(report,~any(obj.lutid == [0 7 8 11:64]),'DataMapping','lutid', ...
                'Use 0, 7, 8, or 11 to 64; other values are reserved.',reference);
            report = addIssue(report,obj.nevents < 1 || obj.nevents > 99,'EventCount','event', ...
                'Supply 1 to 99 chronological processing events.',reference);
            count = 41;
            for k = 1:obj.nevents
                item = obj.event(k);
                report = mergeReport(report,validate(item),sprintf('event(%d).',k));
                count = count+item.byte_count;
                if k > 1
                    previous = obj.event(k-1);
                    if knownDate(item.pdate,14) && knownDate(previous.pdate,14)
                        report = addIssue(report,mieTimeEarlier(item.pdate,previous.pdate), ...
                            'EventOrder',sprintf('event(%d).pdate',k),'Events must remain in chronological order.',reference);
                    end
                    report = addIssue(report,item.ibpp ~= previous.obpp || ...
                        ~strcmp(strtrim(char(item.ipvtype)),strtrim(char(previous.opvtype))), ...
                        'HistoryContinuity',sprintf('event(%d)',k), ...
                        'Each event input representation must match the previous output.',reference);
                end
            end
            report = addIssue(report,count > 83512,'TRELength','event','The HISTOA payload must fit its specified size limit.',reference);
        end
        function value = payload(obj) %#codegen
            %PAYLOAD - Serialize header and events in supplied chronological order
            requireValid(validate(obj));
            counts = [obj.event.byte_count];
            value = zeros(1,41+sum(counts),'uint8');
            value(1:41) = [textField(obj.systype,20) textField(obj.pc,12) textField(obj.pe,4) ...
                blankDecimal(obj.remap_flag,1,0,false) decimalField(obj.lutid,2,0,false) decimalField(obj.nevents,2,0,false)];
            at = 41;
            for k = 1:obj.nevents
                value(at+1:at+counts(k)) = bytes(obj.event(k));
                at = at+counts(k);
            end
        end
    end
end

function mustBeEvents(value) %#codegen
    %mustBeEvents - Require a row of concrete event values without reshaping
    if ~isa(value,'nfx.HistoryEvent') || ~(isrow(value) || isempty(value))
        error('nfx:HistoryEvents','Supply a row array of nfx.HistoryEvent values.');
    end
end

function valid = systemCode(value) %#codegen
    %systemCode - Recognize published system identifiers and NCDRD codes
    value = strtrim(char(value));
    valid = any(strcmp(value,{'ALIRT','ASARS-2','BUCKEY','GHR','GORGON STARE','HALOE','JAUDIT', ...
        'MULTIPLE_EO','MULTIPLE_MS','MULTIPLE_SAR','OPEN_SKIES','SYERS-EO','SYERS-MSI','SYERS-IR','DSR','TSAR','TBD'}));
    if numel(value) ~= 6, return; end
    valid = valid || (any(strcmp(value(1:2),{'DC','DR','DS','GE','GL','IK','LG','OV','QB','SK','WV','HP','GT','9I','AU'})) && ...
        all(value(3:4) >= '0' & value(3:4) <= '9') && ...
        any(strcmp(value(5:6),{'AA','CA','EO','GA','HO','HP','IR','LW','MW','NA','NR','SW','UV','VN','VS'})));
    if strcmp(value(1:2),'OV') && strcmp(value(3:4),'00'), valid = false; end
end
