.PHONY: help install sync save stow brew

# Default target
help:
	@echo "Available commands:"
	@echo "  make install - First-time setup"
	@echo "  make sync    - Pull from repo and apply to system"
	@echo "  make save    - Save current system state to repo"
	@echo "  make stow    - Apply config files"
	@echo "  make brew    - Update Homebrew packages"

# First-time installation
install:
	@echo "Installing dotfiles..."
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || true
	brew bundle
	stow -v -t ~ .
	bash -c "$(curl --fail --show-error --silent --location https://raw.githubusercontent.com/zdharma-continuum/zinit/HEAD/scripts/install.sh)" || true
	@echo "Installation complete! Please restart your terminal or run 'source ~/.zshrc'"

# Pull from repo and apply to system
sync:
	@echo "Syncing from repo..."
	git pull
	brew update && brew upgrade
	make stow
	@echo "Sync complete! Please restart your terminal or run 'source ~/.zshrc'"

# Save current system state to repo
save:
	@echo "Saving current system state..."
	brew bundle dump --force
	@echo "System state saved to Brewfile!"

# Apply config files
stow:
	@echo "Applying config files..."
	stow -v -t ~ .
	mkdir -p ~/.config/zed
	ln -sf $(PWD)/zed-settings.json ~/.config/zed/settings.json
	@echo "Config files applied!"

stow-unsafe:
	@echo "Applying config files (unsafe)..."
	stow --adopt -R -v -t ~  .
	@echo "Config files applied!"

# Update Homebrew packages
brew:
	@echo "Updating Homebrew packages..."
	brew update && brew upgrade
	@echo "Homebrew packages updated!"
