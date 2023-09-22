if ($PSVersionTable.PSVersion.Major -lt 7) {
    return "Install Script Maker requires PowerShell 7 or later"
}

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
    $label = Read-Host "Enter a unique name for the manual client, e.g. Heads Testmiljö"
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
    $input = $input.Trim()
    if ( $input.StartsWith("@")) {
        # Use input as-is
        $input = $input.SubString(1)
    }
    elseif (!$input.StartsWith("http")) {
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

    if ( $input.StartsWith("http://")) {
        # Using unencrypted HTTP
        Write-Host "> You are using an unencrypted Broadcaster connection. Use Ctrl+C to abort..." -ForegroundColor Yellow
        $PSDefaultParameterValues['Invoke-RestMethod:AllowUnencryptedAuthentication'] = $true
    }

    try {
        $options = irm $input -Method "OPTIONS" -TimeoutSec 5
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
$token = $token.Trim()
$uris = @()
if (Yes "> Should we first uninstall existing client software, if present?") {
    if (Yes "--> Also uninstall legacy (SUS/RA) client software?") {
        $uris += "'uninstall.legacy'"
    }
    $uris += "'uninstall.all'"
}
if (Yes "> Install Receiver?") {
    $uris += "'install/p=Receiver'"
}
$csa = $false
if (Yes "> Install WpfClient?") {
    $part = "p=WpfClient"
    if (Yes "--> Install as a manual client?") {
        $label = Label
        $installPath = [System.Uri]::EscapeDataString("C:\ProgramData\Heads\$label")
        $part += "&installPath=$installPath"
        $shortcutLabel = [System.Uri]::EscapeDataString("Heads Retail - $label")
        $part += "&shortcutLabel=$shortcutLabel"
    }
    $part += "&usePosServer=" + (Yes "--> Connect client to local POS Server?")
    $part += "&useArchiveServer=" + (Yes "--> Connect client to central Archive Server?")
    $uris += "'install/$part'"
}
elseif (Yes "> Install CustomerServiceApplication?") {
    $uris += "'install/p=CustomerServiceApplication'"
    $csa = $true
}
if (!$csa -and (Yes "> Install POS Server?")) {
    $part = "p=PosServer"
    $part += "&createDump=" + (Yes "--> Create a dump of an existing POS-server?")
    $part += "&collation=" + (Collation "--> Enter database collation, e.g. sv-SE")
    $part += "&databaseImageSize=" + (Num "--> Enter database image size in MB (or enter for 1024)" 1024)
    $part += "&databaseLogSize=" + (Num "--> Enter database log size in MB (or enter for 1024)" 1024)
    $uris += "'install/$part'"
}
$arr = $uris | Join-String -Separator ","
Write-Host
Write-Host "# Here's your install script! Run it in PowerShell as administrator on a client computer:"
Write-Host
Write-Host "$arr|%{try{irm('$bc/'+`$_)-He @{Authorization='Bearer $token'}|iex}catch{echo `$_;return}};"
Write-Host
Write-Host "# End of script"
Write-Host
