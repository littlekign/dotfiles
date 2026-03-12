# ============================================================================
# ZSH CONFIGURATION
# ============================================================================

# ============================================================================
# HISTORY
# ============================================================================

HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000

# ============================================================================
# ZSH OPTIONS
# ============================================================================

setopt autocd extendedglob nomatch
zstyle :compinstall filename '/Users/doug/.zshrc'

# Enable completion
autoload -Uz compinit
compinit

# ============================================================================
# KEY BINDINGS
# ============================================================================

bindkey -v                                      # Vi mode
bindkey '^R' history-incremental-search-backward
bindkey "^P" up-line-or-search
bindkey "^N" down-line-or-search
bindkey '^?' backward-delete-char

# ============================================================================
# PROMPT
# ============================================================================

PROMPT="%~ $ "

# ============================================================================
# ENVIRONMENT VARIABLES
# ============================================================================

export EDITOR="nvim"
export DISABLE_AUTO_TITLE="true"

# ============================================================================
# PATH
# ============================================================================

export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="/opt/homebrew/bin/:$PATH"

# ============================================================================
# PYTHON (pyenv)
# ============================================================================

export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"

# Initialize pyenv
if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init -)"
fi

# Initialize pyenv-virtualenv
if which pyenv-virtualenv-init > /dev/null; then
  eval "$(pyenv virtualenv-init -)";
fi

eval "$(pyenv init - zsh)"

# ============================================================================
# NODE (nvm)
# ============================================================================

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# ============================================================================
# TOOLS & UTILITIES
# ============================================================================

# z - jump around
. /opt/homebrew/etc/profile.d/z.sh

# ============================================================================
# ALIASES
# ============================================================================

# Editor
alias vi="nvim"
alias vim="nvim"

# Navigation
alias j="z"
alias ...="cd ../.."

# Git
alias add="git add -A"
alias commit="git commit"
alias status="git status -s"
alias gs="git status"
alias log="git l"
alias llog="pretty_git_log"
alias show="git show"
alias diff="git diff"
alias pull="git pull origin"

# Python virtual environments
alias va=". .venv/bin/activate"
alias da="deactivate"

# Tmux
alias tmain="tmux new-session -A -s main"

# Utilities
alias ls="ls -G"

# ============================================================================
# WORK-SPECIFIC CONFIG
# ============================================================================

# Source Candid-specific configuration (not checked into dotfiles repo)
if [ -f "$HOME/.candid-zshrc" ]; then
  source "$HOME/.candid-zshrc"
fi

# ============================================================================
# TMUX INTEGRATION
# ============================================================================

# Prevent terminal title changes in tmux (must be at end, after pyenv/nvm init)
if [[ -n "$TMUX" ]]; then
  precmd() { }
  preexec() { }
fi

