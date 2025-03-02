# Dotfiles

A collection of my personal dotfiles for macOS development environment setup, managed with GNU Stow and Homebrew.

## Pre-Requirements

Before you begin, you'll need:

1. **macOS** - This setup is designed for macOS
2. **Git** - To clone the repository

   ```bash
   # Check if Git is installed
   git --version

   # If not installed, you'll be prompted to install the Xcode Command Line Tools
   ```

3. **Xcode Command Line Tools** - Required for many development tools
   ```bash
   xcode-select --install
   ```

## Quick Onboarding

### First-time Setup

```bash
# 1. Clone this repository
git clone https://github.com/diegoalzate/dotfiles.git ~/dotfiles
cd ~/dotfiles

# 2. Install Homebrew if needed
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 3. Install dependencies from Brewfile
brew bundle

# 4. Symlink dotfiles to home directory
stow -v -t ~ .

# 5. Install Zinit (ZSH plugin manager)
bash -c "$(curl --fail --show-error --silent --location https://raw.githubusercontent.com/zdharma-continuum/zinit/HEAD/scripts/install.sh)"


# 6. Reload shell
source ~/.zshrc
```

### Updating Your Setup

```bash
# 1. Navigate to dotfiles
cd ~/dotfiles

# 2. Pull latest changes
git pull

# 3. Update Homebrew packages
brew update && brew upgrade

# 4. Re-stow dotfiles
stow -R -v -t ~ .

# 5. Reload shell
source ~/.zshrc
```

## What's Included

- **Brewfile**: Package and application dependencies managed by Homebrew
- **ZSH Configuration**: Custom `.zshrc` with Zinit plugin manager
- **Config Files**: Various application configurations

## Core Tools

- **Shell**: ZSH with Zinit, Starship prompt, syntax highlighting, autosuggestions
- **Navigation**: FZF, Zoxide (smarter cd)
- **Development**: fnm (Fast Node Manager), PNPM, Go, Terraform (via tfenv)
- **Version Control**: Git, GitHub CLI

## Using GNU Stow

[GNU Stow](https://www.gnu.org/software/stow/) is a symlink farm manager that helps organize your dotfiles.

- To stow everything: `stow -v -t ~ .`
- To unstow everything: `stow -D -t ~ .`
- To restow everything: `stow -R -v -t ~ .`

## FAQ

### How do I update my Brewfile after installing new packages?

```bash
# Navigate to your dotfiles directory
cd ~/dotfiles

# Update the Brewfile with currently installed packages
brew bundle dump --force

# Re-stow to update symlinks
stow -R -v -t ~ .

# Commit and push your changes
git add Brewfile
git commit -m "Update Brewfile with new packages"
git push
```

### How do I modify my ZSH configuration?

```bash
# Edit the .zshrc file
vim ~/dotfiles/.zshrc  # or use your preferred editor

# Re-stow to update symlinks
stow -R -v -t ~ .

# Apply changes to your current session
source ~/.zshrc

# Commit and push your changes
git add .zshrc
git commit -m "Update .zshrc with new configuration"
git push
```

### How do I add a new dotfile?

```bash
# Copy the file to your dotfiles repository with the correct structure
cp ~/.some-config ~/dotfiles/

# Re-stow to create the symlink
cd ~/dotfiles
stow -R -v -t ~ .

# Commit and push your changes
git add .
git commit -m "Add new configuration file"
git push
```

### How do I update a specific tool?

```bash
# For Homebrew packages
brew upgrade <package-name>

# For Node.js
fnm install <version>
fnm use <version>

# For Go
brew upgrade go

# If configuration files were updated, re-stow
cd ~/dotfiles
stow -R -v -t ~ .
```

### Important Note About Making Changes

Always remember the GNU Stow workflow:

1. Make changes to files in your dotfiles repository
2. Run `stow -R -v -t ~ .` to update the symlinks
3. Source the appropriate file if needed (e.g., `source ~/.zshrc`)
4. Commit and push your changes

Without re-stowing, your changes will only exist in the repository but won't be linked to your actual configuration files.

## Customization

- Edit `Brewfile` to add/remove packages
- Customize `.zshrc` for shell preferences

## License

MIT
