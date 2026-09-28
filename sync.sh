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

# Ghostty icon on Linux: same retro icon as macos-icon in config.macos.
# Copy the installed desktop entry to ~/.local/share/applications (which takes
# precedence) with Icon= pointing at the repo image.
if [[ "$OS" == linux ]]; then
  apps="${XDG_DATA_HOME:-$HOME/.local/share}/applications"
  for src in /var/lib/snapd/desktop/applications/ghostty_ghostty.desktop \
             /usr/share/applications/com.mitchellh.ghostty.desktop; do
    [[ -f "$src" ]] || continue
    mkdir -p "$apps"
    sed "s|^Icon=.*|Icon=$DOT/ghostty/icons/retro.png|" "$src" > "$apps/$(basename "$src")"
    echo "icon    $apps/$(basename "$src")"
    break
  done
fi

# herdr: only config.toml (the folder also holds sockets, logs and session state)
link "$DOT/herdr/config.toml" "$CFG/herdr/config.toml"
link "$DOT/herdr/close-pane.sh" "$CFG/herdr/close-pane.sh"

if command -v herdr >/dev/null 2>&1; then
  herdr config check
  herdr server reload-config >/dev/null 2>&1 && echo "herdr config reloaded" || true
fi
