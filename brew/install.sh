#!/usr/bin/env bash

set -euo pipefail

MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/bootstrap.sh
source "$MODULE_DIR/../lib/bootstrap.sh"

install_module() {
  ensure_homebrew
  info "Updating Homebrew metadata."
  brew update
}

has_any_shellenv_line() {
  [[ -f "$HOME/.zprofile" ]] && grep -Eq 'brew[[:space:]]+shellenv' "$HOME/.zprofile"
}

link_module() {
  local brew_path

  brew_path="$(brew_bin)" || fail "Homebrew was not found during brew link step."

  if managed_block_present "$HOME/.zprofile" "homebrew-shellenv"; then
    info "Managed Homebrew shellenv block already present."
  elif has_any_shellenv_line; then
    warn "Found an existing Homebrew shellenv line in $HOME/.zprofile; skipping duplicate managed block."
  else
    ensure_managed_block "$HOME/.zprofile" "homebrew-shellenv" "eval \"\$($brew_path shellenv)\""
  fi

  setup_brew_env
  stow_module_if_needed "$MODULE_DIR"
}

uninstall_module() {
  remove_managed_block "$HOME/.zprofile" "homebrew-shellenv"
  unstow_module_if_needed "$MODULE_DIR"
  warn "Skipping Homebrew removal itself for safety."
}

status_module() {
  status_init

  if brew_bin >/dev/null 2>&1; then
    STATUS_INSTALLED="yes"
    STATUS_NOTE="Homebrew is available."
  else
    STATUS_INSTALLED="no"
    STATUS_NOTE="Homebrew is not installed yet."
  fi

  if managed_block_present "$HOME/.zprofile" "homebrew-shellenv"; then
    STATUS_LINKED="yes"
  elif has_any_shellenv_line; then
    STATUS_LINKED="yes"
    STATUS_NOTE="Homebrew is available with an existing unmanaged shellenv line."
  else
    STATUS_LINKED="no"
  fi

  status_emit
}

module_dispatch "$@"
