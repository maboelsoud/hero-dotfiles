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
  ensure_managed_block "$HOME/.zshrc" "fnm-init" 'eval "$(fnm env --use-on-cd --shell zsh)"'
  stow_module_if_needed "$MODULE_DIR"
}

module_dispatch "$@"
