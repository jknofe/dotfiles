# dotfiles

Configs for [herdr](https://herdr.dev) and [Ghostty](https://ghostty.org), shared between macOS and Ubuntu.

```
herdr/config.toml        herdr keys and theme (Wave colors)
ghostty/config           shared Ghostty config (font, theme)
ghostty/config.macos     macOS only: left Option as alt, cmd keys handed to herdr, Display P3
ghostty/config.linux     Linux only
ghostty/themes/WaveVivid color theme converted from Wave Terminal
sync.sh                  pull and link everything into ~/.config
```

## New host

```sh
git clone https://github.com/jknofe/dotfiles.git ~/dotfiles
~/dotfiles/sync.sh
```

Existing files are moved to `*.bak.<timestamp>` before linking.

## Update

Edit the files in `~/.config` as usual (they are symlinks into this repo), then:

```sh
cd ~/dotfiles && git commit -am "..." && git push   # on the host you changed
~/dotfiles/sync.sh                                   # on the other hosts
```
