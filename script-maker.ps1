$script = ""

function Yes
{
    param($message)
    $val = Read-Host "> $message (yes/no)"
    $val = $val.Trim();
    if ($val -eq "yes") { return $true }
    if ($val -eq "no") { return $false }
    Write-Host "Invalid value, expected yes or no"
    return Yes $message
}

function Num
{
    param($message)
    $val = Read-Host "> $message (number)"
    $val = $val.Trim();
    if ($val -as [int]) { return $val }
    Write-Host "Invalid value, expected a number"
    return Num $message
}

function Collation
{
    param($message)
    $val = Read-Host "> $message"
    $val = $val.Trim().ToLower();
    if ($val -eq "sv-se") { return "sv-SE" }
    if ($val -eq "en-gb") { return "en-GB" }
    if ($val -eq "nb-no") { return "nb-NO" }
    Write-Host "Invalid collation, expected sv-SE, en-GB or nb-NO"
    return Collation $message
}

Write-Host ""
Write-Host "> This tool will help create a Broadcaster install script!" -ForegroundColor Green
$environment = Read-Host "> Enter environment name, e.g. fynda or fynda-test"
$token = Read-Host "> Enter install token" -MaskInput
$baseUrl = "https://broadcaster.$environment.heads-api.com/api/install"

if (Yes "Should we first uninstall all existing client software?") {
    $script += "irm raw.githubusercontent.com/byheads/util/main/u/all | iex"
    $script += [Environment]::NewLine
}
if (Yes "Install Receiver?") {
    $script += "irm `"$baseUrl/product=Receiver`" -Headers @{ Authorization = `"Bearer $token`" } | iex"
    $script += [Environment]::NewLine
}
if (Yes "Install WpfClient?") {
    $part = "product=WpfClient"
    $part += "&usePosServer=" + (Yes "--- Connect client to local POS Server?")
    $part += "&useArchiveServer=" + (Yes "--- Connect client to central Archive Server?")
    $script += "irm `"$baseUrl/$part`" -Headers @{ Authorization = `"Bearer $token`" } | iex"
    $script += [Environment]::NewLine
}
if (Yes "Install POS Server?") {
    $part = "product=PosServer"
    $part += "&createDump=" + (Yes "--- Create a dump first?")
    $part += "&databaseImageSize=" + (Num "--- Enter database image size in MB")
    $part += "&databaseLogSize=" + (Num "--- Enter database log size in MB")
    $part += "&collation=" + (Collation "--- Enter database collation, e.g. sv-SE")
    $script += "irm `"$baseUrl/$part`" -Headers @{ Authorization = `"Bearer $token`" } | iex"
    $script += [Environment]::NewLine
}

Write-Host ""
Write-Host "# Here's your script. Run it in PowerShell as administrator on a client computer"
Write-Host ""
Write-Host $script
Write-Host "# End of script"
