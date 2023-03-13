# This script activates a previously sideloaded client and uninstalls legacy software
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
$ErrorActionPreference = "Stop"
Write-Host -NoNewline "> Activating Broadcaster-based client applications"
# Uninstall all legacy software
irm raw.githubusercontent.com/byheads/util/main/u/uninstall-legacy.ps1 | iex
# Finalize WpfClient by creating a desktop shortcut
Write-Host -NoNewline "> Creating WPF client desktop shortcut... "
$wpfInstallDir = "C:\ProgramData\Heads\Client";
$processFilePath = "$wpfInstallDir\bin\PolyjuiceWindows.exe"
$shell = New-Object -ComObject WScript.Shell
$desktopPath = $shell.SpecialFolders("Desktop")
$shortcutPath = "$desktopPath\Heads Retail.lnk"
$shortcut = $shell.CreateShortcut($shortcutPath)
$shortcut.TargetPath = $processFilePath
$shortcut.WorkingDirectory = "$wpfInstallDir\bin"
$shortcut.IconLocation = "$wpfInstallDir\bin\AppIcon.ico"
$shortcut.Save()
Write-Host "Done!"
# Finalize POS-server by creating and starting the service
$serviceName = 'Heads POS Server'
Write-Host -NoNewline "> Creating the $serviceName service... "
$existingService = Get-Service $serviceName -ErrorAction SilentlyContinue
if ($existingService) {
    if ($existingService.Status -eq "Running") {
        $out = Stop-Service -Name $serviceName
        Start-Sleep -Seconds 4
    }
    $out = sc.exe delete $serviceName
}
$posInstallDir = "C:\ProgramData\Heads\POSServer"
$starcounterDir = "$posInstallDir\bin\Starcounter"
$serviceWrapper = "$posInstallDir\bin\Service\ScSvcWrap10.exe"
$databaseName = "POSServer"
$serviceParameters = @{
    Name = $serviceName
    BinaryPathName = "$serviceWrapper --db-server --starcounter-home $starcounterDir --server-name $databaseName"
    DisplayName = $serviceName
    StartupType = "Automatic"
}
$out = New-Service @serviceParameters
$out = & sc.exe failure "$serviceName" "actions=" "restart/30000/restart/30000//" "reset=" 60
Start-Service -Name $serviceName
Write-Host "Done!"
