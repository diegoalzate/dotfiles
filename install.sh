#!/bin/bash
set -e

echo "=== Dotfiles Linux/WSL Install Script ==="

# Check if running on Linux
if [[ "$(uname)" != "Linux" ]]; then
    echo "This script is for Linux/WSL only. On macOS, use 'make install'."
    exit 1
fi

# Detect package manager
if command -v apt &> /dev/null; then
    PKG_MANAGER="apt"
elif command -v dnf &> /dev/null; then
    PKG_MANAGER="dnf"
elif command -v pacman &> /dev/null; then
    PKG_MANAGER="pacman"
else
    echo "Unsupported package manager. Please install packages manually."
    exit 1
fi

echo "Detected package manager: $PKG_MANAGER"

# Install base packages
echo ""
echo "=== Installing base packages ==="
case $PKG_MANAGER in
    apt)
        sudo apt update
        sudo apt install -y zsh git curl wget unzip build-essential
        ;;
    dnf)
        sudo dnf install -y zsh git curl wget unzip gcc gcc-c++ make
        ;;
    pacman)
        sudo pacman -S --noconfirm zsh git curl wget unzip base-devel
        ;;
esac

# Install zsh as default shell
if [[ "$SHELL" != *"zsh"* ]]; then
    echo ""
    echo "=== Setting zsh as default shell ==="
    chsh -s $(which zsh)
fi

# Install starship
if ! command -v starship &> /dev/null; then
    echo ""
    echo "=== Installing starship ==="
    curl -sS https://starship.rs/install.sh | sh -s -- -y
fi

# Install fzf
if ! command -v fzf &> /dev/null; then
    echo ""
    echo "=== Installing fzf ==="
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install --all
fi

# Install zoxide
if ! command -v zoxide &> /dev/null; then
    echo ""
    echo "=== Installing zoxide ==="
    curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
fi

# Install fnm (Node version manager)
if ! command -v fnm &> /dev/null; then
    echo ""
    echo "=== Installing fnm ==="
    curl -fsSL https://fnm.vercel.app/install | bash -s -- --skip-shell
fi

# Install pnpm
if ! command -v pnpm &> /dev/null; then
    echo ""
    echo "=== Installing pnpm ==="
    curl -fsSL https://get.pnpm.io/install.sh | sh -
fi

# Install lazygit
if ! command -v lazygit &> /dev/null; then
    echo ""
    echo "=== Installing lazygit ==="
    LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
    curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
    tar xf lazygit.tar.gz lazygit
    sudo install lazygit /usr/local/bin
    rm lazygit lazygit.tar.gz
fi

# Install Go
if ! command -v go &> /dev/null; then
    echo ""
    echo "=== Installing Go ==="
    GO_VERSION=$(curl -s https://go.dev/VERSION?m=text | head -1)
    curl -Lo go.tar.gz "https://go.dev/dl/${GO_VERSION}.linux-amd64.tar.gz"
    sudo rm -rf /usr/local/go
    sudo tar -C /usr/local -xzf go.tar.gz
    rm go.tar.gz
    export PATH=$PATH:/usr/local/go/bin
    echo "Go installed: $(go version)"
fi

# Install bun
if ! command -v bun &> /dev/null; then
    echo ""
    echo "=== Installing bun ==="
    curl -fsSL https://bun.sh/install | bash
fi

# Symlink .zshrc
echo ""
echo "=== Linking .zshrc ==="
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ -f ~/.zshrc && ! -L ~/.zshrc ]]; then
    echo "Backing up existing .zshrc to .zshrc.backup"
    mv ~/.zshrc ~/.zshrc.backup
fi
ln -sf "$DOTFILES_DIR/.zshrc" ~/.zshrc

# Symlink VS Code settings
echo ""
echo "=== Linking VS Code settings ==="
mkdir -p ~/.config/Code/User
ln -sf "$DOTFILES_DIR/vscode-settings.json" ~/.config/Code/User/settings.json

echo ""
echo "=== Installation complete! ==="
echo "Please restart your terminal or run: source ~/.zshrc"
