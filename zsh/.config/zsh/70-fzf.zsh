export FZF_DEFAULT_OPTS='--height=40% --layout=reverse --border --color=bg+:#3B4252,bg:#2E3440,spinner:#81A1C1,hl:#616E88,fg:#D8DEE9,header:#616E88,info:#81A1C1,pointer:#81A1C1,marker:#81A1C1,fg+:#D8DEE9,prompt:#81A1C1,hl+:#81A1C1'

if command -v brew >/dev/null 2>&1; then
  fzf_prefix="$(brew --prefix fzf 2>/dev/null || true)"

  [[ -f "$fzf_prefix/shell/completion.zsh" ]] && source "$fzf_prefix/shell/completion.zsh"
  [[ -f "$fzf_prefix/shell/key-bindings.zsh" ]] && source "$fzf_prefix/shell/key-bindings.zsh"
fi

is_in_git_repo() {
  git rev-parse HEAD >/dev/null 2>&1
}

fzf-down() {
  fzf --height 50% --min-height 20 --border --bind ctrl-/:toggle-preview "$@"
}

_gf() {
  is_in_git_repo || return
  git -c color.status=always status --short |
    fzf-down -m --ansi --nth 2..,.. \
      --preview '(git diff --color=always -- {-1} | sed 1,4d; bat --style=numbers --color=always --line-range :200 -- {-1} 2>/dev/null || cat {-1})' |
    cut -c4- | sed 's/.* -> //'
}

_gb() {
  is_in_git_repo || return
  git branch -a --color=always | grep -v '/HEAD\s' | sort |
    fzf-down --ansi --multi --tac --preview-window right:70% \
      --preview 'git log --oneline --graph --date=short --color=always --pretty="format:%C(auto)%cd %h%d %s" $(sed s/^..// <<< {} | cut -d" " -f1)' |
    sed 's/^..//' | cut -d' ' -f1 |
    sed 's#^remotes/##'
}

_gt() {
  is_in_git_repo || return
  git tag --sort -version:refname |
    fzf-down --multi --preview-window right:70% \
      --preview 'git show --color=always {}'
}

_gh() {
  is_in_git_repo || return
  git log --date=short --format="%C(green)%C(bold)%cd %C(auto)%h%d %s (%an)" --graph --color=always |
    fzf-down --ansi --no-sort --reverse --multi --bind 'ctrl-s:toggle-sort' \
      --header 'Press CTRL-S to toggle sort' \
      --preview 'grep -o "[a-f0-9]\{7,\}" <<< {} | xargs git show --color=always' |
    grep -o "[a-f0-9]\{7,\}"
}

_gr() {
  is_in_git_repo || return
  git remote -v | awk '{print $1 "\t" $2}' | uniq |
    fzf-down --tac \
      --preview 'git log --oneline --graph --date=short --pretty="format:%C(auto)%cd %h%d %s" {1}' |
    cut -d$'\t' -f1
}

_gs() {
  is_in_git_repo || return
  git stash list |
    fzf-down --reverse -d: --preview 'git show --color=always {1}' |
    cut -d: -f1
}

join-lines() {
  local item
  while read -r item; do
    printf '%s ' "${(q)item}"
  done
}

() {
  local command

  for command in "$@"; do
    eval "fzf-g${command}-widget() { local result=\$(_g${command} | join-lines); zle reset-prompt; LBUFFER+=\$result }"
    eval "zle -N fzf-g${command}-widget"
    eval "bindkey '^g^${command}' fzf-g${command}-widget"
  done
} f b t r h s
