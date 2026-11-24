#requires -Version 5.1
$ErrorActionPreference = 'Stop'
$probe = Join-Path $PSScriptRoot '../scripts/Invoke-RemoteAppProbe.ps1'
$inspect = & $probe -Inspect
if (!$inspect.Edition -or !$inspect.MstscVersion) { throw 'Missing environment metadata.' }
$inspect | Format-List

$fixture = Join-Path ([System.IO.Path]::GetTempPath()) ("WinCoherence {0}.rdp" -f [guid]::NewGuid())
$profile = @('full address:s:rdsh.example.invalid', 'remoteapplicationmode:i:1', 'remoteapplicationprogram:s:||Notepad')

$launches = [System.Collections.Generic.List[object]]::new()

function Start-Process([string]$FilePath, [string[]]$ArgumentList) {
    $launches.Add([pscustomobject]@{ FilePath = $FilePath; Arguments = $ArgumentList })
}
function Assert-Rejected([string[]]$Lines, [string]$Expected) {
    Set-Content -LiteralPath $fixture -Value $Lines -Encoding Unicode
    try {
        & $probe -RdpFile $fixture -ValidateOnly
    } catch {
        if ($_.Exception.Message -notlike "$Expected*") { throw }
        return
    }
    throw "Expected rejection: $Expected"
}

try {
    Set-Content -LiteralPath $fixture -Value $profile -Encoding Unicode
    $result = & $probe -RdpFile $fixture -ValidateOnly
    if ($result -ne 'RemoteApp file structure validated.') { throw 'Expected a valid profile.' }
    if ($launches.Count -ne 0) { throw 'Validation unexpectedly launched a process.' }

    $before = (Get-FileHash -LiteralPath $fixture).Hash
    $null = & $probe -RdpFile $fixture
    $expectedClient = Join-Path ([Environment]::SystemDirectory) 'mstsc.exe'
    if ($launches.Count -ne 1 -or $launches[0].FilePath -ne $expectedClient -or
        $launches[0].Arguments.Count -ne 1 -or $launches[0].Arguments[0] -cne ('"{0}"' -f $fixture)) {
        throw 'Expected exactly one mstsc launch request with the quoted original profile path.'
    }
    if ((Get-FileHash -LiteralPath $fixture).Hash -ne $before) {
        throw 'The launcher changed the original RDP profile.'
    }
    Assert-Rejected ($profile + 'RemoteApplicationMode:i:0') 'Duplicate RDP setting'
    Assert-Rejected ($profile[0], 'remoteapplicationmode:i:0', $profile[2]) 'Expected RemoteApp mode'
    Assert-Rejected ($profile[0], $profile[1], 'remoteapplicationprogram:s:notepad.exe') 'Expected RemoteApp mode'
    Assert-Rejected ($profile[1], $profile[2]) 'Expected RemoteApp mode'
    Assert-Rejected ($profile + 'malformed') 'Malformed RDP setting'
    'PASS: environment inspection, one valid profile, five invalid profiles and mstsc launch arguments.'
} finally {
    Remove-Item -LiteralPath $fixture -ErrorAction SilentlyContinue
}
