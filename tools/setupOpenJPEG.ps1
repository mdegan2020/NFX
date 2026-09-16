# Obtain the pinned optional Windows codec. Binaries stay in ignored artifacts/.
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$cache = Join-Path $projectRoot 'artifacts\openjpeg'
$archive = Join-Path $cache 'openjpeg-v2.5.4-windows-x64.zip'
$destination = Join-Path $cache '2.5.4'
$executable = Join-Path $destination 'openjpeg-v2.5.4-windows-x64\bin\opj_compress.exe'
$expected = '655f6111449da83f5424f76d74873116bc01ce50cc10361d2b0b4667c3e5e8c3'
New-Item -ItemType Directory -Force -Path $cache | Out-Null
if (-not (Test-Path -LiteralPath $archive)) {
    Invoke-WebRequest -Uri 'https://github.com/uclouvain/openjpeg/releases/download/v2.5.4/openjpeg-v2.5.4-windows-x64.zip' -OutFile $archive
}
if ((Get-FileHash -LiteralPath $archive -Algorithm SHA256).Hash -ne $expected) {
    throw 'OpenJPEG archive SHA-256 mismatch. No executable was installed.'
}
if (-not (Test-Path -LiteralPath $executable)) {
    Expand-Archive -LiteralPath $archive -DestinationPath $destination
}
Write-Output $executable
