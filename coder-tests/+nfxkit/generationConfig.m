function [cfg, settings] = generationConfig(phase)
    %generationConfig - Use explicit heap and extrinsic settings for each phase
    kind = 'lib'; if strcmp(phase, 'mex'), kind = 'mex'; end
    cfg = coder.config(kind);
    cfg.TargetLang = 'C';
    if endsWith(phase, 'cpp'), cfg.TargetLang = 'C++'; end
    cfg.EnableVariableSizing = true;
    cfg.EnableDynamicMemoryAllocation = ~startsWith(phase, 'noheap');
    cfg.DynamicMemoryAllocationThreshold = 65536;
    cfg.GenerateReport = true; cfg.LaunchReport = false;
    if strcmp(kind, 'mex')
        cfg.EnableAutoExtrinsicCalls = false;
        cfg.ExtrinsicCalls = false;
    end
    settings = struct('kind', kind, 'language', cfg.TargetLang, ...
        'variableSizing', cfg.EnableVariableSizing, ...
        'dynamicMemoryAllocation', cfg.EnableDynamicMemoryAllocation, ...
        'dynamicMemoryThreshold', cfg.DynamicMemoryAllocationThreshold, ...
        'generateReport', cfg.GenerateReport, 'launchReport', cfg.LaunchReport, ...
        'extrinsicCalls', false, 'autoExtrinsicCalls', false, ...
        'sourceGenerationOnly', ~strcmp(kind, 'mex'));
end
