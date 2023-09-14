pwsh {
    Write-Host "This script will download:"
    Write-Host
    Write-Host "- PowerShell 7 installer from it's official Microsoft source"
    Write-Host "- bcman.ps1 PowerShell source from it's GitHub repo"
    Write-Host "– Visual C++ Redistributable 2015-2022 x64 and x86 installers from the official Microsoft source"
    Write-Host
    Write-Host "The files will be placed in subdirectories to the Broadcaster install directory,"
    Write-Host "from where they can be deployed by the Broadcaster to clients"
    Write-Host
    Read-Host "Press Enter to continue or Ctrl+C to abort"
    $bcPath = Read-Host "> Enter the Broadaster install directory path"
    $o = New-Item -Path "$bcPath\bcman" -ItemType Directory -ErrorAction SilentlyContinue
    $o = New-Item -Path "$bcPath\vcredist" -ItemType Directory -ErrorAction SilentlyContinue
    $o = New-Item -Path "$bcPath\powershell" -ItemType Directory -ErrorAction SilentlyContinue
    $powershellUrl = irm https://api.github.com/repos/PowerShell/PowerShell/releases/latest `
    | % { $_.assets } `
    | ? { $_.browser_download_url -like "*win-x64.msi*" } `
    | select -exp browser_download_url
    $powershellFileName = Split-Path -Path $powershellUrl -Leaf
    Write-Host "> Downloading $powershellFileName from $powershellUrl"
    irm $powershellUrl -OutFile "$bcPath\powershell\$powershellFileName"
    Write-Host "> Downloading bcman.ps1 from https://raw.githubusercontent.com/byheads/bcman/main/bcman.ps1"
    irm raw.githubusercontent.com/byheads/bcman/main/bcman.ps1 -OutFile "$bcPath\bcman\bcman.ps1"
    Write-Host "> Downloading vcredist x64 from https://aka.ms/vs/17/release/vc_redist.x64.exe"
    irm https://aka.ms/vs/17/release/vc_redist.x64.exe -OutFile "$bcPath\vcredist\vc_redist.x64.exe"
    Write-Host "> Downloading vcredist x86 from https://aka.ms/vs/17/release/vc_redist.x86.exe"
    irm https://aka.ms/vs/17/release/vc_redist.x86.exe -OutFile "$bcPath\vcredist\vc_redist.x86.exe"
    Write-Host "> Done!" -ForegroundColor Green
}
