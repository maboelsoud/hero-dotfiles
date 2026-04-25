#!/usr/bin/env bash

set -euo pipefail

MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/bootstrap.sh
source "$MODULE_DIR/../lib/bootstrap.sh"

install_module() {
  ensure_brew_formula fzf
}

link_module() {
  remove_managed_block "$HOME/.zshrc" "fzf-zsh"
  stow_module_if_needed "$MODULE_DIR"
}

uninstall_module() {
  remove_managed_block "$HOME/.zshrc" "fzf-zsh"
  unstow_module_if_needed "$MODULE_DIR"
  remove_brew_formula_if_present fzf
}

status_module() {
  status_init

  if brew_formula_installed fzf; then
    STATUS_INSTALLED="yes"
    STATUS_NOTE="fzf is installed; shell startup is owned by the zsh module."
  else
    STATUS_INSTALLED="no"
    STATUS_NOTE="fzf is not installed yet."
  fi

  if managed_block_present "$HOME/.zshrc" "fzf-zsh"; then
    STATUS_LINKED="no"
    STATUS_NOTE="Legacy fzf init block still exists in ~/.zshrc."
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
