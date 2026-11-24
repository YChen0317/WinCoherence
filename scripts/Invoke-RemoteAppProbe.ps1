#requires -Version 5.1
[CmdletBinding(DefaultParameterSetName = 'Inspect')]
param(
    [Parameter(Mandatory, ParameterSetName = 'Inspect')]
    [switch]$Inspect,

    [Parameter(Mandatory, ParameterSetName = 'Launch')]
    [ValidateNotNullOrEmpty()]
    [string]$RdpFile,

    [Parameter(ParameterSetName = 'Launch')]
    [switch]$ValidateOnly
)

$ErrorActionPreference = 'Stop'
$mstsc = Join-Path ([Environment]::SystemDirectory) 'mstsc.exe'
$client = Get-Item -LiteralPath $mstsc

if ($Inspect) {
    $os = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion'
    [pscustomobject]@{
        Edition = $os.EditionID
        DisplayVersion = $os.DisplayVersion
        Build = "$($os.CurrentBuild).$($os.UBR)"
        MstscVersion = $client.VersionInfo.FileVersion
    }
    return
}

$file = Get-Item -LiteralPath $RdpFile
if ($file -isnot [System.IO.FileInfo] -or $file.Extension -ne '.rdp') {
    throw 'Select a trusted, exported .rdp file.'
}
if ($file.Length -gt 1MB) {
    throw 'The .rdp file exceeds the 1 MiB probe limit.'
}

$settings = @{}
foreach ($line in [System.IO.File]::ReadAllLines($file.FullName)) {
    if ([string]::IsNullOrWhiteSpace($line)) { continue }
    if ($line -notmatch '^([^:]+):([isb]):(.*)$') {
        throw 'Malformed RDP setting.'
    }
    $key = $Matches[1].Trim()
    if ($settings.ContainsKey($key)) { throw "Duplicate RDP setting: $key" }
    $settings[$key] = "$($Matches[2]):$($Matches[3])"
}

if ($settings['remoteapplicationmode'] -ne 'i:1' -or
    $settings['remoteapplicationprogram'] -notmatch '^s:\|\|[^\s|].*$' -or
    $settings['full address'] -notmatch '^s:\S') {
    throw 'Expected RemoteApp mode, a published application alias and a server address.'
}

if ($ValidateOnly) {
    'RemoteApp file structure validated.'
    return
}

Start-Process -FilePath $client.FullName -ArgumentList ('"{0}"' -f $file.FullName)
'RemoteApp connection handed to mstsc. Verify the session in the client.'
