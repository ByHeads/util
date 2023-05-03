#!ps 
# A light-weight preflight script to just ensure that we have PowerShell 7. Intended for modern win10/11 computers
# where the script does not need administrator rights. If interactive, will ask before installing PowerShell 7.
$requiredPsVersion = 7
if ($PSVersionTable.PSVersion.Major -lt $requiredPsVersion) {
    # Upgrade to PowerShell 7
    $coreVersion = Get-ItemPropertyValue -Path "HKLM:\SOFTWARE\Microsoft\PowerShellCore\InstalledVersions\*" -Name "SemanticVersion" -ErrorAction SilentlyContinue
    if (!$coreVersion -or !$coreVersion.StartsWith("$requiredPsVersion")) {
        function Yes($message)
        {
            switch ( (Read-Host "$message (yes/no)").Trim()) {
                "yes" { return $true } "no" { return $false } "y" { return $true } "n" { return $false }
                default { Write-Host "Invalid value, expected yes or no"; return Yes $message }
            }
        }
        if ($PSVersionTable.Platform -eq "Unix") {
            Write-Host "> This script requires PowerShell $requiredPsVersion. Please install it and run this script again."
            exit 0
        }
        $interactive = !([bool]([Environment]::GetCommandLineArgs() -like '-noni*'))
        if ($interactive) {
            $response = Yes "> This script requires PowerShell $requiredPsVersion. Do you want to install it now using winget?"
            if (!$response) {
                Write-Host "> Aborting"
                exit 1
            }
        }
        Write-Host "> Installing PowerShell $requiredPsVersion using winget..."
        winget install Microsoft.PowerShell -h
        $env:path = [System.Environment]::GetEnvironmentVariable("Path", "Machine")
    }
}
