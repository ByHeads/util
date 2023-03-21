Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
$ErrorActionPreference = "Stop"
Write-Host -NoNewline "> Uninstalling Receiver... "
$installDir = "C:\ProgramData\Heads\Receiver"

$serviceName = 'Heads Receiver'
$existingService = Get-Service $serviceName -ErrorAction SilentlyContinue
if ($existingService) {
    if ($existingService.Status -eq "Running") {
        $out = Stop-Service -Name $serviceName
        Start-Sleep -Seconds 4
    }
    $out = sc.exe delete $serviceName
}
$exists = Test-Path $installDir
rm -r "$installDir\bin" -ErrorAction SilentlyContinue
rm "$installDir\version.txt.lnk" -ErrorAction SilentlyContinue
rm -r "$installDir\Deployment" -ErrorAction SilentlyContinue
rm -r "$installDir\Temp" -ErrorAction SilentlyContinue
rm "$installDir\*.json" -ErrorAction SilentlyContinue
rm "$installDir\*.info" -ErrorAction SilentlyContinue

if ($exists) {
    echo "$((Get-Date -AsUTC).ToString("yyyyMMddHHmmss") ): UNINSTALLED Receiver" >> "C:\ProgramData\Heads\install.log"
    Write-Host "Done!"
}
else { Write-Host "No installation found" }
