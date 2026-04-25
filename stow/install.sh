#!/usr/bin/env bash

set -euo pipefail

MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/bootstrap.sh
source "$MODULE_DIR/../lib/bootstrap.sh"

install_module() {
  ensure_brew_formula stow
}

link_module() {
  stow_module_if_needed "$MODULE_DIR"
}

uninstall_module() {
  unstow_module_if_needed "$MODULE_DIR"
  remove_brew_formula_if_present stow
}

status_module() {
  status_init

  if brew_formula_installed stow; then
    STATUS_INSTALLED="yes"
    STATUS_NOTE="GNU Stow is installed."
  else
    STATUS_INSTALLED="no"
    STATUS_NOTE="GNU Stow is not installed yet."
  fi

  STATUS_LINKED="na"
  status_emit
}

module_dispatch "$@"
