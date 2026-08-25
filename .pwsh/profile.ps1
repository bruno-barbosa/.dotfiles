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

# ------------------------------------------------------------------- prompt
# same starship.toml the zsh side uses -- one prompt on all three platforms
$env:STARSHIP_CONFIG = Join-Path $env:DOTFILES '.config\starship\starship.toml'
if (Get-Command starship -ErrorAction SilentlyContinue) {
    Invoke-Expression (&starship init powershell)
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

if (Get-Module -ListAvailable PSFzf) {
    Import-Module PSFzf -ErrorAction SilentlyContinue
    try { Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r' -ErrorAction Stop } catch { }
}

# ------------------------------------------------------------------ zoxide
if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    Invoke-Expression (& { (zoxide init powershell --cmd cd | Out-String) })
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
    # Cache it, keyed on the binary's timestamp so a volta upgrade
    # regenerates it automatically. No subprocess on the common path.
    try {
        $stamp     = (Get-Item $voltaCmd.Source).LastWriteTime.Ticks
        $cacheDir  = Join-Path $HOME '.cache\pwsh'
        $cacheFile = Join-Path $cacheDir "volta-completions-$stamp.ps1"
        if (-not (Test-Path $cacheFile)) {
            if (-not (Test-Path $cacheDir)) { New-Item -ItemType Directory $cacheDir -Force | Out-Null }
            (& volta completions powershell) | Out-String |
                Set-Content -Path $cacheFile -Encoding UTF8
        }
        . $cacheFile
    } catch { }
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