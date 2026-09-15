function observations = measureMemory(side)
    %measureMemory - Observe process memory during representative NFX operations
    %   OBSERVATIONS = measureMemory uses an 8192-by-8192 uint16 image, records
    %   pre/post operation process memory, and deletes its temporary NITF.
    %
    %   OBSERVATIONS = measureMemory(SIDE) uses the specified square image size.
    %   Measurements require Windows MATLAB and can miss transient allocations.
    %   This is an observation tool, not a portable memory ceiling assertion.
    %
    %   See also memory, runTests
    arguments
        side (1,1) double {mustBeInteger,mustBePositive} = 8192
    end
    root = fileparts(fileparts(mfilename('fullpath')));
    previous = path;
    paths = onCleanup(@() path(previous));
    addpath(fullfile(root,'src'),fullfile(root,'tests','helpers'));
    filename = [tempname '.ntf'];
    cleanup = onCleanup(@() removeFile(filename));
    [warm,~,~] = fixtureFile();
    warm.write(filename);
    baseline = memory().MemUsedMATLAB;
    pixels = repmat(uint16(0:side-1),side,1);
    allocated = memory().MemUsedMATLAB;
    image = nfx.ImageSegment(pixels);
    attached = memory().MemUsedMATLAB;
    image.header = nfx.ImageHeader(iid1='MEMORY',idatim='20260915120000', ...
        isclas='U',irep='MONO',icat='VIS');
    image = image+fixtureRPC();
    metadata = memory().MemUsedMATLAB;
    file = nfx.File(header=warm.header)+image;
    composed = memory().MemUsedMATLAB;
    report = file.validate();
    assert(report.valid);
    validated = memory().MemUsedMATLAB;
    timer = tic;
    file.write(filename,Overwrite=true);
    elapsed = toc(timer);
    written = memory().MemUsedMATLAB;
    assert(isequal(file.images(1).data,pixels));
    phases = {'baseline';'allocate pixels';'attach pixels';'metadata and TRE'; ...
        'compose file';'validate';'write'};
    bytes = [baseline;allocated;attached;metadata;composed;validated;written];
    observations = table(phases,bytes,[0;diff(bytes)], ...
        VariableNames={'Phase','ProcessBytes','DeltaBytes'});
    disp(observations);
    fprintf('Image bytes: %d; output bytes: %d; write seconds: %.3f\n', ...
        numel(pixels)*2,file.header.fl,elapsed);
end

function removeFile(filename)
    %removeFile - Remove the owned temporary memory-probe output
    if isfile(filename), delete(filename); end
end
