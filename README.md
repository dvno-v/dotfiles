# dotfiles

Configuration for [Fastfetch](https://github.com/fastfetch-cli/fastfetch) and [Kitty](https://sw.kovidgoyal.net/kitty/).

## Install

Install Fastfetch and Kitty first, then clone this repository and copy the configs into their standard locations:

```sh
git clone https://github.com/dvno-v/dotfiles.git
cd dotfiles
mkdir -p "$HOME/.config/fastfetch" "$HOME/.config/kitty"
cp -i fastfetch/config.jsonc fastfetch/logo.txt "$HOME/.config/fastfetch/"
cp -i kitty/kitty.conf "$HOME/.config/kitty/"
```

The `cp -i` commands ask before replacing any existing config files. Fastfetch needs both `config.jsonc` and `logo.txt` in the same directory because the config loads the logo from `~/.config/fastfetch/logo.txt`.

Kitty is configured to use JetBrains Mono; install that font or change `font_family` in `~/.config/kitty/kitty.conf` to one you have.
