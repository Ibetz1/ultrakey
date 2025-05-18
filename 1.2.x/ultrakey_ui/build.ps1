param (
    [string]$out = "$(Split-Path -Path $MyInvocation.MyCommand.Path -Parent)\bin"
)

$dir = Split-Path -Path $MyInvocation.MyCommand.Path -Parent

$buildName = "ultrakey_ui.exe"
$buildPath = Join-Path $dir "build/windows/x64/runner/Release"
$assetsPath = Join-Path $dir "assets/"
$configPath = Join-Path $dir "configs/"
$scriptPath = Join-Path $dir "scripts/"

Push-Location $dir
Invoke-Expression "flutter build windows --release --obfuscate --split-debug-info=build/symbols/"
Pop-Location

Invoke-Expression "llvm-strip $buildPath/$buildName"
Invoke-Expression "llvm-strip $buildPath/*.dll"

Remove-Item -Recurse -Force "$out" -ErrorAction Ignore
New-Item -ItemType Directory -Force -Path $out

Copy-Item -Recurse -Force `
  "$buildPath/*" `
  "$out/"

Get-ChildItem -Path $buildPath -Recurse -Include *.lib, *.exp | Remove-Item -Force

Copy-Item -Recurse -Force `
  "$assetsPath" `
  "$out"

Copy-Item -Recurse -Force `
  "$configPath" `
  "$out"

Copy-Item -Recurse -Force `
  "$scriptPath" `
  "$out"

# Copy-Item -Recurse -Force `
#   "$dllPath/*" `
#   "$buildDir/"

# Copy-Item -Recurse -Force `
#   "$driversPath" `
#   "$buildDir"