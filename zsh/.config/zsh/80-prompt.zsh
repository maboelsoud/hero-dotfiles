export HERO_PROMPT_STYLE="${HERO_PROMPT_STYLE:-legacy}"

hero_prompt_set() {
  case "${1:-$HERO_PROMPT_STYLE}" in
    legacy)
      export HERO_PROMPT_STYLE="legacy"
      source "$HOME/.config/zsh/prompt/legacy.zsh"
      ;;
    starship)
      export HERO_PROMPT_STYLE="starship"
      source "$HOME/.config/zsh/prompt/starship.zsh"
      ;;
    *)
      export HERO_PROMPT_STYLE="starship"
      source "$HOME/.config/zsh/prompt/starship.zsh"
      ;;
  esac
}

hero_prompt_choose() {
  local choice

  if command -v gum >/dev/null 2>&1; then
    choice=$(gum choose starship legacy) || return
  else
    printf 'Choose a prompt: starship or legacy\n' >&2
    return 1
  fi

  hero_prompt_set "$choice"
}

hero_prompt_set "$HERO_PROMPT_STYLE"
