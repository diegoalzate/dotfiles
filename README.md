# Dotfiles

Personal dotfiles for macOS and Linux/WSL development setups.

## Setup

```bash
git clone https://github.com/diegoalzate/dotfiles.git ~/dotfiles
cd ~/dotfiles
make install
```

`make install` auto-detects your OS:
- **macOS**: installs Homebrew (if needed), runs `brew bundle`, applies stow links
- **Linux/WSL (Ubuntu/apt)**: runs `install-linux.sh`, installs core tools, applies stow links

## Update

```bash
cd ~/dotfiles
make sync
```

## Useful commands

```bash
make stow         # Re-apply config links
make doctor       # Check/fix broken links
make save         # Export Brewfile (macOS only)
make brew         # Update brew packages (macOS only)
```

## Platform notes

- `Brewfile` is macOS-specific.
- Linux/WSL uses `install-linux.sh` instead of Homebrew.
- `.zshrc` now guards macOS-only settings (`brew`, `DYLD_LIBRARY_PATH`, mac-only pnpm path).
