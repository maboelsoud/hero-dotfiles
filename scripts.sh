#!/usr/bin/env bash

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./lib/bootstrap.sh
source "$REPO_ROOT/lib/bootstrap.sh"

DEFAULT_MODULES=(
  brew
  stow
  zsh
  autocomplete
  starship
  atuin
  zoxide
  fzf
  python
  node
  npm
  vim
  docker
  aws
  gcp
  ssh
)

banner() {
  cat <<'EOF'
========================================
 hero dotfiles bootstrap
========================================
EOF
}

usage() {
  cat <<'EOF'
Usage:
  ./scripts.sh
  ./scripts.sh install
  ./scripts.sh link
  ./scripts.sh all
  ./scripts.sh all brew stow zsh

Behavior:
  - default action is 'all'
  - default module order is the repo bootstrap order
  - optional module names let you run a subset in your chosen order
EOF
}

module_script_for() {
  local module="$1"
  printf '%s/%s/install.sh\n' "$REPO_ROOT" "$module"
}

validate_modules() {
  local module
  local script

  for module in "${MODULES[@]}"; do
    script="$(module_script_for "$module")"
    [[ -f "$script" ]] || fail "Missing module installer: $script"
  done
}

run_phase() {
  local phase="$1"
  local module
  local script

  info "Starting '$phase' phase."

  for module in "${MODULES[@]}"; do
    script="$(module_script_for "$module")"
    info "Running $phase for module: $module"
    bash "$script" "$phase"
    refresh_runtime_environment
  done
}

print_next_steps() {
  cat <<'EOF'

Bootstrap complete.

Likely next manual steps:
  - open Docker once so macOS finishes app setup
  - run 'aws configure' or 'aws configure sso'
  - run 'gcloud init'
  - run 'atuin register' or 'atuin login'
  - add real config files to each module directory, then rerun './scripts.sh link'
EOF
}

main() {
  local action="${1:-all}"

  case "$action" in
    all|install|link)
      shift || true
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      action="all"
      ;;
  esac

  if [[ "$#" -gt 0 ]]; then
    MODULES=("$@")
  else
    MODULES=("${DEFAULT_MODULES[@]}")
  fi

  if [[ "${#MODULES[@]}" -eq 0 ]]; then
    MODULES=("${DEFAULT_MODULES[@]}")
  fi

  banner
  ensure_macos
  validate_modules
  refresh_runtime_environment

  info "Module order: ${MODULES[*]}"

  case "$action" in
    install)
      run_phase install
      ;;
    link)
      run_phase link
      ;;
    all)
      run_phase install
      run_phase link
      print_next_steps
      ;;
  esac
}

main "$@"
