#!/usr/bin/env bash

set -euo pipefail

MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXTENSIONS_FILE="$MODULE_DIR/extensions.txt"
# shellcheck source=../lib/bootstrap.sh
source "$MODULE_DIR/../lib/bootstrap.sh"

cursor_cli_bin() {
  resolve_first_existing_path \
    "${CURSOR_CLI_BIN:-}" \
    /Applications/Cursor.app/Contents/Resources/app/bin/cursor \
    /opt/homebrew/bin/cursor \
    /usr/local/bin/cursor
}

install_module() {
  ensure_brew_cask cursor
  install_extensions_from_file "$(cursor_cli_bin)" "$EXTENSIONS_FILE"
}

link_module() {
  backup_conflicting_module_targets "$MODULE_DIR"
  stow_module_no_folding_if_needed "$MODULE_DIR"
}

uninstall_module() {
  unstow_module_if_needed "$MODULE_DIR"
  remove_brew_cask_if_present cursor
}

status_module() {
  status_init

  if brew_cask_installed cursor; then
    STATUS_INSTALLED="yes"
    STATUS_NOTE="Cursor is installed."
  else
    STATUS_INSTALLED="no"
    STATUS_NOTE="Cursor is not installed yet."
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
