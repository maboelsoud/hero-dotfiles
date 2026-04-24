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

module_dispatch "$@"
