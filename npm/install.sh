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

uninstall_module() {
  unstow_module_if_needed "$MODULE_DIR"

  if command -v corepack >/dev/null 2>&1; then
    info "Disabling corepack shims."
    corepack disable || true
  fi

  warn "pnpm itself is managed through corepack and your active Node.js install."
}

status_module() {
  status_init

  if command -v pnpm >/dev/null 2>&1; then
    STATUS_INSTALLED="yes"
    STATUS_NOTE="pnpm is available through corepack."
  elif command -v corepack >/dev/null 2>&1; then
    STATUS_INSTALLED="no"
    STATUS_NOTE="corepack is present, but pnpm is not activated."
  else
    STATUS_INSTALLED="no"
    STATUS_NOTE="corepack is not available yet."
  fi

  if module_has_stow_payload "$MODULE_DIR"; then
    if module_payload_linked "$MODULE_DIR"; then
      STATUS_LINKED="yes"
    else
      STATUS_LINKED="no"
    fi
  else
    STATUS_LINKED="na"
  fi

  status_emit
}

module_dispatch "$@"
