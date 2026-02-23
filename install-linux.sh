#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

has_cmd() {
  command -v "$1" >/dev/null 2>&1
}

log_step() {
  printf "\n==> %s\n" "$1"
}

warn() {
  printf "Warning: %s\n" "$1"
}

require_linux() {
  if [[ "$(uname -s)" != "Linux" ]]; then
    printf "This installer is for Linux/WSL only. On macOS run: make install\n"
    exit 1
  fi
}

install_base_packages() {
  if ! has_cmd apt; then
    printf "Only apt-based Linux is supported by this script right now.\n"
    printf "Install core tools manually, then run: make stow\n"
    exit 1
  fi

  log_step "Installing base packages"
  sudo apt update
  sudo apt install -y \
    build-essential \
    ca-certificates \
    curl \
    git \
    stow \
    unzip \
    wget \
    zsh
}

install_fzf() {
  if has_cmd fzf; then
    return
  fi

  log_step "Installing fzf"
  if sudo apt install -y fzf; then
    return
  fi

  if [[ ! -d "$HOME/.fzf" ]]; then
    git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf"
  fi
  "$HOME/.fzf/install" --all
}

install_zoxide() {
  if has_cmd zoxide; then
    return
  fi

  log_step "Installing zoxide"
  curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
}

install_starship() {
  if has_cmd starship; then
    return
  fi

  log_step "Installing starship"
  curl -sS https://starship.rs/install.sh | sh -s -- -y
}

install_fnm() {
  if has_cmd fnm; then
    return
  fi

  log_step "Installing fnm"
  curl -fsSL https://fnm.vercel.app/install | bash -s -- --skip-shell
}

install_pnpm() {
  if has_cmd pnpm; then
    return
  fi

  log_step "Installing pnpm"
  curl -fsSL https://get.pnpm.io/install.sh | sh -
}

install_bun() {
  if has_cmd bun; then
    return
  fi

  log_step "Installing bun"
  curl -fsSL https://bun.sh/install | bash
}

set_default_shell() {
  if ! has_cmd zsh; then
    return
  fi

  local zsh_path
  zsh_path="$(command -v zsh)"

  if [[ "$SHELL" != "$zsh_path" ]]; then
    log_step "Setting zsh as default shell"
    chsh -s "$zsh_path" || warn "Could not set zsh as default shell automatically"
  fi
}

link_dotfiles() {
  log_step "Linking dotfiles"
  (
    cd "$DOTFILES_DIR"
    stow -v -t "$HOME" .
  )

  mkdir -p "$HOME/.config/zed"
  ln -sf "$DOTFILES_DIR/zed-settings.json" "$HOME/.config/zed/settings.json"
}

main() {
  require_linux
  install_base_packages
  install_fzf
  install_zoxide
  install_starship
  install_fnm
  install_pnpm
  install_bun
  set_default_shell
  link_dotfiles

  printf "\nDone. Restart your terminal or run: source ~/.zshrc\n"
}

main "$@"
