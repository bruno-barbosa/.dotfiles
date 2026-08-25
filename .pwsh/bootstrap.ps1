<#
.SYNOPSIS
    Windows arm of the dotfiles bootstrap -- the counterpart to dotfiles.sh.
.DESCRIPTION
    Installs scoop packages listed under setup.packages.windows in
    .config/config.yaml, installs the PowerShell modules, and points
    $PROFILE at .pwsh/profile.ps1.
    Safe to re-run; every step is idempotent.
.EXAMPLE
    .\.pwsh\bootstrap.ps1
    .\.pwsh\bootstrap.ps1 -SkipPackages
#>
[CmdletBinding()]
param(
    [switch]$SkipPackages,
    [switch]$SkipModules,
    [switch]$SkipProfile
)

$ErrorActionPreference = 'Stop'
$DotfilesRoot = Split-Path $PSScriptRoot -Parent

function Say  { param($m) Write-Host "  ==> $m" -ForegroundColor Cyan }
function Ok   { param($m) Write-Host "  [ok] $m" -ForegroundColor Green }
function Warn { param($m) Write-Host "  [!!] $m" -ForegroundColor Yellow }

Write-Host ""
Write-Host "  dotfiles :: windows bootstrap" -ForegroundColor Magenta
Write-Host "  root: $DotfilesRoot"
Write-Host ""

# ------------------------------------------------------------------ scoop
if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
    Say "installing scoop"
    Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
    Ok "scoop installed"
} else { Ok "scoop present" }

# --------------------------------------------- packages from config.yaml
function Get-WindowsPackages {
    param([string]$YamlPath)
    $lines = [System.IO.File]::ReadAllText($YamlPath) -split "\r?\n"
    $inSection = $false
    $pkgs = @()
    foreach ($line in $lines) {
        if ($line -match '^\s{4}windows:\s*$') { $inSection = $true; continue }
        if ($inSection) {
            # any other key at the same indent ends the section
            if ($line -match '^\s{4}\S+:\s*$') { break }
            if ($line -match '^\s{6}-\s+(\S+)\s*$') { $pkgs += $Matches[1] }
        }
    }
    return $pkgs
}

if (-not $SkipPackages) {
    $yaml = Join-Path $DotfilesRoot '.config\config.yaml'
    $packages = Get-WindowsPackages -YamlPath $yaml
    Say "$($packages.Count) packages listed in config.yaml"

    # fonts live in a separate bucket
    if ($packages -match 'NF$|Nerd') {
        if ((scoop bucket list | Out-String) -notmatch 'nerd-fonts') {
            Say "adding nerd-fonts bucket"
            scoop bucket add nerd-fonts | Out-Null
        }
        Ok "nerd-fonts bucket present"
    }

    $installed = (scoop list 6>$null | Out-String)
    foreach ($p in $packages) {
        if ($installed -match "(?m)^\s*$([regex]::Escape($p))\s") {
            Ok "$p already installed"
        } else {
            Say "installing $p"
            try { scoop install $p | Out-Null; Ok "$p" }
            catch { Warn "$p failed: $($_.Exception.Message)" }
        }
    }
}

# --------------------------------------------------------- PS modules
if (-not $SkipModules) {
    # PSGallery on Windows PowerShell 5.1 needs TLS 1.2 explicitly
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    if (-not (Get-PackageProvider -Name NuGet -ErrorAction SilentlyContinue)) {
        Say "installing NuGet provider"
        Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -Scope CurrentUser | Out-Null
    }
    Set-PSRepository -Name PSGallery -InstallationPolicy Trusted -ErrorAction SilentlyContinue

    # 5.1 ships PSReadLine 2.0.0 in-box; -SkipPublisherCheck is required to replace it
    if ((Get-Module PSReadLine -ListAvailable | Sort-Object Version -Descending |
         Select-Object -First 1).Version -lt [version]'2.2') {
        Say "upgrading PSReadLine (predictive intellisense)"
        Install-Module PSReadLine -MinimumVersion 2.3.4 -SkipPublisherCheck -Force -Scope CurrentUser -AllowClobber
    }
    Ok "PSReadLine $((Get-Module PSReadLine -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1).Version)"

    if (-not (Get-Module PSFzf -ListAvailable)) {
        Say "installing PSFzf"
        Install-Module PSFzf -Force -Scope CurrentUser -AllowClobber
    }
    Ok "PSFzf present"
}

# ------------------------------------------------------------- $PROFILE
if (-not $SkipProfile) {
    $profileDir = Split-Path $PROFILE -Parent
    if (-not (Test-Path $profileDir)) { New-Item -ItemType Directory $profileDir -Force | Out-Null }

    # A shim rather than a symlink: symlinks on Windows need admin or
    # Developer Mode, and this survives both.
    $shim = @"
`$env:DOTFILES = '$DotfilesRoot'
. (Join-Path `$env:DOTFILES '.pwsh\profile.ps1')
"@
    if ((Test-Path $PROFILE) -and ((Get-Content $PROFILE -Raw) -notmatch [regex]::Escape('.pwsh\profile.ps1'))) {
        Copy-Item $PROFILE "$PROFILE.pre-dotfiles.bak" -Force
        Warn "existing profile backed up to $PROFILE.pre-dotfiles.bak"
    }
    [System.IO.File]::WriteAllText($PROFILE, $shim, (New-Object System.Text.UTF8Encoding($false)))
    Ok "profile -> $PROFILE"
}

# ----------------------------------------------------------- git config
# Include the repo gitconfig rather than copying it, so aliases, hooks,
# the commit template and the delta pager all come from version control.
# It also sets core.autocrlf=false, which keeps shell scripts LF on Windows.
if (Get-Command git -ErrorAction SilentlyContinue) {
    $repoGitConfig = (Join-Path $DotfilesRoot '.config\git\.gitconfig') -replace '\\', '/'
    $current = (git config --global --get-all include.path) 2>$null
    if ($current -notcontains $repoGitConfig) {
        git config --global --add include.path $repoGitConfig
        Ok "git include -> $repoGitConfig"
    } else { Ok "git include already set" }
}
# ------------------------------------------------------------ bat theme
if (Get-Command bat -ErrorAction SilentlyContinue) {
    $batThemes = Join-Path (& bat --config-dir).Trim() 'themes'
    if (-not (Test-Path $batThemes)) { New-Item -ItemType Directory $batThemes -Force | Out-Null }
    & bat cache --build 2>&1 | Out-Null
    Ok "bat theme cache built"
}

Write-Host ""
Ok "done -- open a new terminal tab"
Write-Host "  Windows Terminal settings are NOT applied automatically."
Write-Host "  See .pwsh/windows-terminal.md to merge them."
Write-Host ""