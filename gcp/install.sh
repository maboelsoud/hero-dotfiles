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

module_dispatch "$@"
