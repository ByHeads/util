Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
$ErrorActionPreference = "Stop"
if (!(Test-Path "C:\ProgramData\Heads\Starcounter.LogViewer.exe")) {
    irm raw.githubusercontent.com/byheads/util/main/Starcounter.LogViewer.exe -OutFile "C:\ProgramData\Heads\LogViewer\Starcounter.LogViewer.exe"
}
Write-Host "> Cry no more, dear troubleshooter. The Starcounter LogViewer is here now!"
sleep 0.5
Write-Host "I's in C:\ProgramData\Heads\LogViewer for you if you need to find it later"
sleep 0.5
$newestLogFile = Get-ChildItem "C:\ProgramData\Heads\POSServer\bin\Server\starcounter.*.log" -ErrorAction SilentlyContinue | sort | select -first 1
if (!$newestLogFile) {
    Write-Host "However, you don't have any starcounter log files in C:\ProgramData\Heads\POSServer\bin\Server so I can't start it..."
    return
}
Write-Host "But I'm also starting it right now because I'm just that nice!"
& C:\ProgramData\Heads\Starcounter.LogViewer.exe $newestLogFile.FullName
