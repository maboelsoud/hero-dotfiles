#!/usr/bin/env bash

set -euo pipefail

MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/bootstrap.sh
source "$MODULE_DIR/../lib/bootstrap.sh"

install_module() {
  ensure_brew_formula fnm
  eval "$(fnm env --shell bash)"
  info "Installing the latest Node.js LTS with fnm."
  fnm install --lts
  fnm use lts-latest
  fnm default "$(fnm current)"
}

link_module() {
  remove_managed_block "$HOME/.zshrc" "fnm-init"
  stow_module_if_needed "$MODULE_DIR"
}

uninstall_module() {
  remove_managed_block "$HOME/.zshrc" "fnm-init"
  unstow_module_if_needed "$MODULE_DIR"
  remove_brew_formula_if_present fnm
  warn "Any Node.js versions already installed by fnm were left in place."
}

status_module() {
  status_init

  if command -v fnm >/dev/null 2>&1; then
    eval "$(fnm env --shell bash 2>/dev/null || true)"
    if [[ "$(fnm current 2>/dev/null || printf 'system')" != "system" ]]; then
      STATUS_INSTALLED="yes"
      STATUS_NOTE="fnm and a Node.js runtime are installed; shell startup is owned by the zsh module."
    else
      STATUS_INSTALLED="no"
      STATUS_NOTE="fnm is installed, but no Node.js runtime is active."
    fi
  else
    STATUS_INSTALLED="no"
    STATUS_NOTE="fnm is not installed yet."
  fi

  if managed_block_present "$HOME/.zshrc" "fnm-init"; then
    STATUS_LINKED="no"
    STATUS_NOTE="Legacy fnm init block still exists in ~/.zshrc."
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
