#!ps
# A robust preflight script for initiating and checking client computers before install. Intended for client computers
# and when the script is an install or uninstall script that requires administrator rights
if (![bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -match "S-1-5-32-544")) {
    Write-Host "This script requires administrator rights, please run again in PowerShell as administrator" -ForegroundColor Red
    throw
}
if (![Environment]::Is64BitOperatingSystem) {
    Write-Host "This computer is running a 32-bit operating system. This software can only run on 64-bit systems" -ForegroundColor Red
    throw
}
if ($PSVersionTable.PSVersion.Major -lt 7) {
    # Upgrade to PowerShell 7
    $coreVersion = Get-ItemPropertyValue -Path "HKLM:\SOFTWARE\Microsoft\PowerShellCore\InstalledVersions\*" -Name "SemanticVersion" -ErrorAction SilentlyContinue
    if (!$coreVersion -or !$coreVersion.StartsWith("7")) {
        try {
            Write-Host -NoNewline "> Installing PowerShell 7... "
            iex "& { $( irm 'https://aka.ms/install-powershell.ps1' ) } -UseMSI -Quiet" *>&1 | Out-Null
            Write-Host "Done!"
            $env:path = [System.Environment]::GetEnvironmentVariable("Path", "Machine")
        }
        catch {
            Write-Host "Failed!" -ForegroundColor Red
            Write-Host
            Write-Host "Could not install PowerShell 7 :/ Try again, and if the error persists, try a manual install using one of the methods mentioned here:"
            Write-Host
            Write-Host "--> " -NoNewline -ForegroundColor Gray
            Write-Host "https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows" -ForegroundColor Yellow -NoNewline
            Write-Host " <--" -ForegroundColor Gray
            Write-Host
            Write-Host "... and then try to run the script again"
            Write-Host
            throw
        }
    }
}
