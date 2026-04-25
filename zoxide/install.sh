#!/usr/bin/env bash

set -euo pipefail

MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/bootstrap.sh
source "$MODULE_DIR/../lib/bootstrap.sh"

install_module() {
  ensure_brew_formula zoxide
}

link_module() {
  remove_managed_block "$HOME/.zshrc" "zoxide-init"
  stow_module_if_needed "$MODULE_DIR"
}

uninstall_module() {
  remove_managed_block "$HOME/.zshrc" "zoxide-init"
  unstow_module_if_needed "$MODULE_DIR"
  remove_brew_formula_if_present zoxide
}

status_module() {
  status_init

  if brew_formula_installed zoxide; then
    STATUS_INSTALLED="yes"
    STATUS_NOTE="zoxide is installed; shell startup is owned by the zsh module."
  else
    STATUS_INSTALLED="no"
    STATUS_NOTE="zoxide is not installed yet."
  fi

  if managed_block_present "$HOME/.zshrc" "zoxide-init"; then
    STATUS_LINKED="no"
    STATUS_NOTE="Legacy zoxide init block still exists in ~/.zshrc."
  elif module_has_stow_payload "$MODULE_DIR"; then
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
