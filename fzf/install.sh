#!/usr/bin/env bash

set -euo pipefail

MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/bootstrap.sh
source "$MODULE_DIR/../lib/bootstrap.sh"

install_module() {
  ensure_brew_formula fzf
}

link_module() {
  ensure_managed_block "$HOME/.zshrc" "fzf-zsh" $'if [[ -f "$(brew --prefix)/opt/fzf/shell/completion.zsh" ]]; then\n  source "$(brew --prefix)/opt/fzf/shell/completion.zsh"\nfi\nif [[ -f "$(brew --prefix)/opt/fzf/shell/key-bindings.zsh" ]]; then\n  source "$(brew --prefix)/opt/fzf/shell/key-bindings.zsh"\nfi'
  stow_module_if_needed "$MODULE_DIR"
}

module_dispatch "$@"
