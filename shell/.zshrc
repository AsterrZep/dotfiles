export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#545862"

plugins=()
[ -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ] && source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
[ -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ] && source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

autoload -Uz compinit && compinit

setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt EXTENDED_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt SHARE_HISTORY
setopt INTERACTIVE_COMMENTS

HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000

ZSH_AUTOSUGGEST_STRATEGY=(history completion)

export EDITOR=nvim
export LANG=es_ES.UTF-8

command -v starship >/dev/null 2>&1 && eval "$(starship init zsh)"
command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init zsh)"

# ---------- eza (ls moderno) ----------
alias ls='eza --group-directories-first'
alias ll='eza -la --group-directories-first --icons=auto'
alias la='eza -a --group-directories-first --icons=auto'
alias lt='eza --tree --group-directories-first --icons=auto'
alias l='ls'
alias tree='eza --tree --icons=auto'

# ---------- cat / grep ----------
alias cat='batcat'
alias bat='batcat'
alias grep='rg'
alias rg='rg --hidden --no-ignore'

# ---------- visores de imagen ----------
alias timg='timg'
alias viewimg='timg'
alias showimg='chafa'

# ---------- fd ----------
alias fd='fdfind'

# ---------- navegacion ----------
alias ...='../..'
alias ....='../../..'
alias zi='zi'

function take() { mkdir -p "$1" && cd "$1" }

# ---------- tmux ----------
alias tm='tmux new -A -s main'
alias tls='tmux ls'
alias tkill='tmux kill-server'

# ---------- git ----------
alias gs='git status'
alias ga='git add'
alias gc='git commit -m'
alias gaa='git add -A'
alias gcm='git commit -m'
alias gp='git push'
alias gpl='git pull'
alias gl='git log --oneline --graph --decorate'
alias gd='git diff'

# ---------- misc ----------
alias zshconfig="$EDITOR ~/.zshrc"
alias reload='exec zsh'
alias update='sudo apt update && sudo apt upgrade -y'
alias ip='ip -c'

# ---------- fzf ----------
export FZF_DEFAULT_COMMAND='fdfind --type f --hidden --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_DEFAULT_OPTS='--height 60% --layout=reverse --border --color=fg:#a8a8a8,hl:#5f87ff --preview "fzf-preview.sh {}" --preview-window=right:50%:wrap'
export FZF_CTRL_T_OPTS="--preview 'fzf-preview.sh {}'"
[ -f /usr/share/doc/fzf/examples/key-bindings.zsh ] && source /usr/share/doc/fzf/examples/key-bindings.zsh
[ -f /usr/share/doc/fzf/examples/completion.zsh ] && source /usr/share/doc/fzf/examples/completion.zsh

# ---------- zsh vi-mode opcional ----------
(( $+functions[fzf-history-widget] )) && bindkey '^R' fzf-history-widget
export PATH="$HOME/.local/bin:$HOME/.opencode/bin:$PATH"

# pnpm
export PNPM_HOME="/home/aster/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME/bin:"*) ;;
  *) export PATH="$PNPM_HOME/bin:$PATH" ;;
esac
# pnpm end

# bun completions
[ -s "/home/aster/.bun/_bun" ] && source "/home/aster/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"


# Added by Antigravity CLI installer
export PATH="/home/aster/.local/bin:$PATH"
export PATH="$HOME/.npm-global/bin:$PATH"

# >>> juliaup initialize >>>

# !! Contents within this block are managed by juliaup !!

path=('/home/aster/.juliaup/bin' $path)
export PATH
# Tab completion for juliaup and julia channel selection
[ -f "/home/aster/.julia/juliaup/completions/zsh.zsh" ] && source "/home/aster/.julia/juliaup/completions/zsh.zsh"

# <<< juliaup initialize <<<

# ---------- nvm (Node.js) ----------
# Sin este bloque no existen node/npm/npx tras restaurar los dotfiles:
# fallan el MCP de opencode (npx) y el npm install del plugin de status.
export NVM_DIR="$HOME/.config/nvm"
if [ -s "$NVM_DIR/nvm.sh" ]; then
    # nvm se queja del `prefix` de ~/.npmrc (globals en ~/.npm-global, fuera
    # de su árbol). Solo es un aviso: el PATH de nvm se aplica igual. Se
    # filtran esas 3 líneas; el resto de errores de nvm se muestran igual.
    . "$NVM_DIR/nvm.sh" 2> >(grep -v \
        -e 'npmrc file' \
        -e 'incompatible with nvm' \
        -e 'nvm use --delete-prefix' >&2)
fi
