#!/usr/bin/env bash

set -euo pipefail

MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PNPM_VERSION="${PNPM_VERSION:-latest}"
# shellcheck source=../lib/bootstrap.sh
source "$MODULE_DIR/../lib/bootstrap.sh"

install_module() {
  command -v fnm >/dev/null 2>&1 || fail "fnm must be installed before npm setup."
  eval "$(fnm env --shell bash)"
  command -v corepack >/dev/null 2>&1 || fail "corepack was not found. Install the node module first."

  info "Enabling corepack and activating pnpm@$PNPM_VERSION."
  corepack enable
  corepack prepare "pnpm@$PNPM_VERSION" --activate
}

link_module() {
  stow_module_if_needed "$MODULE_DIR"
}

module_dispatch "$@"
