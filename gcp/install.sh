#!/usr/bin/env bash

set -euo pipefail

MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GCLOUD_PYTHON_VERSION="${GCLOUD_PYTHON_VERSION:-${PYTHON_VERSION:-3.12}}"
GCLOUD_PYTHON_BIN="${GCLOUD_PYTHON_BIN:-$HOME/.local/bin/python3}"
# shellcheck source=../lib/bootstrap.sh
source "$MODULE_DIR/../lib/bootstrap.sh"

brew_prefix() {
  local brew_path

  brew_path="$(brew_bin)" || return 1
  "$brew_path" --prefix
}

gcloud_sdk_root() {
  local prefix

  prefix="$(brew_prefix)" || return 1
  if [[ -d "$prefix/share/google-cloud-sdk" ]]; then
    printf '%s\n' "$prefix/share/google-cloud-sdk"
    return 0
  fi

  return 1
}

ensure_gcloud_python() {
  info "Ensuring a supported Python runtime for Google Cloud CLI."
  bash "$MODULE_DIR/../python/install.sh" install
  refresh_runtime_environment

  [[ -x "$GCLOUD_PYTHON_BIN" ]] || fail "Expected Google Cloud CLI Python at $GCLOUD_PYTHON_BIN after installing Python $GCLOUD_PYTHON_VERSION."
}

ensure_virtualenv_tool() {
  refresh_runtime_environment

  if command -v virtualenv >/dev/null 2>&1; then
    info "virtualenv is already available."
    return 0
  fi

  info "Installing virtualenv with uv so gcloud can create its managed environment."
  uv tool install virtualenv
  refresh_runtime_environment

  command -v virtualenv >/dev/null 2>&1 || fail "virtualenv is still unavailable after uv tool install."
}

ensure_virtualenv_brew_shim() {
  local prefix
  local shim_path
  local source_path

  prefix="$(brew_prefix)" || fail "Homebrew prefix could not be determined."
  shim_path="$prefix/bin/virtualenv"
  source_path="$HOME/.local/bin/virtualenv"

  [[ -x "$source_path" ]] || fail "Expected virtualenv shim at $source_path."

  if [[ -L "$shim_path" && "$shim_path" -ef "$source_path" ]]; then
    info "Homebrew-visible virtualenv shim already exists."
    return 0
  fi

  if [[ -e "$shim_path" && ! -L "$shim_path" ]]; then
    info "Keeping existing Homebrew virtualenv at $shim_path."
    return 0
  fi

  info "Linking virtualenv into Homebrew bin so the Google Cloud SDK installer can find it."
  ln -sfn "$source_path" "$shim_path"
}

gcloud_command_healthy() {
  local sdk_root
  local gcloud_bin

  sdk_root="$(gcloud_sdk_root)" || return 1
  gcloud_bin="$sdk_root/bin/gcloud"

  [[ -x "$gcloud_bin" ]] || return 1

  PATH="$HOME/.local/bin:$(brew_prefix)/bin:$PATH" \
    CLOUDSDK_PYTHON="$GCLOUD_PYTHON_BIN" \
    "$gcloud_bin" version >/dev/null 2>&1
}

repair_gcloud_install_if_needed() {
  local prefix
  local linked_bin

  prefix="$(brew_prefix)" || fail "Homebrew prefix could not be determined."
  linked_bin="$prefix/bin/gcloud"

  if [[ -x "$linked_bin" ]] && gcloud_command_healthy; then
    info "Google Cloud SDK is already linked and healthy."
    return 0
  fi

  info "Repairing Google Cloud SDK installation so gcloud uses $GCLOUD_PYTHON_BIN."
  brew reinstall --cask google-cloud-sdk
}

install_module() {
  ensure_gcloud_python
  ensure_virtualenv_tool
  ensure_virtualenv_brew_shim

  export PATH="$HOME/.local/bin:$PATH"
  export CLOUDSDK_PYTHON="$GCLOUD_PYTHON_BIN"

  info "Installing Google Cloud SDK with CLOUDSDK_PYTHON=$CLOUDSDK_PYTHON."
  ensure_homebrew

  if brew list --cask google-cloud-sdk >/dev/null 2>&1; then
    repair_gcloud_install_if_needed
  else
    brew install --cask google-cloud-sdk
  fi

  stow_module_if_needed "$MODULE_DIR"

  if ! gcloud_command_healthy; then
    fail "Google Cloud SDK installed, but gcloud still failed to start with $GCLOUD_PYTHON_BIN."
  fi
}

link_module() {
  ensure_dir "$HOME/.config/gcloud"
  stow_module_if_needed "$MODULE_DIR"
  warn "Google Cloud SDK is installed. Run 'gcloud init' to finish account setup."
}

uninstall_module() {
  local prefix
  local shim_path
  local source_path

  unstow_module_if_needed "$MODULE_DIR"
  remove_brew_cask_if_present google-cloud-sdk

  prefix="$(brew_prefix)" || return 0
  shim_path="$prefix/bin/virtualenv"
  source_path="$HOME/.local/bin/virtualenv"

  if [[ -L "$shim_path" && "$shim_path" -ef "$source_path" ]]; then
    rm -f "$shim_path"
  fi
}

status_module() {
  status_init

  if command -v gcloud >/dev/null 2>&1 || gcloud_sdk_root >/dev/null 2>&1 || brew_cask_installed google-cloud-sdk; then
    STATUS_INSTALLED="yes"
    if [[ -d "$HOME/.config/gcloud/configurations" ]]; then
      STATUS_NOTE="Google Cloud SDK is installed; shell integration and configuration may still need a refresh."
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
