Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
if (![bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -match "S-1-5-32-544")) {
    Write-Host "This script requires administrator rights, please run again in PowerShell as administrator" -ForegroundColor Red
    throw
}
if (![Environment]::Is64BitOperatingSystem) {
    Write-Host "This computer is running a 32-bit operating system. This software can only run on 64-bit systems" -ForegroundColor Red
    throw
}
$ErrorActionPreference = "Stop"
try {
    # Bind some variables
    $drive = $pwd.drive.name
    $product = 'Broadcaster'
    $serviceName = 'Heads Broadcaster'
    if (-not( Test-Path env:HEADS_BroadcasterDir)) {
        $env:HEADS_BroadcasterDir = '\Heads\Broadcaster'
    }
    $installDir = $env:HEADS_BroadcasterDir
    $serviceParameters = @{
        Name = "$serviceName"
        BinaryPathName = "`"$drive`:$installDir\bin\Broadcaster.Application.exe`" `"$drive`:$installDir`""
        DisplayName = $serviceName
        StartupType = "Automatic"
    }
    # Print a nice logo
    Write-Host
    Write-Host "___________________________________________________________________________________"
    Write-Host "                  +        +        +        +      *       +     +            +  /"
    Write-Host "     |\ |\     *   ___    +      *      +    __  +       +   *   __    +    *     \"
    Write-Host "  |\ || || |\     / _ )  ____ ___  ___ _ ___/ / ____ ___ _  ___ / /_ ___   ____   /"
    Write-Host "  || || || ||    / _  | / __// _ \/ _ ``// _  / / __// _ ``/ (_-</ __// -_) / __/   \"
    Write-Host "  \| || || \|   /____/ /_/   \___/\_,_/ \_,_/  \__/ \_,_/ /___/\__/ \__/ /_/      /"
    Write-Host "     \| \|    <>============================================================<>    \"
    Write-Host "_________________________________________________It_does_not_suck_________________/"
    Write-Host
    Write-Host "> Installing Broadcaster into $drive`:$installDir"
    # Delete any existing Broadcaster service
    Write-Host "> Finding existing services with the name $serviceName"
    $existingService = Get-Service $serviceName -ErrorAction SilentlyContinue
    if ($existingService) {
        Stop-Service -Name $serviceName
        Start-Sleep -Seconds 5
        $out = sc.exe delete $serviceName
        Write-Host "> An existing service with name $serviceName was deleted"
    }
    # Ensure that the directory denoted by env:HEADS_BroadcasterDir exists
    if (!(Test-Path $installDir)) {
        throw "Broadcaster installation failed: Directory $installDir does not exist"
    }
    # Fail if there's not exactly one zip file in the Broadcaster directory
    if ((Get-ChildItem "$installDir\*.zip" | Measure-Object).Count -ne 1) {
        throw "Broadcaster installation failed: Expected exactly one .zip file in the Broadcaster directory ($installDir)"
    }
    # Fail if there's no appsettings.json file in the Broadcaster directory
    if ((Get-ChildItem "$installDir\appsettings.json" | Measure-Object).Count -eq 0) {
        throw "Broadcaster installation failed: Expected an appsettings.json file in the Broadcaster directory ($installDir). See the docs for how to create an appsettings.json file"
    }
    # Validate JSON syntax of appsettings file
    try { Get-Content "$installDir\appsettings.json" -Raw | ConvertFrom-Json | Out-Null }
    catch { throw "Broadcaster installation failed: The appsettings.json file in the Broadcaster directory ($installDir) is not valid JSON. $_" }

    # Clear the existing \bin directory, if any
    if (Test-Path "$installDir\bin") {
        for($i = 0; $i -lt 1000; $i++)
        {
            try { rm -r -fo "$installDir\bin"; break }
            catch { Start-Sleep -Seconds 1; continue }
        }
    }
    # Expand the zip file to the bin directory
    $zip = Get-ChildItem "$installDir\*.zip" | Select-Object -first 1
    $version = $zip.ToString().Split("-")[1]
    if ($version) {
        Write-Host "> Installing Broadcaster " -NoNewline
        Write-Host "v$version" -ForegroundColor Yellow
    }
    else {
        throw "The matching zip file found in $installDir was of an unknown (non-Broadcaster) format"
    }
    $zip | Expand-Archive -DestinationPath "$installDir\bin" -Force
    #region Create the Broadcaster service
    Write-Host "> Creating the $serviceName Windows service"
    $out = New-Service @serviceParameters
    $out = & sc.exe failure $serviceName "actions=" "restart/30000/restart/30000//" "reset=" 60
    Write-Host "> The $serviceName service was created"
    #endregion
    #region Start the Broadcaster service
    Start-Service -Name $serviceName
    Write-Host "> The $serviceName service is now running"
    #endregion
    Write-Host -ForegroundColor:Green "> All done! $product was successfully installed!"
}
catch {
    Write-Error $_
    $psVer = $PSVersionTable.PSVersion.ToString()
    Write-Error "PS Version: $psVer"
    Write-Host "- $product installation failed"
}
