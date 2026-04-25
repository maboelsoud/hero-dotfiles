#!/usr/bin/env bash

set -euo pipefail

MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/bootstrap.sh
source "$MODULE_DIR/../lib/bootstrap.sh"

install_module() {
  ensure_brew_formula starship
}

link_module() {
  ensure_managed_block "$HOME/.zshrc" "starship-init" 'eval "$(starship init zsh)"'
  stow_module_if_needed "$MODULE_DIR"
}

uninstall_module() {
  remove_managed_block "$HOME/.zshrc" "starship-init"
  unstow_module_if_needed "$MODULE_DIR"
  remove_brew_formula_if_present starship
}

status_module() {
  status_init

  if brew_formula_installed starship; then
    STATUS_INSTALLED="yes"
    STATUS_NOTE="Starship is installed."
  else
    STATUS_INSTALLED="no"
    STATUS_NOTE="Starship is not installed yet."
  fi

  if managed_block_present "$HOME/.zshrc" "starship-init"; then
    STATUS_LINKED="yes"
  else
    STATUS_LINKED="no"
  fi

  status_emit
}

module_dispatch "$@"
