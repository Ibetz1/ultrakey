param (
    [string]$name = "ultrakey_emu.dll",
    [string]$outdir = "$(Split-Path -Path $MyInvocation.MyCommand.Path -Parent)\bin"
)

$dir = Split-Path -Path $MyInvocation.MyCommand.Path -Parent

if (-not (Test-Path $outdir)) {
    New-Item -ItemType Directory -Path $outdir | Out-Null
}

$src = Join-Path $dir "src/*.cpp"
$inc = Join-Path $dir 'inc'
$out = Join-Path $outdir $name

Invoke-Expression "g++ -shared -fPIC $src -o `"$out`" -I`"$inc`" -L`"$dir`" -lViGEmClient -lsetupapi -linterception -llua -v"
# Invoke-Expression "g++ dlltest/*.cpp -o bin/dlltest.exe"

return $out