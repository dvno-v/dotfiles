# dotfiles

Configuration for [Fastfetch](https://github.com/fastfetch-cli/fastfetch), [Kitty](https://sw.kovidgoyal.net/kitty/), [fish](https://fishshell.com/), [rofi](https://github.com/davatorium/rofi) and a Gruvbox Flat KDE Plasma 6 desktop.

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

## KDE Plasma: Gruvbox Flat

A flat Gruvbox Material desktop: a full-width top bar (launcher, numbered workspaces, active app name, centred clock, a running pixel cat, status icons), a floating dock on the left that dodges windows, and rofi on <kbd>Alt</kbd>+<kbd>Space</kbd>.

### Requirements

KDE Plasma 6 (made on Plasma 6.8, Wayland). Package names are for Arch / CachyOS:

| Package | Why |
| --- | --- |
| `plasma-desktop`, `kwin` | Plasma 6 itself; the theme, widgets and panel script need it |
| `rofi` (2.0 or newer) | App launcher on Alt+Space. Older distros: `rofi-wayland` |
| `ttf-jetbrains-mono-nerd` | Font for the clock and rofi |
| `qt6-tools` | Provides `qdbus6`, which the install script uses |
| `kitty` | Pinned in the dock (see the Kitty config above) |
| `plasma-nm`, `plasma-pa`, `powerdevil` | Wi-Fi, volume, brightness and battery icons. Usually installed with Plasma; the script skips any that are missing |

```sh
sudo pacman -S --needed rofi ttf-jetbrains-mono-nerd qt6-tools kitty
```

### Install

Run from a terminal inside your Plasma session:

```sh
cd dotfiles
bash kde/install.sh
```

The script:

1. Backs up `kdeglobals`, `plasmarc`, `plasmashellrc`, the panel layout, `kwinrc`, `kglobalshortcutsrc` and `~/.config/rofi` to `~/kde-theme-backup-<date>`.
2. Installs the colour scheme, the `gruvbox-flat` Plasma style, the three custom widgets and the rofi config.
3. Applies the colour scheme and Plasma style, and enables KWin blur.
4. **Replaces all panels** with the top bar and dock (`kde/layout.js`).
5. Binds Alt+Space to rofi and leaves KRunner on Alt+F2.

To undo, copy the files from the backup folder back into `~/.config` and log out and in.

### What's in `kde/`

| Path | Installed to |
| --- | --- |
| `color-schemes/GruvboxFlat.colors` | `~/.local/share/color-schemes/` |
| `desktoptheme/gruvbox-flat/` | `~/.local/share/plasma/desktoptheme/` |
| `plasmoids/local.gruvbox.workspaces/` | `~/.local/share/plasma/plasmoids/` (numbered workspaces) |
| `plasmoids/local.gruvbox.windowtitle/` | `~/.local/share/plasma/plasmoids/` (active app name) |
| `plasmoids/local.tokyonight.cat/` | `~/.local/share/plasma/plasmoids/` (the running cat; click to pause) |
| `applications/rofi-launcher.desktop` | `~/.local/share/applications/` (the Alt+Space shortcut target) |
| `layout.js` | Run by `install.sh` through Plasma's desktop scripting |
| `../rofi/` | `~/.config/rofi/` |

Not included: the wallpaper, and GTK app colours, which Plasma generates from the colour scheme automatically. Icons and cursor are the stock Breeze Dark and Breeze.

### rofi only

```sh
mkdir -p "$HOME/.config/rofi/themes"
cp -i rofi/config.rasi "$HOME/.config/rofi/"
cp -i rofi/themes/gruvbox-flat.rasi "$HOME/.config/rofi/themes/"
```
