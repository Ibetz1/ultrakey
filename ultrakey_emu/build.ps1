param (
    [string]$name = "ultrakey_emu.exe",
    [string]$outdir = "$(Split-Path -Path $MyInvocation.MyCommand.Path -Parent)\bin"
)

$dir = Split-Path -Path $MyInvocation.MyCommand.Path -Parent

if (-not (Test-Path $outdir)) {
    New-Item -ItemType Directory -Path $outdir | Out-Null
}

$src = Join-Path $dir "src/*.cpp"
$inc = Join-Path $dir 'inc'
$out = Join-Path $outdir $name

Invoke-Expression "g++ $src -o $out -I$inc -lViGEmClient -L$dir -lsetupapi -linterception -llua -v"

return $out