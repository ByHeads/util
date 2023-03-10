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
$existingProcess = Get-Process "PolyjuiceWindows" -ErrorAction SilentlyContinue | Where { $_.MainModule.FileName -eq $processFilePath }
if ($existingProcess) {
    $existingProcess | Stop-Process -Force
    $existingProcess | Wait-Process
    Start-Sleep -Seconds 4
}
$exists = Test-Path $installDir
rm -r $installDir -ErrorAction SilentlyContinue
Write-Host ($exists ? "Done!" : "No installation found")
