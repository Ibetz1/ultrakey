param (
    [string]$out = "$(Split-Path -Path $MyInvocation.MyCommand.Path -Parent)\bin"
)

if (-not (Test-Path $out)) {
    New-Item -ItemType Directory -Path $out | Out-Null
} else {
    Remove-Item -Path $out -Recurse -Force
    New-Item -ItemType Directory -Path $out | Out-Null
}

# packer args
$packer_obf_output_name = "packer.bin"
$packer_obf_ui_name = "ultrakey_ui.exe"
$packer_obf_emu_name = "ultrakey_emu.exe"

# paths
$dir = Split-Path -Path $MyInvocation.MyCommand.Path -Parent
$assets = Join-Path $dir 'ultrakey_ui/assets'
$configs = Join-Path $dir 'configs'
$drivers = Join-Path $dir 'drivers'
$lib = Join-Path $dir 'lib'
$zipped = Join-Path $dir 'ultrakey.zip'

Copy-Item -Path "$assets" -Destination $out -Recurse
Copy-Item -Path "$configs" -Destination $out -Recurse
Copy-Item -Path "$drivers" -Destination $out -Recurse
Copy-Item -Path "$lib\*" -Destination $out -Recurse

$runner = Invoke-Expression ".\ultrakey_run\build.ps1 $out"
$emu_path = Invoke-Expression ".\ultrakey_emu\build.ps1 $packer_obf_emu_name"
$ui_path = Invoke-Expression ".\ultrakey_ui\build.ps1 $packer_obf_ui_name"

Write-Host "finished compiling, starting packing sequence: $runner $emu_path $ui_path" -ForegroundColor Green

Push-Location "$out"
Invoke-Expression "$runner pack $emu_path $ui_path"
Pop-Location

if (Test-Path $zipped) {
    Remove-Item $zipped
}

Compress-Archive -Path "$out" -DestinationPath "$zipped"