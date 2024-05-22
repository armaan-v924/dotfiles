# Add homebrew to the path
eval "$(/opt/homebrew/bin/brew shellenv)"

# Set the directory to install zinit and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Load zinit
if [ ! -d "$ZINIT_HOME" ]; then
  mkdir -p "$(dirname $ZINIT_HOME)"
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Source zinit
source "${ZINIT_HOME}/zinit.zsh"

# Load Starship prompt
zinit ice as"command" from "gh-r" \
          atclone"./starship init zsh > init.zsh; ./starship completions zsh > _starship" \
          atpull"%atclone" src"init.zsh"
zinit light starship/starship

# Source starship
source <(/opt/homebrew/bin/starship init zsh --print-full-init)

# Add plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

# Add in snippets
zinit snippet OMZP::git
zinit snippet OMZP::1password
zinit snippet OMZP::sudo
zinit snippet OMZP::vscode

# Load autocomplete
autoload -U compinit && compinit

zinit cdreplay -q

# bind up and down arrow keys to search history
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward

# bind ctrl+f to accept the suggestion if there is one
bindkey '^f' autosuggest-accept

# History settings
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

# Completion settings
zstyle ':completion:*' matcher-list "m:{a-zA-Z}={A-Za-z}"
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':complettion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'
zstyle ':completion:*' menu select setopt completeailiases

# Enable auto correction
ENABLE_CORRECTION="true"

# Aliases
alias ls='ls --color'
alias cd='z'
alias c='clear'

# Shell integration
eval "$(fzf --zsh)"
eval "$(zoxide init --cmd cd zsh)"

# Remove "(base)" from the prompt
export VIRTUAL_ENV_DISABLE_PROMPT=1

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('~/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "~/miniconda3/etc/profile.d/conda.sh" ]; then
        . "~/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="~/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

