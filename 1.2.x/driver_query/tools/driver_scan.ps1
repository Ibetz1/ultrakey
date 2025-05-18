$knownDriverHashes = @(
    "0F12D47D01864CA5E1EB663A52B3D2C060521E57B68FF99D70E7F01506E400F9"
    "2CB5EC142CFAC879BCE4A2F9549258DB972AEBBD24F4551B6B748B464EB7DBA9"
    "B6D6FA5CA8334368FC366A3E78552EFB74EEF657061371B2DE407AA158B0A11C"
)

$driverFolder = "C:\Windows\System32\drivers"

Write-Host "=== Scanning all drivers in $driverFolder ===`n"

$files = Get-ChildItem -Path $driverFolder -Filter "*.sys" -Recurse

foreach ($file in $files) {
    try {
        $hashObj = Get-FileHash -Path $file.FullName -Algorithm SHA256
        $hash = $hashObj.Hash.ToUpper()

        if ($knownDriverHashes -contains $hash) {
            Write-Host "   File: $($file.FullName)"
            Write-Host "   SHA256: $hash`n" -ForegroundColor Green
        }
        else {
        }
    }
    catch {
        Write-Host "⚠️ Could not hash $($file.FullName): $_" -ForegroundColor Yellow
    }
}