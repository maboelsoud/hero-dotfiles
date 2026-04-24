#!/usr/bin/env bash

log() {
  printf '\n[%s] %s\n' "$1" "$2"
}

info() {
  log "info" "$1"
}

warn() {
  log "warn" "$1"
}

fail() {
  log "fail" "$1"
  exit 1
}

ensure_macos() {
  [[ "$(uname -s)" == "Darwin" ]] || fail "This bootstrap flow is intended for macOS."
}

brew_bin() {
  if command -v brew >/dev/null 2>&1; then
    command -v brew
    return 0
  fi

  if [[ -x /opt/homebrew/bin/brew ]]; then
    printf '%s\n' /opt/homebrew/bin/brew
    return 0
  fi

  if [[ -x /usr/local/bin/brew ]]; then
    printf '%s\n' /usr/local/bin/brew
    return 0
  fi

  return 1
}

setup_brew_env() {
  local brew_path
  brew_path="$(brew_bin)" || fail "Homebrew is required but was not found."
  eval "$("$brew_path" shellenv)"
}

refresh_runtime_environment() {
  if brew_bin >/dev/null 2>&1; then
    setup_brew_env
  fi

  export PATH="$HOME/.local/bin:$PATH"

  if command -v fnm >/dev/null 2>&1; then
    eval "$(fnm env --shell bash 2>/dev/null || true)"
  fi
}

ensure_homebrew() {
  if brew_bin >/dev/null 2>&1; then
    info "Homebrew already installed."
  else
    info "Installing Homebrew."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi

  setup_brew_env
}

ensure_brew_formula() {
  local formula="$1"

  ensure_homebrew

  if brew list "$formula" >/dev/null 2>&1; then
    info "brew formula already present: $formula"
  else
    info "Installing brew formula: $formula"
    brew install "$formula"
  fi
}

ensure_brew_cask() {
  local cask="$1"

  ensure_homebrew

  if brew list --cask "$cask" >/dev/null 2>&1; then
    info "brew cask already present: $cask"
  else
    info "Installing brew cask: $cask"
    brew install --cask "$cask"
  fi
}

ensure_dir() {
  local dir="$1"
  mkdir -p "$dir"
}

ensure_managed_block() {
  local file="$1"
  local marker="$2"
  local content="$3"
  local start="# >>> hero dotfiles: $marker >>>"
  local end="# <<< hero dotfiles: $marker <<<"

  ensure_dir "$(dirname "$file")"
  touch "$file"

  if grep -Fq "$start" "$file"; then
    info "Managed shell block already present: $marker"
    return 0
  fi

  {
    printf '\n%s\n' "$start"
    printf '%s\n' "$content"
    printf '%s\n' "$end"
  } >>"$file"

  info "Added managed shell block to $file: $marker"
}

module_has_stow_payload() {
  local module_dir="$1"

  find "$module_dir" \
    -mindepth 1 \
    ! -name 'install.sh' \
    ! -name '.stow-local-ignore' \
    ! -name '.DS_Store' \
    -print -quit | grep -q .
}

stow_module_if_needed() {
  local module_dir="$1"
  local repo_root module_name

  repo_root="$(dirname "$module_dir")"
  module_name="$(basename "$module_dir")"

  if ! command -v stow >/dev/null 2>&1; then
    fail "stow is required for linking module '$module_name'."
  fi

  if ! module_has_stow_payload "$module_dir"; then
    info "Skipping stow for $module_name; no dotfiles to link yet."
    return 0
  fi

  info "Stowing module: $module_name"
  (
    cd "$repo_root"
    stow -Rv -t "$HOME" "$module_name"
  )
}

module_dispatch() {
  local action="${1:-}"

  case "$action" in
    install)
      install_module
      ;;
    link)
      link_module
      ;;
    *)
      fail "Usage: $(basename "$0") {install|link}"
      ;;
  esac
}
