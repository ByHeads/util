Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
$ErrorActionPreference = "Stop"
Write-Host -NoNewline "> Uninstalling legacy software... "

$shell = New-Object -ComObject WScript.Shell
$desktopPath = $shell.SpecialFolders("Desktop")
Get-ChildItem "$desktopPath\*.lnk" | % {
    if ($shell.CreateShortcut($_).TargetPath -eq "C:\Program Files (x86)\Heads\Heads RetailWPF\Heads.exe") {
        Remove-Item $_
    }
}

$services = @(
"Heads Maintenance Service"
"Heads-POSServer Download Service"
"Heads-POSServer Launcher"
"Heads-RetailWPF Download Service"
)

foreach ($serviceName in $services) {
    $existingService = Get-Service $serviceName -ErrorAction SilentlyContinue
    if ($existingService) {
        if ($existingService.Status -eq "Running") {
            $out = Stop-Service -Name $serviceName
            Start-Sleep -Seconds 4
        }
        $out = sc.exe delete $serviceName

    }
}

$clientProcess = Get-Process "PolyjuiceWindows" -ErrorAction SilentlyContinue
if ($clientProcess) {
    $clientProcess | Stop-Process -Force
    $clientProcess | Wait-Process
    Start-Sleep -Seconds 4
}

$wait = $false
foreach ($name in @("scdbs", "scdbc", "scsql", "scpmm", "scweaver")) {
    $process = Get-Process $name -ErrorAction SilentlyContinue
    if ($process) {
        $process | Stop-Process -Force
        $process | Wait-Process
        $wait = $true
    }
}
if ($wait) { Start-Sleep -Seconds 4 }

rm -r "C:\Program Files (x86)\Heads" -ErrorAction SilentlyContinue
rm -r "C:\ProgramData\Heads Svenska AB" -ErrorAction SilentlyContinue

Remove-Item -Path HKCU:\SOFTWARE\Heads -Recurse

Write-Host "Done!"
