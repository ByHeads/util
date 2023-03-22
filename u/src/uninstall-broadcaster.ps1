Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
$ErrorActionPreference = "Stop"
Write-Host -NoNewline "> Uninstalling Broadcaster... "
$installDir = "C:\Heads\Broadcaster"

$serviceName = 'Heads Broadcaster'
$existingService = Get-Service $serviceName -ErrorAction SilentlyContinue
if ($existingService) {
    if ($existingService.Status -eq "Running") {
        $out = Stop-Service -Name $serviceName
        Start-Sleep -Seconds 4
    }
    $out = sc.exe delete $serviceName
}
$exists = Test-Path $installDir
rm -r $installDir -ErrorAction SilentlyContinue
Write-Host ($exists ? "Done!" : "No installation found")
