#!/usr/bin/env bash

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./lib/bootstrap.sh
source "$REPO_ROOT/lib/bootstrap.sh"

DEFAULT_MODULES=(
  brew
  stow
  base
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
  ui_banner "hero dotfiles bootstrap"
}

usage() {
  cat <<'EOF'
Usage:
  ./scripts.sh
  ./scripts.sh menu
  ./scripts.sh status
  ./scripts.sh install [module...]
  ./scripts.sh link [module...]
  ./scripts.sh uninstall [module...]
  ./scripts.sh all [module...]

Behavior:
  - no arguments opens the interactive menu
  - 'status' shows the current module dashboard
  - 'all' runs install and then link for the selected modules
EOF
}

module_script_for() {
  local module="$1"
  printf '%s/%s/install.sh\n' "$REPO_ROOT" "$module"
}

validate_modules() {
  local module
  local script

  for module in "$@"; do
    script="$(module_script_for "$module")"
    [[ -f "$script" ]] || fail "Missing module installer: $script"
  done
}

collect_module_status() {
  local module="$1"
  local script
  local key
  local value

  STATUS_INSTALLED="no"
  STATUS_LINKED="na"
  STATUS_NOTE=""

  script="$(module_script_for "$module")"

  while IFS=$'\t' read -r key value; do
    case "$key" in
      installed)
        STATUS_INSTALLED="$value"
        ;;
      linked)
        STATUS_LINKED="$value"
        ;;
      note)
        STATUS_NOTE="$value"
        ;;
    esac
  done < <(bash "$script" status)
}

status_badge() {
  local value="$1"

  case "$value" in
    yes)
      colorize "$COLOR_GREEN" "yes"
      ;;
    no)
      colorize "$COLOR_RED" "no"
      ;;
    na)
      colorize "$COLOR_DIM" "n/a"
      ;;
    *)
      printf '%s' "$value"
      ;;
  esac
}

status_cell() {
  local value="$1"
  local width="$2"
  local raw
  local pad

  case "$value" in
    yes)
      raw="yes"
      ;;
    no)
      raw="no"
      ;;
    na)
      raw="n/a"
      ;;
    *)
      raw="$value"
      ;;
  esac

  pad=$((width - ${#raw}))
  if (( pad < 1 )); then
    pad=1
  fi

  printf '%s' "$(status_badge "$value")"
  printf '%*s' "$pad" ''
}

print_status_table() {
  local module

  printf '%-3s %-14s %-10s %-8s %s\n' "#" "module" "installed" "linked" "note"
  printf '%-3s %-14s %-10s %-8s %s\n' "---" "--------------" "----------" "--------" "--------------------------------"

  local index=1
  for module in "${DEFAULT_MODULES[@]}"; do
    collect_module_status "$module"
    printf '%-3s %-14s ' "$index" "$module"
    status_cell "$STATUS_INSTALLED" 11
    status_cell "$STATUS_LINKED" 9
    printf '%s\n' "${STATUS_NOTE:-}"
    index=$((index + 1))
  done
}

display_status_table() {
  ui_section_heading "Current status"
  printf '%s\n' ""

  if has_gum; then
    gum spin \
      --spinner pulse \
      --title "Loading modules..." \
      --show-output \
      -- "$REPO_ROOT/scripts.sh" _render_status_table
  else
    print_status_table
  fi
}

run_action_for_modules() {
  local action="$1"
  shift

  local module
  local script

  validate_modules "$@"

  for module in "$@"; do
    script="$(module_script_for "$module")"
    info "Running $action for module: $module"
    bash "$script" "$action"
    refresh_runtime_environment
  done
}

run_install_missing() {
  local module
  local ran=0

  for module in "${DEFAULT_MODULES[@]}"; do
    collect_module_status "$module"
    if [[ "$STATUS_INSTALLED" != "yes" ]]; then
      run_action_for_modules install "$module"
      ran=1
    fi
  done

  if [[ "$ran" -eq 0 ]]; then
    info "Nothing to install. All modules already look installed."
  fi
}

run_link_missing() {
  local module
  local ran=0

  for module in "${DEFAULT_MODULES[@]}"; do
    collect_module_status "$module"
    if [[ "$STATUS_LINKED" == "no" ]]; then
      run_action_for_modules link "$module"
      ran=1
    fi
  done

  if [[ "$ran" -eq 0 ]]; then
    info "Nothing to link. No modules currently report an unlinked state."
  fi
}

pause_for_input() {
  if [[ -t 0 ]]; then
    printf '\nPress Enter to continue...'
    read -r _
  fi
}

clear_if_interactive() {
  if [[ -t 1 ]]; then
    printf '\033[H\033[2J'
  fi
}

choose_module() {
  local prompt="$1"
  local selection
  local max="${#DEFAULT_MODULES[@]}"

  if has_gum; then
    if ! CHOSEN_MODULE="$(gum choose --header "$prompt" "${DEFAULT_MODULES[@]}")"; then
      return 1
    fi
    return 0
  fi

  printf '\n%s\n' "$prompt"
  display_status_table
  printf '\nEnter a module number (1-%s), or press Enter to cancel: ' "$max"
  read -r selection

  if [[ -z "$selection" ]]; then
    return 1
  fi

  if [[ ! "$selection" =~ ^[0-9]+$ ]]; then
    warn "Invalid selection: $selection"
    return 1
  fi

  if (( selection < 1 || selection > max )); then
    warn "Selection out of range: $selection"
    return 1
  fi

  CHOSEN_MODULE="${DEFAULT_MODULES[$((selection - 1))]}"
  return 0
}

confirm() {
  local prompt="$1"
  local answer

  if has_gum; then
    gum confirm "$prompt"
    return $?
  fi

  printf '%s [y/N]: ' "$prompt"
  read -r answer
  [[ "$answer" == "y" || "$answer" == "Y" ]]
}

show_dashboard() {
  clear_if_interactive
  banner
  display_status_table
}

menu_choice() {
  if has_gum; then
    if ! MENU_CHOICE="$(
      gum choose \
      --header "Choose an action" \
      "Install all missing modules" \
      "Link all unlinked modules" \
      "Install one module" \
      "Link one module" \
      "Uninstall one module" \
      "Refresh status" \
      "Quit"
    )"; then
      return 1
    fi
    return 0
  fi

  cat <<'EOF'

Menu
  1. Install all missing modules
  2. Link all unlinked modules
  3. Install one module
  4. Link one module
  5. Uninstall one module
  6. Refresh status
  q. Quit
EOF

  printf '\nChoose an option: '
  read -r MENU_CHOICE
}

interactive_menu() {
  while true; do
    refresh_runtime_environment
    show_dashboard

    if ! menu_choice; then
      break
    fi

    case "$MENU_CHOICE" in
      1|"Install all missing modules")
        run_install_missing
        pause_for_input
        ;;
      2|"Link all unlinked modules")
        run_link_missing
        pause_for_input
        ;;
      3|"Install one module")
        if choose_module "Install which module?"; then
          run_action_for_modules install "$CHOSEN_MODULE"
        fi
        pause_for_input
        ;;
      4|"Link one module")
        if choose_module "Link which module?"; then
          run_action_for_modules link "$CHOSEN_MODULE"
        fi
        pause_for_input
        ;;
      5|"Uninstall one module")
        if choose_module "Uninstall which module?"; then
          if confirm "Uninstall module '$CHOSEN_MODULE'?"; then
            run_action_for_modules uninstall "$CHOSEN_MODULE"
          fi
        fi
        pause_for_input
        ;;
      6|"Refresh status")
        ;;
      q|Q|"Quit")
        break
        ;;
      *)
        warn "Unknown option: $choice"
        pause_for_input
        ;;
    esac
  done
}

main() {
  local action="${1:-menu}"
  shift || true

  ensure_macos
  validate_modules "${DEFAULT_MODULES[@]}"
  refresh_runtime_environment

  case "$action" in
    menu)
      interactive_menu
      ;;
    status)
      banner
      display_status_table
      ;;
    _render_status_table)
      printf '\n\n\n'
      print_status_table
      ;;
    install|link|uninstall)
      if [[ "$#" -eq 0 ]]; then
        set -- "${DEFAULT_MODULES[@]}"
      fi
      run_action_for_modules "$action" "$@"
      ;;
    all)
      if [[ "$#" -eq 0 ]]; then
        set -- "${DEFAULT_MODULES[@]}"
      fi
      run_action_for_modules install "$@"
      run_action_for_modules link "$@"
      ;;
    -h|--help|help)
      usage
      ;;
    *)
      fail "Unknown action: $action"
      ;;
  esac
}

main "$@"
