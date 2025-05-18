$exePath = Join-Path $PSScriptRoot "install-interception.exe"
& $exePath "/uninstall"
& $exePath "/install"

Read-Host "Please restart your Computer and retry your installation. If the issue persists please contact UltraKey support."