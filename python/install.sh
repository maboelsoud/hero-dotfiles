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

uninstall_module() {
  remove_managed_block "$HOME/.zprofile" "uv-local-bin"
  unstow_module_if_needed "$MODULE_DIR"
  remove_brew_formula_if_present uv
  warn "Any Python versions already installed by uv were left in place."
}

status_module() {
  status_init

  if command -v uv >/dev/null 2>&1 && uv python find "$PYTHON_VERSION" >/dev/null 2>&1; then
    STATUS_INSTALLED="yes"
    STATUS_NOTE="uv and Python $PYTHON_VERSION are installed."
  elif command -v uv >/dev/null 2>&1; then
    STATUS_INSTALLED="no"
    STATUS_NOTE="uv is installed, but Python $PYTHON_VERSION is missing."
  else
    STATUS_INSTALLED="no"
    STATUS_NOTE="uv is not installed yet."
  fi

  if managed_block_present "$HOME/.zprofile" "uv-local-bin"; then
    STATUS_LINKED="yes"
  else
    STATUS_LINKED="no"
  fi

  status_emit
}

module_dispatch "$@"
