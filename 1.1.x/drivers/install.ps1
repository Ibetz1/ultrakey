if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
    [Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Start-Process powershell "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

$exePath = Join-Path $PSScriptRoot "install-interception.exe"
$out = & $exePath "/install"

if ($out -match "Could not write to") {
    Write-Host "Install failed: please run the fix tool and try again"
    Read-Host "Press enter to continue"
    return
}

$exePath = Join-Path $PSScriptRoot "ViGembus.exe"
& $exePath

Read-Host "Please Restart Your Computer"