# Build a pinned static library for the optional MEX adapter.
param(
    [Parameter(Mandatory = $true)][string]$CompilerRoot,
    [string]$CMake = ''
)
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$cache = Join-Path $projectRoot 'artifacts\openjpeg'
$archive = Join-Path $cache 'openjpeg-2.5.4-source.zip'
$source = Join-Path $cache 'openjpeg-2.5.4'
$build = Join-Path $cache 'static-msvc2022'
$expected = '1048d084b89ac1587e3b0dca00b863a757fed2bc1804c6355eb4bce9090356b7'
New-Item -ItemType Directory -Force -Path $cache | Out-Null
if (-not (Test-Path -LiteralPath $archive)) {
    Invoke-WebRequest -Uri 'https://codeload.github.com/uclouvain/openjpeg/zip/refs/tags/v2.5.4' -OutFile $archive
}
if ((Get-FileHash -LiteralPath $archive -Algorithm SHA256).Hash -ne $expected) {
    throw 'OpenJPEG source archive SHA-256 mismatch.'
}
# Re-extract verified source so a cached source edit cannot alter the build.
Expand-Archive -LiteralPath $archive -DestinationPath $cache -Force
if ($CMake -eq '') {
    $CMake = Join-Path $CompilerRoot 'Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\bin\cmake.exe'
    if (-not (Test-Path -LiteralPath $CMake)) {
        $CMake = (Get-Command cmake -ErrorAction Stop).Source
    }
}
& $CMake -S $source -B $build -G 'Visual Studio 17 2022' -A x64 `
    "-DCMAKE_GENERATOR_INSTANCE=$CompilerRoot" -DBUILD_SHARED_LIBS=OFF `
    -DBUILD_CODEC=OFF -DBUILD_TESTING=OFF -DBUILD_DOC=OFF -DBUILD_JPIP=OFF `
    -DOPJ_USE_THREAD=ON
if ($LASTEXITCODE -ne 0) { throw 'OpenJPEG CMake configuration failed.' }
& $CMake --build $build --config Release --target openjp2 --parallel 2
if ($LASTEXITCODE -ne 0) { throw 'OpenJPEG static library build failed.' }
