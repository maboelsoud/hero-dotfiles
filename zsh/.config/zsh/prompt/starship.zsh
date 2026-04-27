export STARSHIP_CONFIG="${STARSHIP_CONFIG:-$HOME/hero_dotfiles/starship/.config/starship.toml}"

if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
else
  source "$HOME/.config/zsh/prompt/legacy.zsh"
fi
