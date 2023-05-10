function Yes
{
    param($message)
    $val = Read-Host "$message (yes/no)"
    $val = $val.Trim();
    if ($val -eq "yes") { return $true }
    if ($val -eq "no") { return $false }
    if ($val -eq "y") { return $true }
    if ($val -eq "n") { return $false }
    Write-Host "Invalid value, expected yes or no"
    return Yes $message
}
function Num
{
    param($message, $default)
    $val = Read-Host $message
    $val = $val.Trim();
    if ($val -eq '') { return $default }
    if ($val -as [int]) { return $val }
    Write-Host "Invalid value, expected a number"
    return Num $message
}
function InvalidFileName
{
    param([string]$name)
    return $name.IndexOfAny([System.IO.Path]::GetInvalidFileNameChars()) -ne -1
}
function Label
{
    $label = Read-Host "Enter a unique name for the manual client, e.g. Fynda Testmiljö"
    $label = $label.Trim()
    if ($label -eq '') {
        Write-Host "Invalid value, expected a shortcut label"
        return Label
    }
    if (InvalidFileName $label) {
        Write-Host "Invalid value, $label contains characters that are invalid in a file name"
        return Label
    }
    return $label
}
function Collation
{
    param($message)
    $val = Read-Host "$message (sv-SE, en-GB or nb-NO)"
    $val = $val.Trim().ToLower();
    if ($val -eq "sv-se") { return "sv-SE" }
    if ($val -eq "en-gb") { return "en-GB" }
    if ($val -eq "nb-no") { return "nb-NO" }
    Write-Host "Invalid collation, expected sv-SE, en-GB or nb-NO"
    return Collation $message
}
function Get-BroadcasterUrl
{
    param($instr)
    if ($instr) { $instr = " $instr" }
    $input = Read-Host "> Enter the URL or hostname of the Broadcaster$instr"
    $input = $input.Trim();
    if ( $input.StartsWith("@")) {
        # Use input as-is
        $input = $input.SubString(1)
    }
    elseif (!$input.StartsWith("https://")) {
        # Build from a partial URL or conventional hostname
        if ( $input.Contains(".")) {
            # It's a partial URL
            $input = "https://$input"
        }
        else {
            # It's a hostname
            $input = "https://broadcaster.$input.heads-api.com"
        }
    }
    if (!$input.EndsWith("/api")) {
        $input += "/api"
    }
    $r = $null
    if (![System.Uri]::TryCreate($input, 'Absolute', [ref]$r)) {
        Write-Host "Invalid URI format. Try again."
        return Get-BroadcasterUrl
    }
    try {
        $options = irm $input -Method "OPTIONS" -TimeoutSec 3
        if (($options.Status -eq "success") -and ($options.Data[0].Resource -eq "RESTable.AvailableResource")) {
            Write-Host "That Broadcaster exists! 🎉" -ForegroundColor Green
            return $input
        }
    }
    catch { }
    Write-Host "Warning: Could not verify if a Broadcaster exists at $input" -ForegroundColor Yellow
    return $input
}

Write-Host
Write-Host "This tool will help create a Broadcaster install script!" -ForegroundColor Green
Write-Host -NoNewline "To quit at any time, press "
Write-Host -ForegroundColor Yellow "Ctrl+C"
Write-Host

$bc = Get-BroadcasterUrl
$token = Read-Host "> Now enter the install token" -MaskInput
$script = @()
if (Yes "> Should we first uninstall existing client software, if present?") {
    if (Yes "--> Also uninstall legacy (SUS/RA) client software?") {
        $script += "irm raw.githubusercontent.com/byheads/util/main/u/legacy|iex"
    }
    $script += "irm raw.githubusercontent.com/byheads/util/main/u/all|iex"
}
if (Yes "> Install Receiver?") {
    $script += "irm `"`$u/product=Receiver`" @o|iex"
}
if (Yes "> Install WpfClient?") {
    $part = "product=WpfClient"
    if (Yes "--> Install as a manual client?") {
        $label = Label
        $installPath = [System.Uri]::EscapeDataString("C:\ProgramData\Heads\$label")
        $part += "&installPath=$installPath"
        $shortcutLabel = [System.Uri]::EscapeDataString("Heads Retail - $label")
        $part += "&shortcutLabel=$shortcutLabel"
    }
    $part += "&usePosServer=" + (Yes "--> Connect client to local POS Server?")
    $part += "&useArchiveServer=" + (Yes "--> Connect client to central Archive Server?")
    $script += "irm `"`$u/$part`" @o|iex"
}
if (Yes "> Install POS Server?") {
    $part = "product=PosServer"
    $part += "&createDump=" + (Yes "--> Create a dump of an existing POS-server?")
    $part += "&collation=" + (Collation "--> Enter database collation, e.g. sv-SE")
    $part += "&databaseImageSize=" + (Num "--> Enter database image size in MB (or enter for 1024)" 1024)
    $part += "&databaseLogSize=" + (Num "--> Enter database log size in MB (or enter for 1024)" 1024)
    $script += "irm `"`$u/$part`" @o|iex"
}
$arr = $script | %{ "{$_}" } | Join-String -Separator ","
Write-Host
Write-Host "# Here's your install script! Run it in PowerShell as administrator on a client computer:"
Write-Host
Write-Host "`$o=@{He=@{Authorization=`"Bearer $token`"}};`$u=`"$bc/install`";$arr|%{try{&`$_}catch{echo `$_;break}}"
Write-Host
Write-Host "# End of script"
Write-Host
