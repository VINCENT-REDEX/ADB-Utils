[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Version,

    [string]$Notes = "",

    [string]$Exe = "",

    [switch]$Mandatory,

    [switch]$Push
)

$ErrorActionPreference = "Stop"

if ($Version -notmatch '^\d+(\.\d+){0,3}$') {
    throw "Version must be dotted digits, for example 1.0.2."
}

$folder = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Split-Path -Parent $folder
$target = Join-Path $folder "REDEx-Loop.exe"
$manifest = Join-Path $folder "version.json"

if (-not $Exe) {
    if ($env:REDEXLOOP_BUILD) {
        $Exe = $env:REDEXLOOP_BUILD
    }
    elseif (Test-Path (Join-Path $folder "REDEx-Loop.exe")) {
        $Exe = Join-Path $folder "REDEx-Loop.exe"
    }
    else {
        throw "Pass -Exe <path to Release\REDEx-Loop.exe> or set REDEXLOOP_BUILD."
    }
}

$Exe = (Resolve-Path -LiteralPath $Exe).Path
$info = (Get-Item -LiteralPath $Exe).VersionInfo
Write-Host "Source : $Exe"
Write-Host "Build  : $($info.FileVersion)"

if ($info.FileVersion -and -not $info.FileVersion.StartsWith($Version)) {
    Write-Warning "The executable reports $($info.FileVersion), but the manifest will say $Version."
}

Copy-Item -LiteralPath $Exe -Destination $target -Force
$hash = (Get-FileHash -LiteralPath $target -Algorithm SHA256).Hash.ToLowerInvariant()

$entry = [ordered]@{
    version   = $Version
    url       = "https://raw.githubusercontent.com/VINCENT-REDEX/ADB-Utils/main/REDEx-Loop/REDEx-Loop.exe"
    sha256    = $hash
    notes     = $Notes
    mandatory = [bool]$Mandatory
}

$json = $entry | ConvertTo-Json -Depth 3
$utf8 = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($manifest, $json + "`n", $utf8)

Write-Host "Target : $target"
Write-Host "SHA256 : $hash"
Write-Host "Manifest written."

if ($Push) {
    if (-not (Test-Path (Join-Path $repoRoot ".git"))) {
        throw "Push requested, but $repoRoot is not a git checkout."
    }

    git -C $repoRoot add -- "REDEx-Loop/REDEx-Loop.exe" "REDEx-Loop/version.json"
    if ($LASTEXITCODE -ne 0) { throw "git add failed." }

    git -C $repoRoot commit -m "REDEx-Loop $Version"
    if ($LASTEXITCODE -ne 0) { throw "git commit failed." }

    git -C $repoRoot push
    if ($LASTEXITCODE -ne 0) { throw "git push failed." }

    Write-Host "Published REDEx-Loop $Version."
}
