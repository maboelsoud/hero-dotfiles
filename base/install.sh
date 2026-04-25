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

install_module() {
  local formula

  for formula in "${BASE_FORMULAS[@]}"; do
    ensure_brew_formula "$formula"
  done
}

link_module() {
  stow_module_if_needed "$MODULE_DIR"
}

uninstall_module() {
  local formula

  unstow_module_if_needed "$MODULE_DIR"

  for formula in "${BASE_FORMULAS[@]}"; do
    remove_brew_formula_if_present "$formula"
  done
}

status_module() {
  local formula
  local missing=()

  status_init

  for formula in "${BASE_FORMULAS[@]}"; do
    if ! brew_formula_installed "$formula"; then
      missing+=("$formula")
    fi
  done

  if [[ "${#missing[@]}" -eq 0 ]]; then
    STATUS_INSTALLED="yes"
    STATUS_NOTE="Base CLI tools are installed."
  else
    STATUS_INSTALLED="no"
    STATUS_NOTE="Missing: ${missing[*]}"
  fi

  STATUS_LINKED="na"
  status_emit
}

module_dispatch "$@"
