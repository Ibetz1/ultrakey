param (
    [string]$out = "$(Split-Path -Path $MyInvocation.MyCommand.Path -Parent)\bin"
)

if (-not (Test-Path $out)) {
    New-Item -ItemType Directory -Path $out | Out-Null
} else {
    Remove-Item -Path $out -Recurse -Force
    New-Item -ItemType Directory -Path $out | Out-Null
}

$emu_build = "./ultrakey_emu/builddll.ps1"
$driver_build = "./driver_query/builddll.ps1"
$ui_build = "./ultrakey_ui/build.ps1"

$driver_installers_path = "./drivers"
$emu_output_path = "./ultrakey_emu/bin"
$driver_output_path = "./driver_query/bin"
$ui_output_path = "./ultrakey_ui/bin"

Invoke-Expression $emu_build
Invoke-Expression $driver_build
Invoke-Expression $ui_build

Copy-Item -Recurse -Force `
    "$emu_output_path/*.dll" `
    "$out"

Copy-Item -Recurse -Force `
    "$driver_output_path/*.dll" `
    "$out"

Copy-Item -Recurse -Force `
    "$driver_installers_path" `
    "$out"

Copy-Item -Recurse -Force `
    "$ui_output_path/*" `
    "$out"