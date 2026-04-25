mkcd() {
  [[ $# -eq 1 ]] || return 1
  mkdir -p -- "$1" && cd -- "$1"
}

fcd() {
  local dir

  dir="$(
    fd --type d . "${1:-.}" 2>/dev/null |
      fzf --height 40% --layout reverse --border
  )" || return 0

  [[ -n "$dir" ]] && cd -- "$dir"
}

fe() {
  local file

  file="$(
    fd --type f . "${1:-.}" 2>/dev/null |
      fzf \
        --height 50% \
        --layout reverse \
        --border \
        --preview 'bat --style=numbers --color=always --line-range :200 {}'
  )" || return 0

  [[ -n "$file" ]] && "${EDITOR:-nvim}" "$file"
}

fif() {
  [[ $# -gt 0 ]] || {
    printf 'usage: fif <pattern>\n' >&2
    return 1
  }

  rg --line-number --no-heading --smart-case --color=always "$@" |
    fzf \
      --ansi \
      --delimiter : \
      --height 60% \
      --layout reverse \
      --border \
      --preview 'bat --style=numbers --color=always --highlight-line {2} {1}'
}
