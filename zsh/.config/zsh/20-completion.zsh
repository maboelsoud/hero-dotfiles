fpath=("$HOME/.zsh/completion" $fpath)

autoload -Uz compinit
compinit -u

setopt COMPLETE_IN_WORD
setopt NO_ALWAYS_TO_END
setopt LIST_PACKED

zstyle ':completion:*' completer _complete _match _list _correct _approximate _ignored
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}' 'r:|[-_.]=* r:|=*'
zstyle ':completion:*' menu select=2
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
zstyle ':completion:*' group-name ''
zstyle ':completion:*' verbose yes
zstyle ':completion:*:descriptions' format $'%{\e[01;36m%}-- %d --%{\e[m%}'
zstyle ':completion:*:warnings' format $'%{\e[01;31m%}-- No matches for: %d --%{\e[m%}'
zstyle ':acceptline:*' rehash true

if command -v gdircolors >/dev/null 2>&1; then
  eval "$(gdircolors -b)"
  zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
fi

if command -v brew >/dev/null 2>&1; then
  zsh_brew_prefix="$(brew --prefix)"

  if [[ -f "$zsh_brew_prefix/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
    source "$zsh_brew_prefix/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
  fi

  if [[ -f "$zsh_brew_prefix/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]; then
    source "$zsh_brew_prefix/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

    if [[ -d "$zsh_brew_prefix/share/zsh-syntax-highlighting/highlighters" ]]; then
      ZSH_HIGHLIGHT_HIGHLIGHTERS_DIR="$zsh_brew_prefix/share/zsh-syntax-highlighting/highlighters"
    fi

    ZSH_HIGHLIGHT_STYLES[default]='none'
    ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=red'
    ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=yellow'
    ZSH_HIGHLIGHT_STYLES[alias]='fg=blue'
    ZSH_HIGHLIGHT_STYLES[builtin]='fg=blue'
    ZSH_HIGHLIGHT_STYLES[function]='fg=blue'
    ZSH_HIGHLIGHT_STYLES[command]='fg=blue'
    ZSH_HIGHLIGHT_STYLES[globbing]='fg=green'
    ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=yellow'
    ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=yellow'
    ZSH_HIGHLIGHT_STYLES[dollar-double-quoted-argument]='fg=cyan'
    ZSH_HIGHLIGHT_STYLES[single-hyphen-option]='fg=magenta'
    ZSH_HIGHLIGHT_STYLES[double-hyphen-option]='fg=red'
  fi
fi
