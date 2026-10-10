# Only run for interactive shells
case $- in
  *i*) ;;
    *) return;;
esac

# --- oh-my-bash ---
export OSH="$HOME/.oh-my-bash"
OSH_THEME=""  # prompt comes from starship
OMB_USE_SUDO=true
OMB_PROMPT_SHOW_PYTHON_VENV=true

completions=(
  git
  ssh
  docker
  npm
  pip
  uv
  makefile
)

aliases=(
  general
)

plugins=(
  git
  bashmarks
  fzf
  zoxide
  sudo
  colored-man-pages
  starship
)

source "$OSH"/oh-my-bash.sh
shopt -u cdable_vars  # stop OMB colour vars (white, red…) showing up in cd completion

export PATH="$HOME/.local/bin:$PATH"

# --- Git aliases ---
alias gs='git status'
alias ga='git add'
alias gaa='git add --all'
alias gc='git commit -m'
alias gsh='git stash'
alias gp='git push'
alias gl='git pull'
alias gm='git merge'
alias gco='git checkout'
alias gcp='git cherry-pick'
alias gb='git branch'
alias glog='git log --oneline --graph --decorate --all'
alias gd='git diff'
alias gls='git log --oneline'
alias gl5='git log --oneline -5'
alias glp='git log --pretty=format:"%h %an %ar - %s"'

alias brc='nano ~/.bashrc'
alias src='source ~/.bashrc'

# Personal aliases, if any
[ -f ~/.bash_aliases ] && . ~/.bash_aliases

# --- Modern CLI replacements (only if installed) ---
if command -v eza >/dev/null; then
  alias ls='eza --icons=auto --group-directories-first'
  alias ll='eza -lh --icons=auto --git --group-directories-first'
  alias la='eza -lah --icons=auto --git --group-directories-first'
  alias lt='eza --tree --level=2 --icons=auto'
fi
command -v batcat >/dev/null && alias cat='batcat --paging=never --style=plain'
command -v fdfind >/dev/null && alias fd='fdfind'
command -v fdfind >/dev/null && export FZF_DEFAULT_COMMAND='fdfind --type f --hidden --exclude .git'
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border=rounded --info=inline
  --color=bg+:#313244,spinner:#f5e0dc,hl:#f38ba8,fg:#cdd6f4,header:#f38ba8,info:#cba6f7
  --color=pointer:#f5e0dc,marker:#b4befe,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8,border:#6c7086'
