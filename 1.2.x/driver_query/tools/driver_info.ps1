(Get-Item "C:\Windows\System32\drivers\mouse.sys").VersionInfo | Format-List
(Get-Item "C:\Windows\System32\drivers\keyboard.sys").VersionInfo | Format-List

$path = "C:\Windows\System32\drivers\mouse.sys"
$hash = Get-FileHash $path -Algorithm SHA256
$info = (Get-Item $path).VersionInfo

[PSCustomObject]@{
    File = $path
    SHA256 = $hash.Hash
    FileVersion = $info.FileVersion
    ProductVersion = $info.ProductVersion
    LinkDate = (Get-Item $path).LastWriteTimeUtc
}

$path = "C:\Windows\System32\drivers\keyboard.sys"
$hash = Get-FileHash $path -Algorithm SHA256
$info = (Get-Item $path).VersionInfo

[PSCustomObject]@{
    File = $path
    SHA256 = $hash.Hash
    FileVersion = $info.FileVersion
    ProductVersion = $info.ProductVersion
    LinkDate = (Get-Item $path).LastWriteTimeUtc
}

$path = "C:\WINDOWS\system32\drivers\ViGEmBus.sys"
$hash = Get-FileHash $path -Algorithm SHA256
$info = (Get-Item $path).VersionInfo

[PSCustomObject]@{
    File = $path
    SHA256 = $hash.Hash
    FileVersion = $info.FileVersion
    ProductVersion = $info.ProductVersion
    LinkDate = (Get-Item $path).LastWriteTimeUtc
}