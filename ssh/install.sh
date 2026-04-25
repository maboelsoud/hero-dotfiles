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

uninstall_module() {
  unstow_module_if_needed "$MODULE_DIR"
}

status_module() {
  status_init

  STATUS_INSTALLED="yes"
  STATUS_NOTE="OpenSSH is built into macOS."

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
