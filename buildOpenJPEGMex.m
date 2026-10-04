function binary = buildOpenJPEGMex(options)
    %buildOpenJPEGMex - Build the optional Windows in-memory JPEG2000 codec
    %   BINARY = buildOpenJPEGMex downloads verified OpenJPEG 2.5.4 source,
    %   builds a static library, and compiles the NFX MEX adapter into src.
    %   Select Microsoft Visual C++ 2022 with mex -setup C++ first. Install
    %   the Visual Studio CMake tools, or supply CMake=PATH to cmake.exe.
    %   MATLAB R2023b or later is required. No MATLAB path changes are made.
    %
    %   The resulting MEX includes OpenJPEG, so no OpenJPEG DLL or executable
    %   is needed at runtime. Include THIRD_PARTY_NOTICES.md if distributing
    %   the binary. Build inputs remain under ignored artifacts/openjpeg.
    %
    %   See also mex, nfx.JPEG2000
    arguments
        options.CMake {mustBeTextScalar} = ''
    end
    if ~ispc || ~strcmp(computer('arch'), 'win64')
        error('nfx:OpenJPEGPlatform', ...
            'The MEX build requires 64-bit Windows.');
    end
    compiler = mex.getCompilerConfigurations('C++', 'Selected');
    if isempty(compiler) || ~strcmp(compiler.ShortName, 'MSVCPP170')
        error('nfx:OpenJPEGCompiler', ...
            'Select Microsoft Visual C++ 2022 using mex -setup C++.');
    end
    root = fileparts(mfilename('fullpath'));
    script = fullfile(root, 'tools', 'buildOpenJPEG.ps1');
    compilerRoot = regexprep(compiler.Location, '[\\/]+$', '');
    command = ['powershell.exe -NoProfile -ExecutionPolicy Bypass -File ' ...
        quote(script) ' -CompilerRoot ' quote(compilerRoot)];
    if strlength(options.CMake) > 0
        command = [command ' -CMake ' quote(char(options.CMake))];
    end
    [status, output] = system(command);
    fprintf('%s', output);
    if status ~= 0
        error('nfx:OpenJPEGBuild', 'OpenJPEG static library build failed.');
    end
    cache = fullfile(root, 'artifacts', 'openjpeg');
    build = fullfile(cache, 'static-msvc2022');
    destination = fullfile(root, 'src', '+nfx', '+internal');
    clear('nfx.internal.openjpegMex');
    mex('-R2018a', '-DOPJ_STATIC', ...
        ['-I' fullfile(cache, 'openjpeg-2.5.4', 'src', 'lib', 'openjp2')], ...
        ['-I' fullfile(build, 'src', 'lib', 'openjp2')], ...
        fullfile(destination, 'openjpegMex.cpp'), ...
        fullfile(build, 'bin', 'Release', 'openjp2.lib'), ...
        '-outdir', destination, '-output', 'openjpegMex');
    binary = fullfile(destination, ['openjpegMex.' mexext]);
    rehash;
    fprintf('Built %s\n', binary);
end

function value = quote(value)
    if any(value < 32) || any(ismember(value, '"%!^&|<>'))
        error('nfx:OpenJPEGPath', 'Build paths contain shell metacharacters.');
    end
    value = ['"' value '"'];
end
