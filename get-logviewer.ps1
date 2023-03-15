Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
$ErrorActionPreference = "Stop"
irm raw.githubusercontent.com/byheads/util/main/Starcounter.LogViewer.exe -OutFile "C:\ProgramData\Heads\Starcounter.LogViewer.exe"
Write-Host "Cry no more, dear troubleshooter. The Starcounter LogViewer is here now!"
sleep 0.3
Write-Host "I put it in C:\ProgramData\Heads for you if you need to find it later"
sleep 0.3
Write-Host "But I'm also starting it right now because I'm just that nice..."
sleep 0.3
Write-Host "Here you go!" -ForegroundColor Green
& C:\ProgramData\Heads\Starcounter.LogViewer.exe
