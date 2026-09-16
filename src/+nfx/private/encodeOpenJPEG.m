function [bytes,metrics] = encodeOpenJPEG(data,encoder,profile)
    %encodeOpenJPEG - Run the pinned codec with bounded raw-file staging
    if ~ispc, error('nfx:OpenJPEGPlatform','The prototype requires Windows.'); end
    if ~isfile(encoder) || ~endsWith(lower(encoder),'.exe')
        error('nfx:OpenJPEGExecutable','Supply the path to opj_compress.exe version 2.5.4.');
    end
    % Reject shell expansion even inside quotes; accept ordinary space paths.
    encoder = char(java.io.File(encoder).getCanonicalPath());
    quotePath(encoder);
    [~,versionText] = system([quotePath(encoder) ' -h']);
    if ~contains(versionText,'compiled against openjp2 library v2.5.4.')
        error('nfx:OpenJPEGVersion','This prototype requires OpenJPEG 2.5.4.');
    end
    folder = tempname;
    [ok,message] = mkdir(folder);
    if ~ok, error('nfx:OpenJPEGTemporary','%s',message); end
    cleanup = onCleanup(@() rmdir(folder,'s'));
    input = fullfile(folder,'pixels.raw'); output = fullfile(folder,'image.j2k');
    fid = fopen(input,'wb','ieee-be');
    if fid < 0, error('nfx:OpenJPEGTemporary','Cannot create raw input.'); end
    closeInput = onCleanup(@() fclose(fid));
    count = 0;
    for band = 1:size(data,3)
        for first = 1:128:size(data,1)
            block = data(first:min(first+127,size(data,1)),:,band).';
            count = count+fwrite(fid,block,class(data));
        end
    end
    if count ~= numel(data), error('nfx:OpenJPEGTemporary','Incomplete raw input write.'); end
    clear closeInput
    precision = 8+8*isa(data,'uint16');
    targets = [.03125 .0625 .125 .25 .5 .6 .7 .8 .9 1 1.1 1.2 1.3 1.5 1.7 2 2.3 2.8 3.5];
    ratios = [sprintf('%.12g,',precision./targets) '1'];
    progression = 'LRCP'; split = '';
    if strcmp(profile,'EPJE'), progression = 'RLCP'; split = ' -TP R'; end
    command = sprintf('%s -i %s -o %s -F %d,%d,%d,%d,u -r %s -n 6 -b 64,64 -t 1024,1024 -p %s -mct 0 -GuardBits 2 -PLT -TLM -threads 1 -C NFX_OpenJPEG_2.5.4%s', ...
        quotePath(encoder),quotePath(input),quotePath(output),size(data,2),size(data,1),size(data,3), ...
        precision,ratios,progression,split);
    started = tic;
    [status,log] = system(command);
    seconds = toc(started);
    if status ~= 0 || ~isfile(output)
        error('nfx:OpenJPEGEncode','OpenJPEG encoding failed (status %d): %s',status,log);
    end
    fid = fopen(output,'rb');
    if fid < 0, error('nfx:OpenJPEGTemporary','Cannot read encoder output.'); end
    closeOutput = onCleanup(@() fclose(fid));
    bytes = fread(fid,Inf,'*uint8').';
    clear closeOutput
    generated = numel(bytes);
    started = tic;
    bytes = normalizeJPEG2000(bytes,profile);
    metrics = struct('encode_seconds',seconds,'normalize_seconds',toc(started), ...
        'raw_bytes',numel(data)*precision/8,'encoder_bytes',generated, ...
        'codestream_bytes',numel(bytes),'temporary_bytes',numel(data)*precision/8+generated, ...
        'encoder_version','2.5.4','threads',1);
end

function value = quotePath(value)
    %quotePath - Exclude Windows command expansion and control characters
    if any(value < 32) || any(ismember(value,'"%!^&|<>'))
        error('nfx:OpenJPEGPath','Executable and temporary paths must not contain shell metacharacters.');
    end
    value = ['"' value '"'];
end
