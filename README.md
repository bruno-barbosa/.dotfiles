# 🚀 Cross-Platform Development Dotfiles

Modern, comprehensive dotfiles setup for macOS and Linux development environments. Features automated installation, configuration management, and essential development tools.

## ✨ Features

### 🔧 **Core Components**

- **Cross-Platform Support**: Works on macOS (Homebrew) and Linux (apt)
- **Interactive Installation**: User prompts for selective component installation
- **Configuration Management**: YAML-based package configuration
- **Error Handling**: Robust error logging and non-blocking failures
- **Update Mode**: Refresh existing configurations and update packages

### 🛠 **Development Tools**

#### **Version Managers** (Optional)

- **Volta**: Modern Node.js toolchain manager (replaces nvm)
- **RVM**: Ruby Version Manager with gem configuration
- **pyenv**: Python Version Manager with pip packages

#### **Shell Environment**

- **Zsh Configuration**: Custom `.zshrc` with oh-my-zsh
- **Powerlevel10k Theme**: Modern, fast, and feature-rich prompt
- **Essential Plugins**: zsh-autosuggestions, zsh-syntax-highlighting
- **Tmux Setup**: Terminal multiplexer configuration

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

### Installation

```bash
# Clone the repository
git clone --recursive https://github.com/bruno-barbosa/.dotfiles.git ~/.dotfiles

# Navigate to dotfiles directory
cd ~/.dotfiles

# Run the installer
./dotfiles.sh
```

### Update Existing Installation

```bash
cd ~/.dotfiles
./dotfiles.sh --update
```

## 📋 Requirements

### System Requirements

- **macOS**: macOS 10.15+ (Homebrew will be installed automatically)
- **Linux**: Ubuntu/Debian-based distributions with `apt`
- **Internet**: For downloading packages and plugins

### Automatic Shell Detection

The installer intelligently handles shell compatibility:

1. **Preferred**: Runs with Zsh if available (better associative array support)
2. **Fallback**: Uses Bash with automatic version upgrade if needed
3. **Error Handling**: Clear error messages if neither shell meets requirements

## 🎯 Installation Options

The installer provides interactive prompts for each component:

- **📦 Package Manager Setup**: Homebrew (macOS) or apt packages (Linux)
- **🐚 Shell Environment**: Zsh + oh-my-zsh + Powerlevel10k theme
- **🍎 Platform Defaults**: System preferences optimization (macOS only)
- **📝 Vim Editor Setup**: Vim with vim-plug and essential plugins
- **⚙️ Git Configuration**: User settings and global gitignore
- **🔄 Version Managers**: Volta (Node.js), RVM (Ruby), pyenv (Python)

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
      - python3-dev

    osx:
      - gh
      - docker
      - visual-studio-code

    gems:
      - bundler
      - rake
      - rubocop

    pip:
      - pip
      - black
      - pytest

    node:
      - typescript
      - eslint
      - prettier
```

### Shell Customization

- **Zsh**: Edit `.zsh/.zshrc` for shell configuration
- **Environment & PATH**: Modify `.zsh/.path.zsh` for PATH and environment variables
- **Platform Detection**: `.zsh/.platform.zsh` handles OS-specific settings
- **Functions**: Add custom functions to `.zsh/functions/` directory
- **Aliases**: Add custom aliases to `.zsh/aliases/` directory

### Vim Customization

- **Plugins**: Edit `.vim/.vimrc` to add/remove vim-plug plugins
- **Themes**: Multiple Dracula Pro variants available

## 🔄 Update Workflow

The dotfiles support selective updates:

- **Package Updates**: Updates Homebrew/apt packages
- **Version Manager Updates**: Updates Node.js, Ruby, Python environments
- **Plugin Updates**: Updates vim plugins via vim-plug
- **Configuration Refresh**: Re-links dotfiles and applies settings

## 🗂 Project Structure

```
.dotfiles/
├── dotfiles.sh           # Main installer script
├── bin/
│   ├── setup.sh          # Core setup functions
│   ├── bot/              # UI, error handling, config parsing, and utilities
│   ├── git/              # Git configuration
│   ├── node/             # Volta (Node.js) setup
│   ├── ruby/             # Ruby/RVM setup with permissions fix
│   ├── python/           # Python/pyenv setup
│   └── platform/         # Platform-specific (macOS/Linux)
├── .config/
│   ├── config.yaml       # Package configuration (YAML format)
│   ├── .gitconfig        # Git settings template
│   ├── .gitignore        # Global gitignore rules
│   └── .tmux.conf        # Tmux configuration
├── .zsh/
│   ├── .zshrc            # Zsh configuration with oh-my-zsh
│   ├── .sources.zsh      # Configuration file sourcing
│   ├── .path.zsh         # PATH and environment variables (platform-aware)
│   ├── .platform.zsh     # Platform detection and utilities
│   ├── aliases/          # Shell aliases
│   └── functions/        # Custom shell functions
└── .vim/
    ├── .vimrc            # Vim configuration with vim-plug
    └── colors/           # Dracula Pro themes
```

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

**Made with ❤️ for developers who value automated, consistent development environments across platforms.**
