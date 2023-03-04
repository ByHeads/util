Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
$ErrorActionPreference = "Stop"
Write-Host -NoNewline "> Uninstalling WPF Client... "
$processFilePath = "C:\ProgramData\Heads\Client\bin\PolyjuiceWindows.exe"
$existingProcess = Get-Process "PolyjuiceWindows" -FileVersionInfo -ErrorAction SilentlyContinue | Where-Object "FileName" -eq $processFilePath
if ($existingProcess) {
    $existingProcess | Stop-Process -Force
    $existingProcess | Wait-Process
    Start-Sleep -Seconds 4
}
rm -r "C:\ProgramData\Heads\Client"
Write-Host "Done!"
