function [payload, comrat, ok] = jpeg2000Metadata(profile, bands, samples, bytes)
    %jpeg2000Metadata - Derive original lossless layer targets and bitrate
    payload = zeros(1, 0, 'uint8'); comrat = '';
    rate = 8 * bytes / samples;
    ok = isfinite(rate) && rate > 0 && rate <= 37;
    if ~ok, return, end
    comrat = sprintf('N%03.0f', round(10 * rate));
    targets = [.03125 .0625 .125 .25 .5 .6 .7 .8 .9 1 ...
               1.1 1.2 1.3 1.5 1.7 2 2.3 2.8 3.5 rate];
    payload = uint8(sprintf('%1d05%05d020', ...
        2 * strcmp(profile, 'EPJE'), bands));
    for k = 1:20
        payload = [payload uint8(sprintf('%03d%09.6f', k - 1, targets(k)))]; %#ok<AGROW>
    end
end
