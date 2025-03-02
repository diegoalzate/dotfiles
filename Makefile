.PHONY: help install update stow unstow brew-update brew-dump zsh-reload

# Default target
help:
	@echo "Available commands:"
	@echo "  make install     - First-time setup (Homebrew, dependencies, stow, zinit)"
	@echo "  make update      - Update dotfiles (git pull, brew update, re-stow)"
	@echo "  make stow        - Symlink dotfiles to home directory"
	@echo "  make unstow      - Remove symlinks from home directory"
	@echo "  make brew-update - Update Homebrew packages"
	@echo "  make brew-dump   - Update Brewfile with current packages"
	@echo "  make zsh-reload  - Reload ZSH configuration"

# First-time installation
install:
	@echo "Installing dotfiles..."
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || true
	brew bundle
	stow -v -t ~ .
	bash -c "$(curl --fail --show-error --silent --location https://raw.githubusercontent.com/zdharma-continuum/zinit/HEAD/scripts/install.sh)" || true
	@echo "Installation complete! Please restart your terminal or run 'source ~/.zshrc'"

# Update dotfiles
update:
	@echo "Updating dotfiles..."
	git pull
	brew update
	brew upgrade
	stow -R -v -t ~ .
	@echo "Update complete! Please restart your terminal or run 'source ~/.zshrc'"

# Stow dotfiles
stow:
	@echo "Stowing dotfiles..."
	stow -v -t ~ .
	@echo "Stow complete!"

# Unstow dotfiles
unstow:
	@echo "Unstowing dotfiles..."
	stow -D -t ~ .
	@echo "Unstow complete!"

# Update Homebrew packages
brew-update:
	@echo "Updating Homebrew packages..."
	brew update
	brew upgrade
	@echo "Homebrew update complete!"

# Update Brewfile
brew-dump:
	@echo "Updating Brewfile..."
	brew bundle dump --force
	@echo "Brewfile updated! Don't forget to commit the changes."

# Reload ZSH
zsh-reload:
	@echo "Reloading ZSH configuration..."
	source ~/.zshrc || echo "Please run 'source ~/.zshrc' manually"
