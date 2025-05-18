if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
    [Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Start-Process powershell "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

$exePath = Join-Path $PSScriptRoot "install-interception.exe"
& $exePath "/uninstall"

$exePath = Join-Path $PSScriptRoot "ViGembus.exe"
& $exePath

Read-Host "Please Restart Your Computer"