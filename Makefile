SHELL := /bin/bash

UNAME_S := $(shell uname -s)
DOTFILES_DIR := $(CURDIR)
LINUX_INSTALLER := ./install-linux.sh

.PHONY: help install install-macos install-linux sync save stow stow-unsafe brew doctor

help:
	@echo "Available commands:"
	@echo "  make install       - First-time setup (auto-detects OS)"
	@echo "  make install-macos - macOS setup (Homebrew + stow + zinit)"
	@echo "  make install-linux - Linux/WSL setup (apt + stow)"
	@echo "  make sync          - Pull from repo and re-apply config files"
	@echo "  make save          - Save Homebrew state to Brewfile (macOS only)"
	@echo "  make stow          - Apply config files"
	@echo "  make stow-unsafe   - Apply config files with --adopt"
	@echo "  make brew          - Update Homebrew packages (macOS only)"
	@echo "  make doctor        - Check and fix broken symlinks"

install:
	@case "$(UNAME_S)" in \
		Darwin) $(MAKE) install-macos ;; \
		Linux) $(MAKE) install-linux ;; \
		*) echo "Unsupported OS: $(UNAME_S)"; exit 1 ;; \
	esac

install-macos:
	@echo "Installing dotfiles on macOS..."
	@if ! command -v brew >/dev/null 2>&1; then \
		/bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || true; \
	fi
	brew bundle
	$(MAKE) stow
	bash -c "$$(curl --fail --show-error --silent --location https://raw.githubusercontent.com/zdharma-continuum/zinit/HEAD/scripts/install.sh)" || true
	@echo "Installation complete! Please restart your terminal or run 'source ~/.zshrc'"

install-linux:
	@echo "Installing dotfiles on Linux/WSL..."
	@if [ ! -f "$(LINUX_INSTALLER)" ]; then \
		echo "Missing $(LINUX_INSTALLER)"; \
		exit 1; \
	fi
	chmod +x "$(LINUX_INSTALLER)"
	"$(LINUX_INSTALLER)"

sync:
	@echo "Syncing from repo..."
	git pull
ifeq ($(UNAME_S),Darwin)
	brew update && brew upgrade
endif
	$(MAKE) stow
	@echo "Sync complete! Please restart your terminal or run 'source ~/.zshrc'"

save:
ifeq ($(UNAME_S),Darwin)
	@echo "Saving current Homebrew state..."
	brew bundle dump --force
	@echo "System state saved to Brewfile!"
else
	@echo "make save is only available on macOS (Brewfile export)."
endif

stow:
	@echo "Applying config files..."
	stow -v -t ~ .
	mkdir -p ~/.config/zed
	ln -sf "$(DOTFILES_DIR)/zed-settings.json" ~/.config/zed/settings.json
	@echo "Config files applied!"

stow-unsafe:
	@echo "Applying config files (unsafe)..."
	stow --adopt -R -v -t ~ .
	@echo "Config files applied!"

brew:
ifeq ($(UNAME_S),Darwin)
	@echo "Updating Homebrew packages..."
	brew update && brew upgrade
	@echo "Homebrew packages updated!"
else
	@echo "make brew is only available on macOS."
endif

doctor:
	@DOTFILES_DIR="$(DOTFILES_DIR)"; \
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
				echo "OK"; \
			else \
				echo "Points to wrong location: $$TARGET"; \
				ISSUES=1; \
			fi; \
		else \
			echo "Broken symlink -> $$TARGET"; \
			ISSUES=1; \
		fi; \
	elif [ -e ~/.zshrc ]; then \
		echo "Exists but is not a symlink"; \
		ISSUES=1; \
	else \
		echo "Missing"; \
		ISSUES=1; \
	fi; \
	\
	echo -n "~/.config/zed/settings.json: "; \
	if [ -L ~/.config/zed/settings.json ]; then \
		TARGET=$$(readlink ~/.config/zed/settings.json); \
		if [ -e ~/.config/zed/settings.json ]; then \
			RESOLVED=$$(cd ~/.config/zed && cd "$$(dirname "$$TARGET")" 2>/dev/null && pwd)/$$(basename "$$TARGET"); \
			if [ "$$RESOLVED" = "$$DOTFILES_DIR/zed-settings.json" ]; then \
				echo "OK"; \
			else \
				echo "Points to wrong location: $$TARGET"; \
				ISSUES=1; \
			fi; \
		else \
			echo "Broken symlink -> $$TARGET"; \
			ISSUES=1; \
		fi; \
	elif [ -e ~/.config/zed/settings.json ]; then \
		echo "Exists but is not a symlink"; \
		ISSUES=1; \
	else \
		echo "Missing"; \
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
			$(MAKE) stow; \
			echo ""; \
			echo "Fixed! Run 'source ~/.zshrc' to reload your shell."; \
		else \
			echo "No changes made."; \
		fi; \
	else \
		echo "All symlinks are healthy!"; \
	fi
