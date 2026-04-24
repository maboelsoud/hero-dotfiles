#!/usr/bin/env bash

set -euo pipefail

MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/bootstrap.sh
source "$MODULE_DIR/../lib/bootstrap.sh"

install_module() {
  info "No separate SSH package installation needed on macOS."
}

link_module() {
  ensure_dir "$HOME/.ssh"
  chmod 700 "$HOME/.ssh"
  stow_module_if_needed "$MODULE_DIR"
}

module_dispatch "$@"
