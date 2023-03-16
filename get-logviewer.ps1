Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
$ErrorActionPreference = "Stop"
if (!(Test-Path "C:\ProgramData\Heads\LogViewer\Starcounter.LogViewer.exe")) {
    mkdir "C:\ProgramData\Heads\LogViewer" -ErrorAction SilentlyContinue | Out-Null
    irm raw.githubusercontent.com/byheads/util/main/Starcounter.LogViewer.exe -OutFile "C:\ProgramData\Heads\LogViewer\Starcounter.LogViewer.exe"
}
Write-Host -NoNewline "The "
Write-Host -NoNewline "Starcounter LogViewer" -ForegroundColor Green
Write-Host -NoNewline " is installed at "
Write-Host "C:\ProgramData\Heads\LogViewer" -ForegroundColor Yellow
$newestLogFile = Get-ChildItem "C:\ProgramData\Heads\POSServer\bin\Server\starcounter.*.log" -ErrorAction SilentlyContinue | sort | select -last 1
if (!$newestLogFile) {
    Write-Host "You don't have any starcounter log files in C:\ProgramData\Heads\POSServer\bin\Server"
    return
}
Write-Host "Starting with log file $( $newestLogFile.Name )"
& C:\ProgramData\Heads\LogViewer\Starcounter.LogViewer.exe $newestLogFile.FullName
