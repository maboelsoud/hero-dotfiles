#!/usr/bin/env bash

set -euo pipefail

MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/bootstrap.sh
source "$MODULE_DIR/../lib/bootstrap.sh"

install_module() {
  ensure_brew_cask docker
}

link_module() {
  warn "Docker Desktop is installed, but you still need to open it once to finish setup."
  stow_module_if_needed "$MODULE_DIR"
}

uninstall_module() {
  unstow_module_if_needed "$MODULE_DIR"
  remove_brew_cask_if_present docker
}

status_module() {
  status_init

  if brew_cask_installed docker || [[ -d "/Applications/Docker.app" ]]; then
    STATUS_INSTALLED="yes"
    STATUS_NOTE="Docker Desktop is installed."
  else
    STATUS_INSTALLED="no"
    STATUS_NOTE="Docker Desktop is not installed yet."
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
