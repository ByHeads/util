if (![bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -match "S-1-5-32-544")) {
    Write-Host "This script requires administrator rights, please run again in PowerShell as administrator" -ForegroundColor Red
    return
}
if (![Environment]::Is64BitOperatingSystem) {
    Write-Host "This computer is running a 32-bit operating system. This software can only run on 64-bit systems."  -ForegroundColor Red
    return
}
if ($PSVersionTable.PSVersion.Major -lt 7) {
    # Upgrade to PowerShell 7
    $coreVersion = Get-ItemPropertyValue -Path "HKLM:\SOFTWARE\Microsoft\PowerShellCore\InstalledVersions\*" -Name "SemanticVersion" -ErrorAction SilentlyContinue
    if (!$coreVersion -or !$coreVersion.StartsWith("7")) {
        try {
            Write-Host -NoNewline "> Installing PowerShell 7... "
            iex "& { $( irm 'https://aka.ms/install-powershell.ps1' ) } -UseMSI -Quiet" *>&1 | Out-Null
            Write-Host "Done!"
        }
        catch {
            Write-Host "Failed!"
            Write-Host
            Write-Host "Could not install PowerShell 7 :/ Try again, and if the error persists, try a manual install using the link below:"
            Write-Host
            Write-Host "--> " -NoNewline
            Write-Host "https://github.com/PowerShell/PowerShell/releases/download/v7.3.3/PowerShell-7.3.3-win-x64.msi" -ForegroundColor Yellow -NoNewline
            Write-Host " <--" -NoNewline
            Write-Host
            Write-Host "... and then try to run the script again"
            return
        }
        $env:path = [System.Environment]::GetEnvironmentVariable("Path", "Machine")
    }
}
