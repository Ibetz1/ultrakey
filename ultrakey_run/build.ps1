param (
    [string]$outdir = "$(Split-Path -Path $MyInvocation.MyCommand.Path -Parent)\bin",
    [string]$name = "ultrakey_runner.exe"
)

if (-not (Test-Path $outdir)) {
    New-Item -ItemType Directory -Path $outdir | Out-Null
}

$dir = Split-Path -Path $MyInvocation.MyCommand.Path -Parent
$src = Join-Path $dir "./src/*.cpp"
$inc = Join-Path $dir 'inc'
$out = Join-Path $outdir $name

Invoke-Expression "g++ -std=c++20 -O2 -s $src -I$inc -o$out -liphlpapi -ladvapi32"

return $out