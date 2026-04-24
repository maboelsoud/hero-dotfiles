#!/usr/bin/env bash

set -euo pipefail

MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PYTHON_VERSION="${PYTHON_VERSION:-3.12}"
# shellcheck source=../lib/bootstrap.sh
source "$MODULE_DIR/../lib/bootstrap.sh"

install_module() {
  ensure_brew_formula uv
  info "Installing Python $PYTHON_VERSION with uv."
  uv python install "$PYTHON_VERSION"
}

link_module() {
  ensure_managed_block "$HOME/.zprofile" "uv-local-bin" 'export PATH="$HOME/.local/bin:$PATH"'
  stow_module_if_needed "$MODULE_DIR"
}

module_dispatch "$@"
