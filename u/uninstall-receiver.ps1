Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
$ErrorActionPreference = "Stop"
Write-Host -NoNewline "> Uninstalling Receiver... "
$serviceName = 'Heads Receiver'
$existingService = Get-Service $serviceName -ErrorAction SilentlyContinue
if ($existingService) {
    if ($existingService.Status -eq "Running") {
        $out = Stop-Service -Name $serviceName
        Start-Sleep -Seconds 4
    }
    $out = sc.exe delete $serviceName
}
rm -r "C:\ProgramData\Heads\Receiver"
Write-Host "Done!"
