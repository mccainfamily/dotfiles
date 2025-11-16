# ~/.zshrc - Zsh configuration
# Part of mccainfamily/dotfiles

# Homebrew configuration
# Detect architecture and set Homebrew path
if [[ "$(uname -m)" == "arm64" ]]; then
    BREW_PREFIX="/opt/homebrew"
else
    BREW_PREFIX="/usr/local"
fi

# Add Homebrew to PATH
export PATH="${BREW_PREFIX}/bin:${BREW_PREFIX}/sbin:$PATH"

# Homebrew environment setup
if [[ -f "${BREW_PREFIX}/bin/brew" ]]; then
    eval "$(${BREW_PREFIX}/bin/brew shellenv)"
fi

# Load brew alias from system profile if it exists
# This allows non-admin users to run brew commands via the admin user
if [[ -f /etc/profile.d/brew-alias.sh ]]; then
    source /etc/profile.d/brew-alias.sh
fi

# Go development environment
export GOPATH="${HOME}"
export PATH="${GOPATH}/bin:$PATH"

# Python development environment (pyenv)
if command -v pyenv &> /dev/null; then
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init --path)"
    eval "$(pyenv init -)"
    # pyenv-virtualenv
    if command -v pyenv-virtualenv-init &> /dev/null; then
        eval "$(pyenv virtualenv-init -)"
    fi
fi

# Starship prompt
if command -v starship &> /dev/null; then
    eval "$(starship init zsh)"
fi

# Enable command completion
autoload -Uz compinit
compinit

# History configuration
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE

# Color support
export CLICOLOR=1
export LSCOLORS=ExFxCxDxBxegedabagacad

# Common aliases
alias ll='ls -lah'
alias la='ls -A'
alias l='ls -CF'
alias grep='grep --color=auto'

# Git aliases
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline --graph --decorate'

# SSH Agent with macOS Keychain
# This is handled by ~/.ssh/config with UseKeychain yes

# VS Code alias
if [[ -f "${BREW_PREFIX}/bin/code" ]]; then
    alias code="${BREW_PREFIX}/bin/code"
fi
