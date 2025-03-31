param (
    [string]$name = "ultrakey_ui.exe",
    [string]$outdir = "$(Split-Path -Path $MyInvocation.MyCommand.Path -Parent)\bin"
)

$out = [System.IO.Path]::GetFileNameWithoutExtension($name)

if (-not (Test-Path $outdir)) {
    New-Item -ItemType Directory -Path $outdir | Out-Null
}

$dir = Split-Path -Path $MyInvocation.MyCommand.Path -Parent
$src = Join-Path $dir "./src/main.py"

Invoke-Expression "pyinstaller --onefile --name $out $src --distpath $outdir --noconfirm --clean"

return Join-Path $outdir $name