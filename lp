#!ps A light-weight preflight script to just ensure that we have PowerShell 7. Intended for modern win10,11 computers.
if ($PSVersionTable.PSVersion.Major -lt 7) {
    # Upgrade to PowerShell 7
    $coreVersion = Get-ItemPropertyValue -Path "HKLM:\SOFTWARE\Microsoft\PowerShellCore\InstalledVersions\*" -Name "SemanticVersion" -ErrorAction SilentlyContinue
    if (!$coreVersion -or !$coreVersion.StartsWith("7")) {
        $o = winget install Microsoft.PowerShell -h
        $env:path = [System.Environment]::GetEnvironmentVariable("Path", "Machine")
    }
}
