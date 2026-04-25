#!/usr/bin/env bash

set -euo pipefail

MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/bootstrap.sh
source "$MODULE_DIR/../lib/bootstrap.sh"

install_module() {
  ensure_brew_formula awscli
}

link_module() {
  ensure_dir "$HOME/.aws"
  stow_module_if_needed "$MODULE_DIR"
  warn "AWS CLI is installed. Run 'aws configure' or 'aws configure sso' to finish credentials setup."
}

uninstall_module() {
  unstow_module_if_needed "$MODULE_DIR"
  remove_brew_formula_if_present awscli
}

status_module() {
  status_init

  if command -v aws >/dev/null 2>&1; then
    STATUS_INSTALLED="yes"
    if [[ -f "$HOME/.aws/config" || -f "$HOME/.aws/credentials" ]]; then
      STATUS_NOTE="AWS CLI is installed and credentials/config exist."
    else
      STATUS_NOTE="AWS CLI is installed, but credentials are not configured."
    fi
  else
    STATUS_INSTALLED="no"
    STATUS_NOTE="AWS CLI is not installed yet."
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
