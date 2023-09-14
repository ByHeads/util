$bcPath = Read-Host "> BC install dir: "
New-Item -Path "$bcPath\bcman" -ItemType Directory
New-Item -Path "$bcPath\vcredist" -ItemType Directory
New-Item -Path "$bcPath\powershell" -ItemType Directory
$powershellUrl = irm https://api.github.com/repos/PowerShell/PowerShell/releases/latest `
    | % { $_.assets } `
    | ? { $_.browser_download_url -like "*win-x64.msi*" } `
    | select -exp browser_download_url
Write-Host "> Downloading $powershellFileName from $powershellUrl"
$powershellFileName = Split-Path -Path $powershellUrl -Leaf
irm $powershellUrl -OutFile "$bcPath\powershell\$powershellFileName"
Write-Host "> Downloading bcman.ps1 from https://raw.githubusercontent.com/byheads/bcman/main/bcman.ps1"
irm raw.githubusercontent.com/byheads/bcman/main/bcman.ps1 -OutFile "$bcPath\bcman\bcman.ps1"
Write-Host "> Downloading vcredist x64 from https://aka.ms/vs/17/release/vc_redist.x64.exe"
irm https://aka.ms/vs/17/release/vc_redist.x64.exe -OutFile "$bcPath\vcredist\vc_redist.x64.exe"
Write-Host "> Downloading vcredist x86 from https://aka.ms/vs/17/release/vc_redist.x86.exe"
irm https://aka.ms/vs/17/release/vc_redist.x86.exe -OutFile "$bcPath\vcredist\vc_redist.x86.exe"
Write-Host "Done!"
