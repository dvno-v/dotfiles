# dotfiles

My desktop setup for **Arch (including CachyOS) and Fedora** running **KDE Plasma 6**: a flat Gruvbox Material desktop, rofi as the app launcher, kitty with fastfetch, and fish.

| Folder | What it is | Goes to |
| --- | --- | --- |
| `fish/` | [fish](https://fishshell.com/) shell config and aliases | `~/.config/fish/` |
| `kitty/` | [Kitty](https://sw.kovidgoyal.net/kitty/) terminal (Tokyo Night colours) | `~/.config/kitty/` |
| `fastfetch/` | [Fastfetch](https://github.com/fastfetch-cli/fastfetch) system info with a custom logo | `~/.config/fastfetch/` |
| `rofi/` | [rofi](https://github.com/davatorium/rofi) launcher, Gruvbox theme | `~/.config/rofi/` |
| `kde/` | Plasma style, colour scheme, panel widgets and an install script | `~/.local/share/…` (see [step 5](#5-kde-plasma-gruvbox-flat)) |

On a fresh install, follow the steps in order. Steps 3 to 6 don't depend on each other, so you can also pick only the parts you want.

## 1. Install packages

### Arch / CachyOS

```sh
sudo pacman -S --needed git fish kitty fastfetch eza rofi ttf-jetbrains-mono-nerd qt6-tools flatpak
```

### Fedora (43 or 44)

Start from the Fedora KDE Plasma Desktop edition, then:

```sh
sudo dnf install git fish kitty fastfetch eza rofi qt6-qttools
```

Fedora doesn't package the JetBrains Mono **Nerd** Font, so install it from the Nerd Fonts release:

```sh
mkdir -p ~/.local/share/fonts/JetBrainsMonoNerdFont
curl -L https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz \
    | tar -xJ -C ~/.local/share/fonts/JetBrainsMonoNerdFont
fc-cache -f
```

### What each package is for

| Arch | Fedora | Used by |
| --- | --- | --- |
| `fish` | `fish` | Shell |
| `kitty` | `kitty` | Terminal; also pinned in the dock |
| `fastfetch` | `fastfetch` | Runs when a fish shell opens |
| `eza` | `eza` | The `ll` alias |
| `rofi` (2.0 or newer, native Wayland) | `rofi` (2.0 on Fedora 43 and 44) | App launcher on Alt+Space |
| `ttf-jetbrains-mono-nerd` | manual install above | Font for kitty, rofi, the clock and fastfetch icons |
| `qt6-tools` | `qt6-qttools` | Provides `qdbus6` / `qdbus-qt6` for the KDE install script |
| `flatpak` | preinstalled | The `update-all` alias also updates Flatpaks |

Plasma's own Wi-Fi, volume, brightness and battery widgets (`plasma-nm`, `plasma-pa`, `powerdevil`) come with a normal Plasma install on both distros.

## 2. Clone the repo

```sh
git clone https://github.com/dvno-v/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

All commands below run from `~/dotfiles`. The `cp -i` commands ask before replacing a file that already exists.

## 3. fish

```sh
mkdir -p ~/.config/fish
cp -i fish/config.fish fish/fish_variables ~/.config/fish/
chsh -s "$(command -v fish)"
```

Log out and back in for the shell change to take effect. CachyOS already uses fish, but its stock `config.fish` loads CachyOS's own fish setup; this one replaces it.

What the config adds:

- Runs fastfetch when an interactive shell opens, with no greeting.
- `ll` (eza with icons), `la`, `l`, `..`, `...`
- `cp`, `mv` and `rm` ask before overwriting or deleting.
- Git shortcuts: `g`, `gs`, `ga`, `gc "message"`, `gp`, `gl`
- `update-all` updates system packages (pacman on Arch, dnf on Fedora) and then Flatpaks.

## 4. kitty and fastfetch

```sh
mkdir -p ~/.config/kitty ~/.config/fastfetch
cp -i kitty/kitty.conf ~/.config/kitty/
cp -i fastfetch/config.jsonc fastfetch/logo.txt ~/.config/fastfetch/
```

Fastfetch needs `config.jsonc` and `logo.txt` in the same folder, because the config loads the logo from `~/.config/fastfetch/logo.txt`.

## 5. KDE Plasma: Gruvbox Flat

A flat Gruvbox Material desktop:

- a full-width top bar with the launcher, numbered workspaces, the active app's name, a centred clock, a running pixel cat (click it to pause) and status icons
- a floating dock on the left that moves out of the way of windows
- rofi on <kbd>Alt</kbd>+<kbd>Space</kbd>, while KRunner stays on <kbd>Alt</kbd>+<kbd>F2</kbd>

Run this from a terminal **inside your Plasma session** (it talks to the running desktop):

```sh
bash kde/install.sh
```

The script:

1. Backs up `kdeglobals`, `plasmarc`, `plasmashellrc`, the panel layout, `kwinrc`, `kglobalshortcutsrc` and `~/.config/rofi` to `~/kde-theme-backup-<date>`.
2. Installs the colour scheme, the `gruvbox-flat` Plasma style, the three custom widgets and the rofi config.
3. Applies the colour scheme and Plasma style, and turns on KWin blur.
4. **Replaces all your panels** with the top bar and dock (`kde/layout.js`).
5. Binds Alt+Space to rofi.

To undo it, copy the files from the backup folder back into `~/.config`, then log out and in.

It was made and tested on Plasma 6.8 (CachyOS). It handles Fedora's different tool names, but hasn't been run on a Fedora machine yet.

### What's in `kde/`

| Path | Installed to |
| --- | --- |
| `color-schemes/GruvboxFlat.colors` | `~/.local/share/color-schemes/` |
| `desktoptheme/gruvbox-flat/` | `~/.local/share/plasma/desktoptheme/` |
| `plasmoids/local.gruvbox.workspaces/` | `~/.local/share/plasma/plasmoids/` (numbered workspaces) |
| `plasmoids/local.gruvbox.windowtitle/` | `~/.local/share/plasma/plasmoids/` (active app name) |
| `plasmoids/local.tokyonight.cat/` | `~/.local/share/plasma/plasmoids/` (the running cat) |
| `applications/rofi-launcher.desktop` | `~/.local/share/applications/` (what Alt+Space runs) |
| `layout.js` | Run by `install.sh` to build the panels |

### Not included

- The wallpaper.
- GTK app colours: Plasma generates them from the colour scheme automatically.
- Icons and cursor: these are the stock Breeze Dark and Breeze.

## 6. rofi on its own

The KDE script already installs rofi's config. To use rofi without the rest of the KDE setup:

```sh
mkdir -p ~/.config/rofi/themes
cp -i rofi/config.rasi ~/.config/rofi/
cp -i rofi/themes/gruvbox-flat.rasi ~/.config/rofi/themes/
```

Then bind `rofi -show drun` to a key in System Settings → Keyboard → Shortcuts.
