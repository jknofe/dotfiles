#!/usr/bin/env bash
# Pull the latest dotfiles and link them into ~/.config on this host.
# Usage: ./sync.sh [--no-pull]
set -euo pipefail

DOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CFG="${XDG_CONFIG_HOME:-$HOME/.config}"

case "$(uname -s)" in
  Darwin) OS=macos ;;
  Linux)  OS=linux ;;
  *) echo "unsupported OS: $(uname -s)" >&2; exit 1 ;;
esac

if [[ "${1:-}" != "--no-pull" ]] && git -C "$DOT" remote get-url origin >/dev/null 2>&1; then
  git -C "$DOT" pull --ff-only
fi

# link <source in repo> <target>: symlink target to source, backing up anything already there
link() {
  local src="$1" dst="$2"
  if [[ -L "$dst" && "$(readlink "$dst")" == "$src" ]]; then
    echo "ok      $dst"
    return
  fi
  mkdir -p "$(dirname "$dst")"
  if [[ -e "$dst" || -L "$dst" ]]; then
    local bak="$dst.bak.$(date +%Y%m%d-%H%M%S)"
    mv "$dst" "$bak"
    echo "backup  $dst -> $bak"
  fi
  ln -s "$src" "$dst"
  echo "linked  $dst -> $src"
}

# Ghostty: whole folder, plus the OS-specific part as config.local
ln -sfn "config.$OS" "$DOT/ghostty/config.local"
link "$DOT/ghostty" "$CFG/ghostty"

# herdr: only config.toml (the folder also holds sockets, logs and session state)
link "$DOT/herdr/config.toml" "$CFG/herdr/config.toml"

if command -v herdr >/dev/null 2>&1; then
  herdr config check
  herdr server reload-config >/dev/null 2>&1 && echo "herdr config reloaded" || true
fi
