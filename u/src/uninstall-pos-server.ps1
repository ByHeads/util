Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
$ErrorActionPreference = "Stop"
Write-Host -NoNewline "> Uninstalling POS-Server... "
$installDir = "C:\ProgramData\Heads\POSServer"

$serviceName = 'Heads POS Server'
$existingService = Get-Service $serviceName -ErrorAction SilentlyContinue
if ($existingService) {
    if ($existingService.Status -eq "Running") {
        $out = Stop-Service -Name $serviceName
        Start-Sleep -Seconds 4
    }
    $out = sc.exe delete $serviceName
}
$wait = $false
ForEach ($name in @("scdbs", "scdbc", "scsql", "scpmm", "scweaver")) {
    $process = Get-Process $name -ErrorAction SilentlyContinue
    if ($process) {
        $process | Stop-Process -Force
        $process | Wait-Process
        $wait = $true
    }
}
if ($wait) { Start-Sleep -Seconds 4 }
$exists = Test-Path $installDir
rm -r $installDir -ErrorAction SilentlyContinue

if ($exists) {
    if (!(Test-Path "C:\ProgramData\Heads")) { $out = New-Item -Path "C:\ProgramData\Heads" -ItemType Directory }
    echo "$((Get-Date).ToUniversalTime().ToString("yyyyMMddHHmmss") ): UNINSTALLED POS Server" >> "C:\ProgramData\Heads\install.log"
    Write-Host "Done!"
}
else { Write-Host "No installation found" }
