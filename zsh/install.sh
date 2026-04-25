#!/usr/bin/env bash

set -euo pipefail

MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_BREW_ZSH="${HERO_INSTALL_BREW_ZSH:-0}"
# shellcheck source=../lib/bootstrap.sh
source "$MODULE_DIR/../lib/bootstrap.sh"

install_module() {
  if [[ "$INSTALL_BREW_ZSH" == "1" ]]; then
    ensure_brew_formula zsh
  elif command -v zsh >/dev/null 2>&1; then
    info "Using bundled/system zsh. Set HERO_INSTALL_BREW_ZSH=1 to install Homebrew zsh explicitly."
  else
    ensure_brew_formula zsh
  fi

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

  if command -v zsh >/dev/null 2>&1 && brew_formula_installed zsh-autosuggestions && brew_formula_installed zsh-syntax-highlighting; then
    STATUS_INSTALLED="yes"
    if brew_formula_installed zsh; then
      STATUS_NOTE="Homebrew zsh and shell plugins are installed."
    else
      STATUS_NOTE="System zsh is available and shell plugins are installed."
    fi
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
