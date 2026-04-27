if [[ -x "$HOME/.local/bin/python3" ]]; then
  export CLOUDSDK_PYTHON="$HOME/.local/bin/python3"
fi

for sdk_root in /opt/homebrew/share/google-cloud-sdk /usr/local/share/google-cloud-sdk; do
  [[ -d "$sdk_root" ]] || continue

  case ":$PATH:" in
    *":$sdk_root/bin:"*) ;;
    *) export PATH="$sdk_root/bin:$PATH" ;;
  esac

  if [[ -o interactive && -f "$sdk_root/completion.zsh.inc" ]]; then
    source "$sdk_root/completion.zsh.inc"
  fi

  break
done

unset sdk_root
