param (
    [string]$name = "driver_tools.dll",
    [string]$outdir = "$(Split-Path -Path $MyInvocation.MyCommand.Path -Parent)\bin"
)

$dir = Split-Path -Path $MyInvocation.MyCommand.Path -Parent

if (-not (Test-Path $outdir)) {
    New-Item -ItemType Directory -Path $outdir | Out-Null
}

$src = Join-Path $dir "src/*.cpp"
$out = Join-Path $outdir $name

# Invoke-Expression "g++ -shared -fPIC $src -o `"$out`" -I`"$inc`" -L`"$dir`" -lViGEmClient -lsetupapi -linterception -llua"
Invoke-Expression "g++ -shared -o $out $src -lShell32 -lAdvapi32 -lCrypt32 -v"