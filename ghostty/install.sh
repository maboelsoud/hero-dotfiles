#!/usr/bin/env bash

set -euo pipefail

MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GHOSTTY_CONFIG_FILE="${GHOSTTY_CONFIG_FILE:-$HOME/.config/ghostty/config.ghostty}"
# shellcheck source=../lib/bootstrap.sh
source "$MODULE_DIR/../lib/bootstrap.sh"

install_module() {
  ensure_brew_cask ghostty
}

link_module() {
  if [[ -f "$GHOSTTY_CONFIG_FILE" && ! -L "$GHOSTTY_CONFIG_FILE" ]]; then
    local managed_block
    managed_block=$'\n# >>> hero dotfiles: ghostty-theme >>>\ntheme = nord\n# <<< hero dotfiles: ghostty-theme <<<'

    if [[ "$(cat "$GHOSTTY_CONFIG_FILE")" == "$managed_block" || "$(cat "$GHOSTTY_CONFIG_FILE")" == "theme = nord" ]]; then
      rm -f "$GHOSTTY_CONFIG_FILE"
    else
      warn "Existing Ghostty config file at $GHOSTTY_CONFIG_FILE is not managed by this module. Leaving it in place."
    fi
  fi

  stow_module_if_needed "$MODULE_DIR"
}

uninstall_module() {
  unstow_module_if_needed "$MODULE_DIR"
  remove_brew_cask_if_present ghostty
}

status_module() {
  status_init

  if brew_cask_installed ghostty; then
    STATUS_INSTALLED="yes"
    STATUS_NOTE="Ghostty and the Nord theme module are installed."
  else
    STATUS_INSTALLED="no"
    STATUS_NOTE="Ghostty is not installed via Homebrew cask."
  fi

  if module_payload_linked "$MODULE_DIR"; then
    STATUS_LINKED="yes"
  else
    STATUS_LINKED="no"
  fi

  status_emit
}

module_dispatch "$@"
