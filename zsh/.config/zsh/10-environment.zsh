if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

export PATH="$HOME/.local/bin:$PATH"

export EDITOR="nvim"
export VISUAL="$EDITOR"

export LANG="en_US.UTF-8"
export LC_CTYPE="en_US.UTF-8"
export LESSCHARSET="utf-8"

if [[ -o interactive ]]; then
  if command -v fnm >/dev/null 2>&1; then
    eval "$(fnm env --use-on-cd --shell zsh)"
  fi

  if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init zsh)"
  fi
fi
