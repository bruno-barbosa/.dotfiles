# 🚀 Cross-Platform Development Dotfiles

Modern, comprehensive dotfiles setup for macOS, Linux and Windows development environments. Features automated installation, configuration management, and essential development tools.

## ✨ Features

### 🔧 **Core Components**

- **Cross-Platform Support**: macOS (Homebrew), Linux (apt) and Windows (scoop)
- **One Prompt Everywhere**: starship, driven by a single `starship.toml` on all three platforms
- **Interactive Installation**: User prompts for selective component installation
- **Configuration Management**: YAML-based package configuration, shared by all three installers
- **Error Handling**: Robust error logging and non-blocking failures
- **Update Mode**: Refresh existing configurations and update packages

### 🛠 **Development Tools**

#### **Version Managers** (Optional)

- **Volta**: Modern Node.js toolchain manager (replaces nvm)
- **RVM**: Ruby Version Manager with gem configuration
- **uv**: Python toolchain manager - installs and pins CPython, resolves project dependencies, and keeps global CLI tools in isolated environments (pyenv + pip + pipx in one binary)

#### **Shell Environment**

- **Zsh Configuration**: Custom `.zshrc` with oh-my-zsh (macOS/Linux)
- **PowerShell Configuration**: `.pwsh/profile.ps1`, which mirrors `.zshrc` (Windows)
- **starship Prompt**: One `.config/starship/starship.toml` loaded by both shells
- **Modern CLI**: zoxide, eza, bat, fzf and delta, configured identically on every platform
- **Essential Plugins**: zsh-autosuggestions, zsh-syntax-highlighting; PSReadLine predictions on Windows
- **Tmux Setup**: Terminal multiplexer configuration (macOS/Linux)

#### **Editor Setup**

- **Vim Configuration**: Comprehensive `.vimrc` with vim-plug
- **Essential Plugins**: NERDTree, fzf, vim-airline, vim-fugitive, ALE
- **Dracula Theme**: Consistent color scheme across tools

#### **Git Integration**

- **Smart Configuration**: Detects existing settings, offers reconfiguration
- **Global Gitignore**: Cross-platform ignore patterns (macOS, Windows, Vim)
- **Enhanced Settings**: Developer-friendly git aliases and configurations

### 🎨 **macOS Enhancements** (macOS Only)

- **System Defaults**: Developer-optimized macOS preferences
- **Dock & Finder**: Enhanced productivity settings
- **Keyboard & Trackpad**: Fast key repeat, tap-to-click
- **Safari Developer Tools**: Web development optimizations

### 📦 **Package Management**

- **Automated Installation**: Platform-specific package managers
- **Configurable Packages**: Defined in `config.yaml` with YAML parsing
- **Language Support**: Development libraries and tools
- **GUI Applications**: macOS cask support for applications
- **Robust Parsing**: Uses `yq` with automatic installation if not available

## 🚀 Quick Start

### Installation (macOS / Linux)

```bash
# Clone the repository
git clone https://github.com/bruno-barbosa/.dotfiles.git ~/.dotfiles

# Navigate to dotfiles directory
cd ~/.dotfiles

# Run the installer
./dotfiles.sh
```

The checkout does not have to live at `~/.dotfiles` — the installer derives its
own root. It links `~/.dotfiles` at wherever you cloned, because git config has
no variable expansion and `.gitconfig` has to name the hooks path literally.

### Installation (Windows)

```powershell
git clone https://github.com/bruno-barbosa/.dotfiles.git $HOME\.dotfiles
cd $HOME\.dotfiles
.\.pwsh\bootstrap.ps1
```

Installs scoop packages from the same `config.yaml`, upgrades PSReadLine, and
points `$PROFILE` at `.pwsh/profile.ps1`. Windows Terminal settings are left
manual — see [.pwsh/windows-terminal.md](.pwsh/windows-terminal.md).

### Update Existing Installation

```bash
cd ~/.dotfiles && ./dotfiles.sh --update      # macOS / Linux
```

```powershell
cd $HOME\.dotfiles; .\.pwsh\bootstrap.ps1 -Update   # Windows
```

## 📋 Requirements

### System Requirements

- **macOS**: macOS 10.15+ (Homebrew will be installed automatically)
- **Linux**: Ubuntu/Debian-based distributions with `apt`
- **Windows**: Windows 10/11 with PowerShell 5.1+ (scoop will be installed automatically)
- **Internet**: For downloading packages and plugins

### Automatic Shell Detection

The installer intelligently handles shell compatibility:

1. **Preferred**: Runs with Zsh if available (better associative array support)
2. **Fallback**: Uses Bash with automatic version upgrade if needed
3. **Error Handling**: Clear error messages if neither shell meets requirements

## 🎯 Installation Options

The installer provides interactive prompts for each component:

- **📦 Package Manager Setup**: Homebrew (macOS), apt (Linux) or scoop (Windows)
- **🐚 Shell Environment**: Zsh + oh-my-zsh + starship prompt
- **🍎 Platform Defaults**: System preferences optimization (macOS only)
- **📝 Vim Editor Setup**: Vim with vim-plug and essential plugins
- **⚙️ Git Configuration**: User settings and global gitignore
- **🔄 Version Managers**: Volta (Node.js), RVM (Ruby), uv (Python)

## 📁 Configuration

### Package Management

Edit `.config/config.yaml` to customize packages:

```yaml
setup:
  packages:
    shared: # Cross-platform packages
      - curl
      - git
      - vim
      - tmux

    debian:
      - build-essential
      - libffi-dev

    osx:
      - gh
      - docker
      - visual-studio-code

    gems:
      - bundler
      - rake
      - rubocop

    python: # global CLI tools, installed with `uv tool install`
      - ruff
      - black
      - pytest

    node:
      - typescript
      - eslint
      - prettier
```

### Python (uv)

There is no pyenv, no global pip and no `python3 -m venv` here — `uv` covers
all three, and it is the only Python thing the installer puts on the machine.

```bash
uv python install 3.13     # install an interpreter
uv init myproject          # start a project (writes pyproject.toml)
uv add requests            # add a dependency, lockfile and venv handled for you
uv run pytest              # run inside the project environment
uvx ruff check .           # run a tool without installing it
uv tool install ruff       # install a CLI tool globally, in its own venv
```

Global CLI tools live under `setup.packages.python` in `.config/config.yaml`
and are installed with `uv tool install`. Libraries do not belong there — they
belong to a project (`uv add`) or to a one-off run (`uv run --with`).

Aliases are in `.zsh/aliases/.python.alias.zsh`; `py` opens a REPL on the
managed interpreter without needing a project.

### Shell Customization

- **Zsh**: Edit `.zsh/.zshrc` for shell configuration
- **Modern CLI + prompt**: `.zsh/.tools.zsh` (sourced last, after oh-my-zsh, which would otherwise clobber starship)
- **PowerShell**: `.pwsh/profile.ps1` is the Windows counterpart to `.zshrc` + `.tools.zsh`
- **Prompt**: `.config/starship/starship.toml` — one file, all three platforms
- **Environment & PATH**: Modify `.zsh/.path.zsh` for PATH and environment variables
- **Platform Detection**: `.zsh/.platform.zsh` handles OS-specific settings
- **Functions**: Add custom functions to `.zsh/functions/` directory
- **Aliases**: Add custom aliases to `.zsh/aliases/` directory

Changing the prompt or a CLI tool means editing both `.zsh/.tools.zsh` and
`.pwsh/profile.ps1` — they are deliberate mirrors of each other.

### Vim Customization

- **Plugins**: Edit `.vim/.vimrc` to add/remove vim-plug plugins
- **Themes**: Multiple Dracula Pro variants available

## 🔄 Update Workflow

The dotfiles support selective updates:

- **Package Updates**: Updates Homebrew/apt packages (`./dotfiles.sh --update`) or scoop packages (`.\.pwsh\bootstrap.ps1 -Update`)
- **Version Manager Updates**: Updates Node.js, Ruby, Python environments
- **Plugin Updates**: Updates vim plugins via vim-plug
- **Configuration Refresh**: Re-links dotfiles and applies settings

## 🗂 Project Structure

```
.dotfiles/
├── dotfiles.sh           # Main installer script (macOS/Linux)
├── bin/
│   ├── setup.sh          # Core setup functions
│   ├── bot/              # UI, error handling, config parsing, and utilities
│   ├── git/              # Git configuration
│   ├── node/             # Volta (Node.js) setup
│   ├── ruby/             # Ruby/RVM setup with permissions fix
│   ├── python/           # Python toolchain setup (uv)
│   └── platform/         # Platform-specific (macOS/Linux/fonts)
├── .pwsh/                # Windows arm
│   ├── bootstrap.ps1     # Installer (counterpart to dotfiles.sh)
│   ├── profile.ps1       # PowerShell profile (mirrors .zshrc + .tools.zsh)
│   └── windows-terminal.md  # Manual Windows Terminal settings merge
├── .config/
│   ├── config.yaml       # Package configuration (YAML format, all platforms)
│   ├── starship/         # Prompt config, shared by zsh and PowerShell
│   ├── ghostty/          # Ghostty terminal config
│   ├── git/              # gitconfig, hooks, subcommands, delta theme
│   └── .tmux.conf        # Tmux configuration
├── .zsh/
│   ├── .zshrc            # Zsh configuration with oh-my-zsh
│   ├── .tools.zsh        # starship + modern CLI init (sourced last)
│   ├── .sources.zsh      # Configuration file sourcing
│   ├── .path.zsh         # PATH and environment variables (platform-aware)
│   ├── .platform.zsh     # Platform detection and utilities
│   ├── aliases/          # Shell aliases
│   └── functions/        # Custom shell functions
└── .vim/
    ├── .vimrc            # Vim configuration with vim-plug
    └── colors/           # Dracula Pro themes
```

`.vim/plugged/` and `.vim/autoload/plug.vim` are deliberately untracked —
vim-plug clones them, and the installer downloads plug.vim on a fresh machine.

## 🎨 Customization

### Adding New Packages

1. Edit `.config/config.yaml`
2. Add packages to appropriate platform sections
3. Run `./dotfiles.sh --update`

### Vim Plugin Management

```vim
" Add to .vim/.vimrc
Plug 'your-username/your-plugin'
```

Then run `:PlugInstall` in vim or use the installer's update option.

## 🤝 Contributing

Feel free to fork this repository and customize it for your needs. The modular structure makes it easy to:

- Add new package managers
- Include additional development tools
- Customize platform-specific settings
- Extend the configuration system

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

**Made with ❤️ for developers who values automation.**
