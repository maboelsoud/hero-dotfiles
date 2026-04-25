[[ -o interactive ]] || return 0

for config in "$HOME"/.config/zsh/*.zsh; do
  [[ -f "$config" ]] || continue
  source "$config"
done
