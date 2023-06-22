Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
$ErrorActionPreference = "Stop"
try {
    # Bind some variables
    $drive = $pwd.drive.name
    $product = 'Broadcaster'
    $serviceName = 'Heads Broadcaster'
    if (-not( Test-Path env:HEADS_BroadcasterDir)) {
        $env:HEADS_BroadcasterDir = '\Heads\Broadcaster'
    }
    $serviceParameters = @{
        Name = "$serviceName"
        BinaryPathName = "`"$drive`:$env:HEADS_BroadcasterDir\bin\Broadcaster.Application.exe`" `"$drive`:$env:HEADS_BroadcasterDir`""
        DisplayName = $serviceName
        StartupType = "Automatic"
    }
    $installDir = $env:HEADS_BroadcasterDir
    # Print a nice logo
    Write-Host
    Write-Host "__________________________________________________________________________________"
    Write-Host "                  +        +        +        +      *       +     +            + /"
    Write-Host "     |\ |\     *   ___    +      *      +    __  +       +   *   __    +    *    \"
    Write-Host "  |\ || || |\     / _ )  ____ ___  ___ _ ___/ / ____ ___ _  ___ / /_ ___   ____  /"
    Write-Host "  || || || ||    / _  | / __// _ \/ _ ``// _  / / __// _ ``/ (_-</ __// -_) / __/  \"
    Write-Host "  \| || || \|   /____/ /_/   \___/\_,_/ \_,_/  \__/ \_,_/ /___/\__/ \__/ /_/     /"
    Write-Host "     \| \|    <>============================================================<>   \"
    Write-Host "_________________________________________________It_does_not_suck________________/"
    Write-Host
    Write-Host "> Installing Broadcaster into $drive`:$env:HEADS_BroadcasterDir"
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
    if (-not(Test-Path $env:HEADS_BroadcasterDir)) {
        throw "Broadcaster installation failed: Directory $HEADS_BroadcasterDir does not exist"
    }
    # Fail if there's not exactly one zip file in the Broadcaster directory
    if ((Get-ChildItem "$env:HEADS_BroadcasterDir\*.zip" | Measure-Object).Count -ne 1) {
        throw "Broadcaster installation failed: Expected exactly one .zip file in the Broadcaster directory ($env:HEADS_BroadcasterDir)"
    }
    # Fail if there's no appsettings.json file in the Broadcaster directory
    if ((Get-ChildItem "$env:HEADS_BroadcasterDir\appsettings.json" | Measure-Object).Count -eq 0) {
        throw "Broadcaster installation failed: Expected an appsettings.json file in the Broadcaster directory ($env:HEADS_BroadcasterDir). See the installation steps for how to create an appsettings.json file"
    }
    # Clear the existing \bin directory, if any
    if (Test-Path "$env:HEADS_BroadcasterDir\bin") {
        rm -r -fo "$env:HEADS_BroadcasterDir\bin"
    }
    # Expand the zip file to the bin directory
    $zip = Get-ChildItem "$env:HEADS_BroadcasterDir\*.zip" | Select-Object -first 1
    $version = $zip.ToString().Split("-")[1]
    if ($version) {
        Write-Host "> Installing Broadcaster version $version"
    }
    else {
        throw "The matching zip file found in $env:HEADS_BroadcasterDir was of an unknown (non-Broadcaster) format"
    }
    $zip | Expand-Archive -DestinationPath "$env:HEADS_BroadcasterDir\bin" -Force
    # Remove the expanded archive
    Remove-Item -Path "$env:HEADS_BroadcasterDir\*.zip"
    #region Create the Broadcaster service
    Write-Host "> Creating the $serviceName Windows service"
    $out = New-Service @serviceParameters
    $out = & sc.exe failure "$serviceName" "actions=" "restart/30000/restart/30000//" "reset=" 60
    Write-Host "> The $serviceName service was created"
    #endregion
    #region Start the Broadcaster service
    Start-Service -Name $serviceName
    Write-Host "> The $serviceName service is now running"
    #endregion
    Write-Host -ForegroundColor:Green "- $product was successfully installed!"
}
catch {
    Write-Error $_
    $psVer = $PSVersionTable.PSVersion.ToString()
    Write-Error "PS Version: $psVer"
    Write-Host "- $product installation failed"
}
