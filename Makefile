SHELL := /bin/bash
UNAME := $(shell uname)

.PHONY: help install sync save stow brew doctor

# Default target
help:
	@echo "Available commands:"
	@echo "  make install - First-time setup"
	@echo "  make sync    - Pull from repo and apply to system"
ifeq ($(UNAME), Darwin)
	@echo "  make save    - Save current system state to repo (macOS only)"
	@echo "  make stow    - Apply config files (macOS only)"
	@echo "  make brew    - Update Homebrew packages (macOS only)"
	@echo "  make doctor  - Check and fix broken symlinks (macOS only)"
endif

# First-time installation
install:
	@echo "Installing dotfiles..."
ifeq ($(UNAME), Darwin)
	/bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || true
	brew bundle
	stow -v -t ~ .
else
	@echo "Running Linux/WSL install script..."
	./install.sh
endif
	bash -c "$$(curl --fail --show-error --silent --location https://raw.githubusercontent.com/zdharma-continuum/zinit/HEAD/scripts/install.sh)" || true
	@echo "Installation complete! Please restart your terminal or run 'source ~/.zshrc'"

# Pull from repo and apply to system
sync:
	@echo "Syncing from repo..."
	git pull
ifeq ($(UNAME), Darwin)
	brew update && brew upgrade
	make stow
endif
	@echo "Sync complete! Please restart your terminal or run 'source ~/.zshrc'"

# Save current system state to repo
save:
ifeq ($(UNAME), Darwin)
	@echo "Saving current system state..."
	brew bundle dump --force
	@echo "System state saved to Brewfile!"
else
	@echo "save is only available on macOS (saves Homebrew state)"
endif

# Apply config files
stow:
ifeq ($(UNAME), Darwin)
	@echo "Applying config files..."
	stow -v -t ~ .
	mkdir -p ~/.config/zed
	ln -sf $(PWD)/zed-settings.json ~/.config/zed/settings.json
	mkdir -p ~/Library/Application\ Support/Code/User
	ln -sf $(PWD)/vscode-settings.json ~/Library/Application\ Support/Code/User/settings.json
	@echo "Config files applied!"
else
	@echo "stow is only available on macOS. On Linux/WSL, run: ./install.sh"
endif

stow-unsafe:
ifeq ($(UNAME), Darwin)
	@echo "Applying config files (unsafe)..."
	stow --adopt -R -v -t ~  .
	@echo "Config files applied!"
else
	@echo "stow-unsafe is only available on macOS"
endif

# Update Homebrew packages
brew:
ifeq ($(UNAME), Darwin)
	@echo "Updating Homebrew packages..."
	brew update && brew upgrade
	@echo "Homebrew packages updated!"
else
	@echo "brew is only available on macOS"
endif

# Check and fix broken symlinks
doctor:
ifeq ($(UNAME), Darwin)
	@DOTFILES_DIR="$$(pwd)"; \
	echo "Checking dotfiles health..."; \
	echo "Dotfiles location: $$DOTFILES_DIR"; \
	echo ""; \
	ISSUES=0; \
	\
	echo -n "~/.zshrc: "; \
	if [ -L ~/.zshrc ]; then \
		TARGET=$$(readlink ~/.zshrc); \
		if [ -e ~/.zshrc ]; then \
			RESOLVED=$$(cd ~ && cd "$$(dirname "$$TARGET")" 2>/dev/null && pwd)/$$(basename "$$TARGET"); \
			if [ "$$RESOLVED" = "$$DOTFILES_DIR/.zshrc" ]; then \
				echo "✓ OK"; \
			else \
				echo "⚠ Points to wrong location: $$TARGET"; \
				ISSUES=1; \
			fi; \
		else \
			echo "✗ Broken symlink -> $$TARGET"; \
			ISSUES=1; \
		fi; \
	elif [ -e ~/.zshrc ]; then \
		echo "⚠ Exists but is not a symlink"; \
		ISSUES=1; \
	else \
		echo "✗ Missing"; \
		ISSUES=1; \
	fi; \
	\
	echo -n "~/.config/zed/settings.json: "; \
	if [ -L ~/.config/zed/settings.json ]; then \
		TARGET=$$(readlink ~/.config/zed/settings.json); \
		if [ -e ~/.config/zed/settings.json ]; then \
			if [ "$$TARGET" = "$$DOTFILES_DIR/zed-settings.json" ]; then \
				echo "✓ OK"; \
			else \
				echo "⚠ Points to wrong location: $$TARGET"; \
				ISSUES=1; \
			fi; \
		else \
			echo "✗ Broken symlink -> $$TARGET"; \
			ISSUES=1; \
		fi; \
	elif [ -e ~/.config/zed/settings.json ]; then \
		echo "⚠ Exists but is not a symlink"; \
		ISSUES=1; \
	else \
		echo "✗ Missing"; \
		ISSUES=1; \
	fi; \
	\
	echo ""; \
	if [ $$ISSUES -eq 1 ]; then \
		read -p "Issues found. Would you like to fix them? [y/N] " REPLY; \
		if [ "$$REPLY" = "y" ] || [ "$$REPLY" = "Y" ]; then \
			echo "Fixing..."; \
			[ -L ~/.zshrc ] && rm ~/.zshrc || true; \
			[ -L ~/.config/zed/settings.json ] && rm ~/.config/zed/settings.json || true; \
			[ -f ~/.zshrc ] && echo "Warning: ~/.zshrc is a regular file, not removing" || true; \
			stow -v -t ~ .; \
			mkdir -p ~/.config/zed; \
			ln -sf "$$DOTFILES_DIR/zed-settings.json" ~/.config/zed/settings.json; \
			echo ""; \
			echo "✓ Fixed! Run 'source ~/.zshrc' to reload your shell."; \
		else \
			echo "No changes made."; \
		fi; \
	else \
		echo "All symlinks are healthy!"; \
	fi
else
	@echo "doctor is only available on macOS"
endif
