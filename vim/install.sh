#!/usr/bin/env bash

set -euo pipefail

MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/bootstrap.sh
source "$MODULE_DIR/../lib/bootstrap.sh"

install_module() {
  ensure_brew_formula neovim
}

link_module() {
  stow_module_if_needed "$MODULE_DIR"
}

uninstall_module() {
  unstow_module_if_needed "$MODULE_DIR"
  remove_brew_formula_if_present neovim
}

status_module() {
  status_init

  if command -v nvim >/dev/null 2>&1; then
    STATUS_INSTALLED="yes"
    STATUS_NOTE="Neovim is installed."
  else
    STATUS_INSTALLED="no"
    STATUS_NOTE="Neovim is not installed yet."
  fi

  if module_has_stow_payload "$MODULE_DIR"; then
    if module_payload_linked "$MODULE_DIR"; then
      STATUS_LINKED="yes"
    else
      STATUS_LINKED="no"
    fi
  else
    STATUS_LINKED="na"
  fi

  status_emit
}

module_dispatch "$@"
