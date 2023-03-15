Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
$ErrorActionPreference = "Stop"
if (!(Test-Path "C:\ProgramData\Heads\LogViewer\Starcounter.LogViewer.exe")) {
    mkdir "C:\ProgramData\Heads\LogViewer" -ErrorAction SilentlyContinue | Out-Null
    irm raw.githubusercontent.com/byheads/util/main/Starcounter.LogViewer.exe -OutFile "C:\ProgramData\Heads\LogViewer\Starcounter.LogViewer.exe"
}
Write-Host
Write-Host -NoNewline "> Cry no more, dear troubleshooter. The "
Write-Host "Starcounter LogViewer" -ForegroundColor Green
Write-Host "is here now!"
sleep 1
Write-Host -NoNewline "> (it's in "
Write-Host -NoNewline "C:\ProgramData\Heads\LogViewer" -ForegroundColor Yellow
Write-Host "if you need to find it later)"
$newestLogFile = Get-ChildItem "C:\ProgramData\Heads\POSServer\bin\Server\starcounter.*.log" -ErrorAction SilentlyContinue | sort | select -last 1
if (!$newestLogFile) {
    sleep 1
    Write-Host "> However, you don't have any starcounter log files in C:\ProgramData\Heads\POSServer\bin\Server, so I can't start it for you..."
    return
}
& C:\ProgramData\Heads\LogViewer\Starcounter.LogViewer.exe $newestLogFile.FullName
