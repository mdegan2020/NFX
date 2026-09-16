function info = inspectJPEG2000(data,profile)
    %inspectJPEG2000 - Validate the bounded BPJ2K01.20 lossless configuration
    info = parseJPEG2000(data);
    epje = strcmp(profile,'EPJE');
    check(info.rsiz == 2,'Expected JPEG 2000 Profile-1.');
    check(all(info.tile_size == 1024) && all(info.offsets == 0),'Expected aligned 1024-square tiles.');
    check(any(info.precision == [8 16]),'Expected unsigned native 8/16-bit precision.');
    check(isequal(info.cod,[0 double(epje) 0 20 0 5 4 4 0 1]), ...
        'Expected 20 layers, six resolutions, maximal precincts, 64-square blocks and reversible coding.');
    expectedQCD = [64 8*info.precision 8*repmat(info.precision+[1 1 2],1,5)];
    check(isequal(info.qcd,expectedQCD), ...
        'Expected two guard bits and unquantized reversible subbands.');
    tileCount = prod(ceil(info.dimensions(1:2)/1024));
    check(tileCount <= 65535,'Too many tiles.');
    partsPerTile = 1+5*epje;
    check(numel(info.parts) == tileCount*partsPerTile,'Wrong number of tile-parts.');
    expectedTiles = repmat(0:tileCount-1,1,partsPerTile);
    expectedParts = repelem(0:partsPerTile-1,tileCount);
    check(isequal([info.parts.tile],expectedTiles) && isequal([info.parts.index],expectedParts) && ...
        all([info.parts.count] == partsPerTile),'Incorrect physical tile-part ordering.');
    check(all(info.tlm_style == 64+32*epje),'Incorrect profile TLM entry format.');
    check(epje || isscalar(info.tlm_style),'The NPJE prototype requires one TLM.');
    if epje, check(all([info.parts.plt_count] == 1),'EPJE requires one PLT per tile-part.'); end
    packetCount = arrayfun(@(part) numel(part.packet_lengths),info.parts);
    check(all(packetCount == 20*info.dimensions(3)*(6-5*epje)), ...
        'Packet count disagrees with layers, resolutions and components.');
    info.profile = profile;
    info.layers = 20; info.resolutions = 6; info.tile_count = tileCount;
end

function check(ok,message)
    if ~ok, error('nfx:JPEG2000Profile','%s',message); end
end
