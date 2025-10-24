# Dotfiles Repository Guidelines

## Build/Test Commands
- `make install` - First-time setup with Homebrew, stow, and zinit
- `make sync` - Pull from repo and apply to system (includes brew update/upgrade)
- `make save` - Save current system state to Brewfile
- `make stow` - Apply config files using GNU stow
- `make brew` - Update Homebrew packages only

## Code Style Guidelines
- Shell scripts: Use zsh syntax, follow existing patterns in .zshrc
- Configuration files: Use JSON for Zed settings, maintain existing structure
- Imports: Use zinit for zsh plugin management, follow existing load order
- Formatting: Zed auto-formats on save, use consistent indentation
- Naming: Use lowercase with underscores for files, follow existing conventions
- Error handling: Use `|| true` for non-critical commands in Makefile
- Paths: Use absolute paths in stow operations, maintain ~ expansion in shell scripts