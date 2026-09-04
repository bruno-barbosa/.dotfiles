# =====================================================================
#  .pwsh/profile.ps1  --  Windows arm of the dotfiles
#  Mirrors what .zsh/.zshrc does on macOS/Linux.
#  Loaded by $PROFILE, which is a two-line shim pointing here.
#  ASCII-only on purpose: Windows PowerShell 5.1 misreads UTF-8
#  files that have no BOM, so escapes are built from [char]27.
# =====================================================================

$ESC = [char]27
if (-not $env:DOTFILES) { $env:DOTFILES = Join-Path $HOME '.dotfiles' }

# ------------------------------------------------------- PATH (see .path.zsh)
function Add-ToPath {
    param([string]$Dir)
    if ((Test-Path $Dir) -and ($env:Path -split ';' -notcontains $Dir)) {
        $env:Path = "$Dir;$env:Path"
    }
}
# the git-* subcommands are plain shell scripts and run fine through the
# bash that ships with Git for Windows
Add-ToPath (Join-Path $env:DOTFILES '.config\git\subcommands')
Add-ToPath (Join-Path $HOME '.local\bin')
Add-ToPath (Join-Path $HOME '.cargo\bin')
Add-ToPath (Join-Path $HOME '.volta\bin')
Add-ToPath (Join-Path $HOME 'go\bin')

# ------------------------------------------------------------- init caching
# Several tools want a subprocess at every shell start purely to print a static
# init script. Cache that output, keyed on the binary's timestamp so an upgrade
# regenerates it, and dot-source the cache instead.
#
# The key means each upgrade produces a new filename, so prune the previous
# ones on the way past -- otherwise every starship/zoxide/volta upgrade leaves
# another file in ~/.cache/pwsh forever.
$script:PwshCacheDir = Join-Path $HOME '.cache\pwsh'

function Use-CachedInit {
    param(
        [string]$Prefix,          # e.g. 'starship-init'
        [string]$BinaryPath,      # keyed on this file's mtime
        [scriptblock]$Generate    # emits the init text
    )
    $stamp     = (Get-Item $BinaryPath).LastWriteTime.Ticks
    $cacheFile = Join-Path $script:PwshCacheDir "$Prefix-$stamp.ps1"

    if (-not (Test-Path $cacheFile)) {
        if (-not (Test-Path $script:PwshCacheDir)) {
            New-Item -ItemType Directory $script:PwshCacheDir -Force | Out-Null
        }
        (& $Generate) | Out-String | Set-Content -Path $cacheFile -Encoding UTF8
        # Only prune once we have a fresh file to replace them with.
        Get-ChildItem -Path $script:PwshCacheDir -Filter "$Prefix-*.ps1" -ErrorAction SilentlyContinue |
            Where-Object { $_.FullName -ne $cacheFile } |
            Remove-Item -Force -ErrorAction SilentlyContinue
    }
    return $cacheFile
}

# ------------------------------------------------------------------- prompt
# same starship.toml the zsh side uses -- one prompt on all three platforms
$env:STARSHIP_CONFIG = Join-Path $env:DOTFILES '.config\starship\starship.toml'
if ($starshipCmd = Get-Command starship -ErrorAction SilentlyContinue) {
    # `starship init powershell` returns a 128-char bootstrap that launches
    # starship a SECOND time with --print-full-init: two process spawns per
    # shell start, ~460ms on Windows PowerShell 5.1. Ask for the full init
    # once and cache it. Dot-sourcing the cache is ~90ms.
    try {
        . (Use-CachedInit -Prefix 'starship-init' -BinaryPath $starshipCmd.Source `
            -Generate { & $starshipCmd.Source init powershell --print-full-init })
    } catch {
        Invoke-Expression (&starship init powershell)
    }
}

# --------------------------------------------------------------- PSReadLine
# Windows PowerShell ships 2.0.0 in-box and loads it before this profile,
# so force the newer copy that actually supports predictions.
try { Import-Module PSReadLine -MinimumVersion 2.2 -Force -ErrorAction Stop } catch { }

# Everything below needs a real interactive console. When output is redirected
# (powershell -Command "..." from a script or CI) PSReadLine throws, so each
# block is guarded -- otherwise every non-interactive call spews errors.
if (Get-Module PSReadLine) {
    try {
        if ((Get-Module PSReadLine).Version -ge [version]'2.2') {
            Set-PSReadLineOption -PredictionSource History -ErrorAction Stop
            Set-PSReadLineOption -PredictionViewStyle ListView -ErrorAction Stop
        }
    } catch { }
    try {
        Set-PSReadLineOption -HistoryNoDuplicates -ErrorAction Stop
        Set-PSReadLineOption -HistorySearchCursorMovesToEnd -ErrorAction Stop
        Set-PSReadLineOption -MaximumHistoryCount 10000 -ErrorAction Stop
        Set-PSReadLineOption -BellStyle None -ErrorAction Stop
        # up/down filter history by what is already typed (matches .zshrc bindkey)
        Set-PSReadLineKeyHandler -Key UpArrow   -Function HistorySearchBackward -ErrorAction Stop
        Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward  -ErrorAction Stop
        Set-PSReadLineKeyHandler -Key Tab       -Function MenuComplete          -ErrorAction Stop
    } catch { }
    try {
        Set-PSReadLineOption -Colors @{
            Command          = "$ESC[38;2;203;166;247m"
            Keyword          = "$ESC[38;2;203;166;247m"
            Parameter        = "$ESC[38;2;148;226;213m"
            Operator         = "$ESC[38;2;137;220;235m"
            Variable         = "$ESC[38;2;250;179;135m"
            Number           = "$ESC[38;2;250;179;135m"
            String           = "$ESC[38;2;166;227;161m"
            Type             = "$ESC[38;2;249;226;175m"
            Member           = "$ESC[38;2;137;180;250m"
            Comment          = "$ESC[38;2;108;112;134m"
            Error            = "$ESC[38;2;243;139;168m"
            InlinePrediction = "$ESC[38;2;88;91;112m"
            ListPrediction   = "$ESC[38;2;127;132;156m"
        } -ErrorAction Stop
    } catch { }
}

# --------------------------------------------------------------------- fzf
$env:FZF_DEFAULT_OPTS = @(
    '--height=45%','--layout=reverse','--border=rounded','--info=inline',
    '--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8',
    '--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc',
    '--color=marker:#b4befe,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8'
) -join ' '

# Bound by hand rather than via Import-Module PSFzf: that module costs ~300ms
# at every shell start, whereas these ScriptBlocks cost nothing until the key
# is actually pressed.
if ((Get-Command fzf -ErrorAction SilentlyContinue) -and (Get-Module PSReadLine)) {
    try {
        Set-PSReadLineKeyHandler -Key 'Ctrl+r' -BriefDescription 'FuzzyHistory' -ScriptBlock {
            $histPath = (Get-PSReadLineOption).HistorySavePath
            if (-not (Test-Path $histPath)) { return }
            $lines = [System.IO.File]::ReadAllLines($histPath)
            [array]::Reverse($lines)
            $sel = $lines | Where-Object { $_.Trim() } | Select-Object -Unique |
                   fzf --prompt 'history> '
            if ($sel) {
                [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
                [Microsoft.PowerShell.PSConsoleReadLine]::Insert($sel)
            }
        } -ErrorAction Stop

        Set-PSReadLineKeyHandler -Key 'Ctrl+t' -BriefDescription 'FuzzyFile' -ScriptBlock {
            if (Get-Command fd -ErrorAction SilentlyContinue) {
                $sel = fd --type f --hidden --exclude .git | fzf --prompt 'file> '
            } else {
                $sel = Get-ChildItem -Recurse -File -ErrorAction SilentlyContinue |
                       ForEach-Object { $_.FullName.Substring($PWD.Path.Length + 1) } |
                       fzf --prompt 'file> '
            }
            if ($sel) { [Microsoft.PowerShell.PSConsoleReadLine]::Insert($sel) }
        } -ErrorAction Stop
    } catch { }
}

# ------------------------------------------------------------------ zoxide
if ($zoxideCmd = Get-Command zoxide -ErrorAction SilentlyContinue) {
    # Cached for the same reason as starship: the init is static, so there is
    # no need to spawn zoxide on every shell start.
    try {
        . (Use-CachedInit -Prefix 'zoxide-init' -BinaryPath $zoxideCmd.Source `
            -Generate { & $zoxideCmd.Source init powershell --cmd cd })
    } catch {
        Invoke-Expression (& { (zoxide init powershell --cmd cd | Out-String) })
    }
}

# --------------------------------------------------------------------- eza
if (Get-Command eza -ErrorAction SilentlyContinue) {
    Remove-Item Alias:ls -Force -ErrorAction SilentlyContinue
    function ls { eza --icons --group-directories-first @args }
    function ll { eza -l  --icons --group-directories-first --git @args }
    function la { eza -la --icons --group-directories-first --git @args }
    function lt { eza --tree --level=2 --icons --group-directories-first @args }
}

# --------------------------------------------------------------------- bat
# deliberately NOT aliased over cat: PowerShell's cat returns objects
# that scripts depend on.
if (Get-Command bat -ErrorAction SilentlyContinue) {
    $env:BAT_THEME = 'Catppuccin Mocha'
    function bcat { bat --style=full @args }
}

# ------------------------------------------------------------------- volta
if ($voltaCmd = Get-Command volta -ErrorAction SilentlyContinue) {
    $voltaHome = Join-Path $HOME '.volta'
    if (Test-Path $voltaHome) { $env:VOLTA_HOME = $voltaHome }

    # `volta completions powershell` emits ~15KB and costs a subprocess on
    # every shell start, which is noticeable on Windows PowerShell 5.1.
    # No subprocess on the common path.
    try {
        . (Use-CachedInit -Prefix 'volta-completions' -BinaryPath $voltaCmd.Source `
            -Generate { & $voltaCmd.Source completions powershell })
    } catch { }
}

# ---------------------------------------------------------------------- uv
# Python toolchain -- the counterpart to the uv block in .zsh/.tools.zsh.
# uv needs no init hook (no shims, single binary), so this is completions
# only, cached like the others to keep them off the startup path.
if ($uvCmd = Get-Command uv -ErrorAction SilentlyContinue) {
    try {
        . (Use-CachedInit -Prefix 'uv-completions' -BinaryPath $uvCmd.Source `
            -Generate { & $uvCmd.Source generate-shell-completion powershell })
    } catch { }

    # uvx is a separate binary with its own completion namespace.
    if ($uvxCmd = Get-Command uvx -ErrorAction SilentlyContinue) {
        try {
            . (Use-CachedInit -Prefix 'uvx-completions' -BinaryPath $uvxCmd.Source `
                -Generate { & $uvxCmd.Source --generate-shell-completion powershell })
        } catch { }
    }
}
# ---------------------------------------------------- git aliases (.git.alias.zsh)
function gs  { git status @args }
function gd  { git diff @args }
function gl  { git log --oneline --graph --decorate @args }
function ga  { git add @args }
function gc  { git commit @args }
function gco { git checkout @args }
function gp  { git push @args }
function gpl { git pull @args }
function gb  { git branch @args }