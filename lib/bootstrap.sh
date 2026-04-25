#!/usr/bin/env bash

if [[ -t 1 ]]; then
  COLOR_RESET=$'\033[0m'
  COLOR_RED=$'\033[31m'
  COLOR_GREEN=$'\033[32m'
  COLOR_YELLOW=$'\033[33m'
  COLOR_BLUE=$'\033[34m'
  COLOR_BOLD=$'\033[1m'
  COLOR_DIM=$'\033[2m'
else
  COLOR_RESET=""
  COLOR_RED=""
  COLOR_GREEN=""
  COLOR_YELLOW=""
  COLOR_BLUE=""
  COLOR_BOLD=""
  COLOR_DIM=""
fi

colorize() {
  local color="$1"
  local text="$2"
  printf '%s%s%s' "$color" "$text" "$COLOR_RESET"
}

has_gum() {
  [[ -t 0 && -t 1 ]] && command -v gum >/dev/null 2>&1
}

ui_banner() {
  local title="$1"

  if has_gum; then
    gum style \
      --foreground 212 \
      --border double \
      --border-foreground 99 \
      --align center \
      --width 38 \
      --margin "1 0" \
      --padding "0 1" \
      "$title"
  else
    cat <<EOF
========================================
 $title
========================================
EOF
  fi
}

ui_section_heading() {
  local title="$1"

  if has_gum; then
    printf '\n'
    gum style --bold --foreground 81 "$title"
  else
    printf '\n%s\n' "$(colorize "$COLOR_BOLD" "$title")"
  fi
}

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

managed_block_start() {
  local marker="$1"
  printf '# >>> hero dotfiles: %s >>>\n' "$marker"
}

managed_block_end() {
  local marker="$1"
  printf '# <<< hero dotfiles: %s <<<\n' "$marker"
}

managed_block_present() {
  local file="$1"
  local marker="$2"
  local start

  start="$(managed_block_start "$marker")"
  [[ -f "$file" ]] && grep -Fq "$start" "$file"
}

ensure_managed_block() {
  local file="$1"
  local marker="$2"
  local content="$3"
  local start
  local end

  start="$(managed_block_start "$marker")"
  end="$(managed_block_end "$marker")"

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

remove_managed_block() {
  local file="$1"
  local marker="$2"
  local start
  local end
  local tmp

  [[ -f "$file" ]] || return 0

  start="$(managed_block_start "$marker")"
  end="$(managed_block_end "$marker")"

  if ! grep -Fq "$start" "$file"; then
    return 0
  fi

  tmp="$(mktemp)"
  awk -v start="$start" -v end="$end" '
    $0 == start { skip = 1; next }
    $0 == end { skip = 0; next }
    skip != 1 { print }
  ' "$file" >"$tmp"
  mv "$tmp" "$file"
  info "Removed managed shell block from $file: $marker"
}

brew_formula_installed() {
  local formula="$1"
  brew_bin >/dev/null 2>&1 && brew list "$formula" >/dev/null 2>&1
}

brew_cask_installed() {
  local cask="$1"
  brew_bin >/dev/null 2>&1 && brew list --cask "$cask" >/dev/null 2>&1
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

module_payload_linked() {
  local module_dir="$1"
  local found=0
  local item
  local rel
  local target

  while IFS= read -r -d '' item; do
    found=1
    rel="${item#$module_dir/}"
    target="$HOME/$rel"

    if [[ ! -L "$target" ]]; then
      return 1
    fi
  done < <(
    find "$module_dir" \
      -mindepth 1 \
      \( -type f -o -type l \) \
      ! -name 'install.sh' \
      ! -name '.stow-local-ignore' \
      ! -name '.DS_Store' \
      -print0
  )

  [[ "$found" -eq 1 ]]
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

unstow_module_if_needed() {
  local module_dir="$1"
  local repo_root module_name

  repo_root="$(dirname "$module_dir")"
  module_name="$(basename "$module_dir")"

  if ! command -v stow >/dev/null 2>&1; then
    warn "stow is not available; skipping unlink for module '$module_name'."
    return 0
  fi

  if ! module_has_stow_payload "$module_dir"; then
    info "Skipping unstow for $module_name; no dotfiles to unlink."
    return 0
  fi

  info "Unstowing module: $module_name"
  (
    cd "$repo_root"
    stow -Dv -t "$HOME" "$module_name"
  )
}

remove_brew_formula_if_present() {
  local formula="$1"

  if ! brew_bin >/dev/null 2>&1; then
    return 0
  fi

  if brew_formula_installed "$formula"; then
    info "Uninstalling brew formula: $formula"
    brew uninstall "$formula"
  else
    info "brew formula not installed: $formula"
  fi
}

remove_brew_cask_if_present() {
  local cask="$1"

  if ! brew_bin >/dev/null 2>&1; then
    return 0
  fi

  if brew_cask_installed "$cask"; then
    info "Uninstalling brew cask: $cask"
    brew uninstall --cask "$cask"
  else
    info "brew cask not installed: $cask"
  fi
}

status_init() {
  STATUS_INSTALLED="no"
  STATUS_LINKED="na"
  STATUS_NOTE=""
}

status_emit() {
  printf 'installed\t%s\n' "$STATUS_INSTALLED"
  printf 'linked\t%s\n' "$STATUS_LINKED"
  printf 'note\t%s\n' "$STATUS_NOTE"
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
    uninstall)
      uninstall_module
      ;;
    status)
      status_module
      ;;
    *)
      fail "Usage: $(basename "$0") {install|link|uninstall|status}"
      ;;
  esac
}
