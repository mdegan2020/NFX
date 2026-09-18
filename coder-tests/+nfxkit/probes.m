function values = probes()
    %probes - Enumerate concrete generated entry points and their scope
    names = {'storage', 'rpc', 'timing', 'groups', 'native8', ...
        'native16', 'file8', 'file16', 'mixed'};
    entries = {'nfxCoderStorage', 'nfxCoderRPC', 'nfxCoderTiming', ...
        'nfxCoderGroups', 'nfxCoderNative8', 'nfxCoderNative16', ...
        'nfxCoderFile8', 'nfxCoderFile16', 'nfxCoderMixed'};
    item = struct('name', '', 'entry', '', 'scope', 'core');
    values = repmat(item, 1, numel(names));
    for k = 1:numel(names)
        values(k).name = names{k}; values(k).entry = entries{k};
    end
    values(end).scope = 'mixed-primitive compatibility';
end
