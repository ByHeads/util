Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
$ErrorActionPreference = "Stop"
Write-Host -NoNewline "> Uninstalling legacy software... "

# SUS/Services
$legacyServices = @(
"Heads Maintenance Service"
"Heads-POSServer Download Service"
"Heads-POSServer Launcher"
"Heads-RetailWPF Download Service"
"Heads-CustomerServiceApplicationWPF Download Service"
"Heads-CustomerServiceApplicationWPF State service"
)

foreach ($service in $legacyServices) {
    $existingService = Get-Service $service -ErrorAction SilentlyContinue
    if ($existingService) {
        if ($existingService.Status -eq "Running") {
            $out = Stop-Service -Name $service
            Start-Sleep -Seconds 4
        }
        $out = sc.exe delete $service
    }
}

# Client
$clientFilePath = "C:\ProgramData\Heads Svenska AB\Client\Bin\Client\PolyjuiceWindows.exe"
$clientProcess = Get-Process "PolyjuiceWindows" -ErrorAction SilentlyContinue | Where { $_.MainModule.FileName -eq $clientFilePath }
if ($clientProcess) {
    $clientProcess | Stop-Process -Force
    $clientProcess | Wait-Process
    Start-Sleep -Seconds 4
}
$headsExePath = "C:\Program Files (x86)\Heads\Heads RetailWPF\Heads.exe"
$shell = New-Object -ComObject WScript.Shell
$desktopPath = $shell.SpecialFolders("Desktop")
Get-ChildItem "$desktopPath\*.lnk" | % {
    if ($shell.CreateShortcut($_).TargetPath -eq $headsExePath) {
        Remove-Item $_
    }
}
$desktopPath = "$env:Public\Desktop"
Get-ChildItem "$desktopPath\*.lnk" | % {
    if ($shell.CreateShortcut($_).TargetPath -eq $headsExePath) {
        Remove-Item $_
    }
}

# Customer Service Application
Unregister-ScheduledTask -TaskName "Heads Keep Alive" -Confirm $false -ErrorAction SilentlyContinue | Out-Null
Start-Sleep -Seconds 2
$runnerProcess = Get-Process "Heads.Runner" -ErrorAction SilentlyContinue
if ($runnerProcess) {
    $runnerProcess | Stop-Process -Force
    $runnerProcess | Wait-Process
    Start-Sleep -Seconds 2
}
$csaFilePath = "C:\ProgramData\Heads Svenska AB\CustomerServiceClient\Bin\CustomerServiceClient\PolyjuiceWindows.exe"
$csaProcess = Get-Process "PolyjuiceWindows" -ErrorAction SilentlyContinue | Where { $_.MainModule.FileName -eq $csaFilePath }
if ($csaProcess) {
    $csaProcess | Stop-Process -Force
    $csaProcess | Wait-Process
    Start-Sleep -Seconds 4
}
$headsExePath = "C:\Program Files (x86)\Heads\Heads CustomerServiceApplicationWPF\Heads.exe"
$shell = New-Object -ComObject WScript.Shell
$desktopPath = $shell.SpecialFolders("Desktop")
Get-ChildItem "$desktopPath\*.lnk" | % {
    if ($shell.CreateShortcut($_).TargetPath -eq $headsExePath) {
        Remove-Item $_
    }
}
$desktopPath = "$env:Public\Desktop"
Get-ChildItem "$desktopPath\*.lnk" | % {
    if ($shell.CreateShortcut($_).TargetPath -eq $headsExePath) {
        Remove-Item $_
    }
}

# StatusLogViewer
$logViewerPath = "C:\Program Files (x86)\Heads\Heads POSServer\StatusLogMonitor\StatusLogViewer.exe"
$statusLogViewerProcess = Get-Process "StatusLogViewer" -ErrorAction SilentlyContinue | Where { $_.MainModule.FileName -eq $logViewerPath }
if ($statusLogViewerProcess) {
    $statusLogViewerProcess | Stop-Process -Force
    $statusLogViewerProcess | Wait-Process
    Start-Sleep -Seconds 4
}

# Starcounter processes
$wait = $false
foreach ($name in @("scdbs", "scdbc", "scsql", "scpmm", "scweaver" )) {
    $process = Get-Process $name -ErrorAction SilentlyContinue
    if ($process) {
        $process | Stop-Process -Force
        $process | Wait-Process
        $wait = $true
    }
}
if ($wait) { Start-Sleep -Seconds 4 }

# Directories and registry entries
rm -r "C:\Program Files (x86)\Heads" -ErrorAction SilentlyContinue
rm -r "C:\ProgramData\Heads Svenska AB" -ErrorAction SilentlyContinue
Remove-Item -Path HKCU:\SOFTWARE\Heads -Recurse

# Write log
if (!(Test-Path "C:\ProgramData\Heads")) { $out = New-Item -Path "C:\ProgramData\Heads" -ItemType Directory }
echo "$((Get-Date).ToUniversalTime().ToString("yyyyMMddHHmmss") ): UNINSTALLED legacy" >> "C:\ProgramData\Heads\install.log"

Write-Host "Done!"
