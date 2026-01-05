# Dotfiles

Personal dotfiles for macOS and Linux/WSL development environment setup.

## macOS Setup

```bash
git clone https://github.com/diegoalzate/dotfiles.git ~/dotfiles
cd ~/dotfiles
make install
```

## Linux/WSL Setup

```bash
git clone https://github.com/diegoalzate/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

The install script will:
- Install base packages (zsh, git, curl, etc.)
- Set zsh as default shell
- Install CLI tools: starship, fzf, zoxide, fnm, pnpm, lazygit, go, bun
- Symlink `.zshrc` and VS Code settings

## Update

```bash
cd ~/dotfiles
make sync  # Pull from repo and apply to system
```

## macOS Only Commands

```bash
make save    # Save current Homebrew state to repo
make stow    # Re-apply config file symlinks
make brew    # Update Homebrew packages
make doctor  # Check and fix broken symlinks
```

## What's Included

| Tool | Description |
|------|-------------|
| zsh + zinit | Shell with plugin manager |
| starship | Cross-shell prompt |
| fzf | Fuzzy finder |
| zoxide | Smarter cd command |
| fnm | Fast Node.js version manager |
| pnpm | Fast npm alternative |
| lazygit | Terminal UI for git |
| go | Go programming language |
| bun | JavaScript runtime & toolkit |

## Editor Settings

- **macOS**: Zed (`~/.config/zed/settings.json`) + VS Code
- **Linux/WSL**: VS Code (`~/.config/Code/User/settings.json`)

The `c` alias opens:
- `zed` on macOS
- `code` on Linux/WSL
