### Added by Zinit's installer
if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
    print -P "%F{33} %F{220}Installing %F{33}ZDHARMA-CONTINUUM%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" && \
        print -P "%F{33} %F{34}Installation successful.%f%b" || \
        print -P "%F{160} The clone has failed.%f%b"
fi

source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# Load a few important annexes, without Turbo
# (this is currently required for annexes)
zinit light-mode for \
    zdharma-continuum/zinit-annex-as-monitor \
    zdharma-continuum/zinit-annex-bin-gem-node \
    zdharma-continuum/zinit-annex-patch-dl \
    zdharma-continuum/zinit-annex-rust

zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-syntax-highlighting
zinit light Aloxaf/fzf-tab
zinit light jirutka/zsh-shift-select
zinit light kutsan/zsh-system-clipboard
zinit light g-plane/pnpm-shell-completion

# Add in snippets
zinit snippet OMZL::git.zsh
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::archlinux
zinit snippet OMZP::aws
zinit snippet OMZP::kubectl
zinit snippet OMZP::kubectx
zinit snippet OMZP::command-not-found


autoload -U compinit && compinit

zinit cdreplay -q

### End of Zinit's installer chunk

# Platform helpers
if [[ "$OSTYPE" == darwin* ]]; then
  IS_MACOS=true
else
  IS_MACOS=false
fi

has_cmd() {
  command -v "$1" >/dev/null 2>&1
}


# key bindings
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward

# Bind Cmd + Shift + Left Arrow to select to the beginning of the line
bindkey -M emacs '^[[1;10D' shift-select::beginning-of-line
bindkey -M shift-select '^[[1;10D' shift-select::beginning-of-line

# Bind Cmd + Shift + Right Arrow to select to the end of the line
bindkey -M emacs '^[[1;10C' shift-select::end-of-line
bindkey -M shift-select '^[[1;10C' shift-select::end-of-line

# Bind Cmd + C to copy the selected text to the system clipboard
bindkey -s '^[c' 'zsh-system-clipboard-copy-region\n'
# Bind Cmd + V to paste the system clipboard content
bindkey -s '^[v' 'zsh-system-clipboard-paste\n'

# History
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no

if ls --color=always >/dev/null 2>&1; then
  FZF_TAB_LS_PREVIEW='ls --color=always'
else
  FZF_TAB_LS_PREVIEW='ls -G'
fi

zstyle ':fzf-tab:complete:cd:*' fzf-preview "${FZF_TAB_LS_PREVIEW} \$realpath"
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview "${FZF_TAB_LS_PREVIEW} \$realpath"

# Shell integrations
has_cmd fzf && eval "$(fzf --zsh)"
has_cmd zoxide && eval "$(zoxide init --cmd cd zsh)"
has_cmd starship && eval "$(starship init zsh)"

# end of zsh plugins config

# Aliases

if ls --color=auto >/dev/null 2>&1; then
  alias ls='ls --color=auto'
elif ls -G >/dev/null 2>&1; then
  alias ls='ls -G'
fi

alias pn=pnpm
alias lg=lazygit
if has_cmd zed; then
  alias c="zed"
elif has_cmd code; then
  alias c="code"
fi

# PATHS

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# pnpm
if $IS_MACOS; then
  export PNPM_HOME="$HOME/Library/pnpm"
else
  export PNPM_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/pnpm"
fi
export PATH="$PNPM_HOME:$PATH"

# go
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin

# brew
if $IS_MACOS; then
  if [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif has_cmd brew; then
    eval "$(brew shellenv)"
  fi
fi

# fnm
has_cmd fnm && eval "$(fnm env --use-on-cd)"

# Created by `pipx` on 2025-04-11 15:13:27
export PATH="$PATH:$HOME/.local/bin"

if $IS_MACOS; then
  export DYLD_LIBRARY_PATH="/opt/homebrew/lib:$DYLD_LIBRARY_PATH"
fi
