<#
.SYNOPSIS
    Windows arm of the dotfiles bootstrap -- the counterpart to dotfiles.sh.
.DESCRIPTION
    Installs scoop packages listed under setup.packages.windows in
    .config/config.yaml, installs the PowerShell modules, and points
    $PROFILE at .pwsh/profile.ps1.
    Safe to re-run; every step is idempotent.
.PARAMETER Update
    Counterpart to `dotfiles.sh --update`: refreshes scoop itself and upgrades
    every installed package before the usual idempotent steps run.
.PARAMETER MergeTerminalSettings
    Merges the profile defaults from .pwsh/windows-terminal.md into Windows
    Terminal's settings.json. Off by default because Terminal rewrites that
    file itself; see the doc for what gets changed.
.EXAMPLE
    .\.pwsh\bootstrap.ps1
    .\.pwsh\bootstrap.ps1 -Update
    .\.pwsh\bootstrap.ps1 -SkipPackages
    .\.pwsh\bootstrap.ps1 -MergeTerminalSettings
#>
[CmdletBinding()]
param(
    [switch]$Update,
    [switch]$SkipPackages,
    [switch]$SkipModules,
    [switch]$SkipProfile,
    [switch]$MergeTerminalSettings
)

$ErrorActionPreference = 'Stop'
$DotfilesRoot = Split-Path $PSScriptRoot -Parent

function Say  { param($m) Write-Host "  ==> $m" -ForegroundColor Cyan }
function Ok   { param($m) Write-Host "  [ok] $m" -ForegroundColor Green }
function Warn { param($m) Write-Host "  [!!] $m" -ForegroundColor Yellow }

Write-Host ""
Write-Host "  dotfiles :: windows bootstrap" -ForegroundColor Magenta
Write-Host "  root: $DotfilesRoot"
if ($Update) { Write-Host "  mode: UPDATE" -ForegroundColor Yellow }
Write-Host ""

# ------------------------------------------------------------------ scoop
if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
    Say "installing scoop"
    Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
    Ok "scoop installed"
} else { Ok "scoop present" }

# ----------------------------------------------------------- update mode
# `dotfiles.sh --update` refreshes brew/apt; this is the scoop equivalent.
# Runs before the install loop so newly-listed packages still get picked up.
if ($Update -and -not $SkipPackages) {
    Say "updating scoop and installed packages"
    try {
        scoop update  *>$null
        scoop update * 2>&1 | ForEach-Object { Write-Verbose $_ }
        Ok "scoop packages upgraded"
    } catch {
        Warn "scoop update failed: $($_.Exception.Message)"
    }
    try {
        scoop cleanup * *>$null
        Ok "old package versions cleaned up"
    } catch { }
}

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
    if ($Update) {
        Say "updating PSReadLine"
        try { Update-Module PSReadLine -Force -ErrorAction Stop } catch { Warn "PSReadLine update: $($_.Exception.Message)" }
    }
    Ok "PSReadLine $((Get-Module PSReadLine -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1).Version)"

    if (-not (Get-Module PSFzf -ListAvailable)) {
        Say "installing PSFzf"
        Install-Module PSFzf -Force -Scope CurrentUser -AllowClobber
    } elseif ($Update) {
        Say "updating PSFzf"
        try { Update-Module PSFzf -Force -ErrorAction Stop } catch { Warn "PSFzf update: $($_.Exception.Message)" }
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

# ------------------------------------------------- Windows Terminal (opt-in)
# Off by default: Terminal owns settings.json and rewrites it on every UI
# change. This merges into the existing document rather than replacing it --
# the scheme and theme are matched by name and updated in place, and only the
# four profiles.defaults keys the doc calls for are touched. Anything set
# through the GUI survives. A timestamped backup is written first regardless.
function Merge-TerminalSettings {
    param([string]$FragmentPath)

    $candidates = @(
        "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json",
        "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\settings.json",
        "$env:LOCALAPPDATA\Microsoft\Windows Terminal\settings.json"
    )
    $settingsPath = $candidates | Where-Object { Test-Path $_ } | Select-Object -First 1
    if (-not $settingsPath) {
        Warn "Windows Terminal settings.json not found - is it installed and launched once?"
        return
    }
    if (-not (Test-Path $FragmentPath)) {
        Warn "fragment not found: $FragmentPath"
        return
    }

    $frag = Get-Content $FragmentPath -Raw | ConvertFrom-Json
    $raw  = Get-Content $settingsPath -Raw
    try {
        $settings = $raw | ConvertFrom-Json
    } catch {
        Warn "settings.json did not parse - leaving it alone: $($_.Exception.Message)"
        return
    }

    $backup = "$settingsPath.pre-dotfiles.bak"
    Copy-Item $settingsPath $backup -Force
    Ok "backed up -> $backup"

    # -- schemes: replace the entry with our name, else append
    if (-not $settings.PSObject.Properties['schemes']) {
        $settings | Add-Member -NotePropertyName schemes -NotePropertyValue @()
    }
    $schemes = @($settings.schemes | Where-Object { $_.name -ne $frag.scheme.name })
    $settings.schemes = @($schemes + $frag.scheme)

    # -- themes: same treatment
    if (-not $settings.PSObject.Properties['themes']) {
        $settings | Add-Member -NotePropertyName themes -NotePropertyValue @()
    }
    $themes = @($settings.themes | Where-Object { $_.name -ne $frag.theme.name })
    $settings.themes = @($themes + $frag.theme)

    # -- top level
    foreach ($p in $frag.topLevel.PSObject.Properties) {
        if ($settings.PSObject.Properties[$p.Name]) { $settings.($p.Name) = $p.Value }
        else { $settings | Add-Member -NotePropertyName $p.Name -NotePropertyValue $p.Value }
    }

    # -- profiles.defaults
    if (-not $settings.PSObject.Properties['profiles']) {
        $settings | Add-Member -NotePropertyName profiles -NotePropertyValue ([pscustomobject]@{})
    }
    if (-not $settings.profiles.PSObject.Properties['defaults']) {
        $settings.profiles | Add-Member -NotePropertyName defaults -NotePropertyValue ([pscustomobject]@{})
    }
    foreach ($p in $frag.profileDefaults.PSObject.Properties) {
        if ($settings.profiles.defaults.PSObject.Properties[$p.Name]) {
            $settings.profiles.defaults.($p.Name) = $p.Value
        } else {
            $settings.profiles.defaults | Add-Member -NotePropertyName $p.Name -NotePropertyValue $p.Value
        }
    }

    # Depth 32: Terminal's actions/keybindings nest deeply and the default of 2
    # would silently flatten them to type names.
    $json = $settings | ConvertTo-Json -Depth 32
    [System.IO.File]::WriteAllText($settingsPath, $json, (New-Object System.Text.UTF8Encoding($false)))
    Ok "merged Catppuccin Mocha + Maple Mono NF -> $settingsPath"
    Write-Host "  restore with: Copy-Item '$backup' '$settingsPath' -Force"
}

if ($MergeTerminalSettings) {
    Say "merging Windows Terminal settings"
    Merge-TerminalSettings -FragmentPath (Join-Path $DotfilesRoot '.config\windows-terminal\catppuccin-mocha.json')
}

Write-Host ""
Ok "done -- open a new terminal tab"
if (-not $MergeTerminalSettings) {
    Write-Host "  Windows Terminal settings were NOT touched."
    Write-Host "  Run with -MergeTerminalSettings to apply them, or see"
    Write-Host "  .pwsh/windows-terminal.md to do it by hand."
}
Write-Host ""