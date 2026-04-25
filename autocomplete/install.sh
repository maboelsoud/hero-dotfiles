#!/usr/bin/env bash

set -euo pipefail

MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/bootstrap.sh
source "$MODULE_DIR/../lib/bootstrap.sh"

install_module() {
  info "No separate autocomplete package installation yet."
}

link_module() {
  remove_managed_block "$HOME/.zshrc" "zsh-compinit"
  stow_module_if_needed "$MODULE_DIR"
}

uninstall_module() {
  remove_managed_block "$HOME/.zshrc" "zsh-compinit"
  unstow_module_if_needed "$MODULE_DIR"
}

status_module() {
  status_init

  STATUS_INSTALLED="yes"
  STATUS_NOTE="Completion setup is owned by the zsh module."

  if managed_block_present "$HOME/.zshrc" "zsh-compinit"; then
    STATUS_LINKED="no"
    STATUS_NOTE="Legacy compinit block still exists in ~/.zshrc."
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
