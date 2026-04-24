#!/usr/bin/env bash

set -euo pipefail

MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/bootstrap.sh
source "$MODULE_DIR/../lib/bootstrap.sh"

install_module() {
  ensure_homebrew
  info "Updating Homebrew metadata."
  brew update
}

link_module() {
  local brew_path

  brew_path="$(brew_bin)" || fail "Homebrew was not found during brew link step."
  ensure_managed_block "$HOME/.zprofile" "homebrew-shellenv" "eval \"\$($brew_path shellenv)\""
  setup_brew_env
  stow_module_if_needed "$MODULE_DIR"
}

module_dispatch "$@"
