#!/usr/bin/env bash

set -euo pipefail

MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/bootstrap.sh
source "$MODULE_DIR/../lib/bootstrap.sh"

install_module() {
  ensure_brew_cask google-cloud-sdk
}

link_module() {
  ensure_dir "$HOME/.config/gcloud"
  stow_module_if_needed "$MODULE_DIR"
  warn "Google Cloud SDK is installed. Run 'gcloud init' to finish account setup."
}

uninstall_module() {
  unstow_module_if_needed "$MODULE_DIR"
  remove_brew_cask_if_present google-cloud-sdk
}

status_module() {
  status_init

  if command -v gcloud >/dev/null 2>&1; then
    STATUS_INSTALLED="yes"
    if [[ -d "$HOME/.config/gcloud/configurations" ]]; then
      STATUS_NOTE="Google Cloud SDK is installed and has local configuration."
    else
      STATUS_NOTE="Google Cloud SDK is installed, but gcloud is not initialized."
    fi
  else
    STATUS_INSTALLED="no"
    STATUS_NOTE="Google Cloud SDK is not installed yet."
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
