#!/usr/bin/env bash

set -euo pipefail

MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/bootstrap.sh
source "$MODULE_DIR/../lib/bootstrap.sh"

install_module() {
  ensure_brew_formula zsh
  ensure_brew_formula zsh-autosuggestions
  ensure_brew_formula zsh-syntax-highlighting
}

link_module() {
  stow_module_if_needed "$MODULE_DIR"
}

uninstall_module() {
  unstow_module_if_needed "$MODULE_DIR"
  remove_brew_formula_if_present zsh-autosuggestions
  remove_brew_formula_if_present zsh-syntax-highlighting
  remove_brew_formula_if_present zsh
}

status_module() {
  status_init

  if brew_formula_installed zsh && brew_formula_installed zsh-autosuggestions && brew_formula_installed zsh-syntax-highlighting; then
    STATUS_INSTALLED="yes"
    STATUS_NOTE="zsh and shell plugins are installed."
  else
    STATUS_INSTALLED="no"
    STATUS_NOTE="zsh or its shell plugins are missing."
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
