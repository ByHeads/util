Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
$ErrorActionPreference = "Stop"
Write-Host -NoNewline "> Uninstalling WPF Client... "
$installDir = "C:\ProgramData\Heads\Client";
$processFilePath = "$installDir\bin\PolyjuiceWindows.exe"
$shell = New-Object -ComObject WScript.Shell
$desktopPath = $shell.SpecialFolders("Desktop")
Get-ChildItem "$desktopPath\*.lnk" | % {
    if ($shell.CreateShortcut($_).TargetPath -eq $processFilePath) {
        Remove-Item $_
    }
}
$desktopPath = "$env:Public\Desktop"
Get-ChildItem "$desktopPath\*.lnk" | % {
    if ($shell.CreateShortcut($_).TargetPath -eq $processFilePath) {
        Remove-Item $_
    }
}
$existingProcess = Get-Process "PolyjuiceWindows" -ErrorAction SilentlyContinue | Where { $_.MainModule.FileName -eq $processFilePath }
if ($existingProcess) {
    $existingProcess | Stop-Process -Force
    $existingProcess | Wait-Process
    Start-Sleep -Seconds 4
}
$exists = Test-Path $installDir
rm -r $installDir -ErrorAction SilentlyContinue

if ($exists) {
    if (!(Test-Path "C:\ProgramData\Heads")) { $out = New-Item -Path "C:\ProgramData\Heads" -ItemType Directory }
    echo "$((Get-Date).ToUniversalTime().ToString("yyyyMMddHHmmss") ): UNINSTALLED WPF Client" >> "C:\ProgramData\Heads\install.log"
    Write-Host "Done!"
}
else { Write-Host "No installation found" }
