#!/usr/bin/env bash

set -euo pipefail

MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/bootstrap.sh
source "$MODULE_DIR/../lib/bootstrap.sh"

BASE_FORMULAS=(
  coreutils
  bat
  eza
  fd
  gum
  jq
  ripgrep
)

BASE_CASKS=(
  font-hack-nerd-font
  font-0xproto-nerd-font
  font-caskaydia-cove-nerd-font
  font-iosevka-nerd-font
  ghostty
)

install_module() {
  local formula
  local cask

  for formula in "${BASE_FORMULAS[@]}"; do
    ensure_brew_formula "$formula"
  done

  for cask in "${BASE_CASKS[@]}"; do
    ensure_brew_cask "$cask"
  done
}

link_module() {
  stow_module_if_needed "$MODULE_DIR"
}

uninstall_module() {
  local formula
  local cask

  unstow_module_if_needed "$MODULE_DIR"

  for formula in "${BASE_FORMULAS[@]}"; do
    remove_brew_formula_if_present "$formula"
  done

  for cask in "${BASE_CASKS[@]}"; do
    remove_brew_cask_if_present "$cask"
  done
}

status_module() {
  local formula
  local cask
  local missing=()

  status_init

  for formula in "${BASE_FORMULAS[@]}"; do
    if ! brew_formula_installed "$formula"; then
      missing+=("$formula")
    fi
  done

  for cask in "${BASE_CASKS[@]}"; do
    if ! brew_cask_installed "$cask"; then
      missing+=("$cask")
    fi
  done

  if [[ "${#missing[@]}" -eq 0 ]]; then
    STATUS_INSTALLED="yes"
    STATUS_NOTE="Base CLI tools and fonts are installed."
  else
    STATUS_INSTALLED="no"
    STATUS_NOTE="Missing: ${missing[*]}"
  fi

  STATUS_LINKED="na"
  status_emit
}

module_dispatch "$@"
