#!/usr/bin/env bash

set -euo pipefail

MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/bootstrap.sh
source "$MODULE_DIR/../lib/bootstrap.sh"

install_module() {
  ensure_brew_formula zoxide
}

link_module() {
  ensure_managed_block "$HOME/.zshrc" "zoxide-init" 'eval "$(zoxide init zsh)"'
  stow_module_if_needed "$MODULE_DIR"
}

module_dispatch "$@"
