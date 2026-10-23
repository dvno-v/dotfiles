#!/usr/bin/env bash
# Installs the Gruvbox Flat KDE Plasma 6 setup. Run from a terminal inside the Plasma session.
set -euo pipefail

kde_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
repo_dir=$(dirname -- "$kde_dir")
config_root="${XDG_CONFIG_HOME:-$HOME/.config}"
data_root="${XDG_DATA_HOME:-$HOME/.local/share}"

for program in qdbus6 kreadconfig6 kwriteconfig6 plasma-apply-colorscheme plasma-apply-desktoptheme busctl rofi; do
    command -v "$program" >/dev/null || { printf 'Missing dependency: %s\n' "$program" >&2; exit 1; }
done
if [[ -z $(fc-list 'JetBrainsMono Nerd Font' family) ]]; then
    printf '%s\n' 'Warning: JetBrainsMono Nerd Font is not installed; the clock and rofi will fall back to another font.' >&2
fi
if ! qdbus6 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript 'print("ok")' >/dev/null 2>&1; then
    printf '%s\n' 'Run this from a terminal inside your logged-in KDE Plasma session.' >&2
    exit 1
fi

# Back up everything this script replaces.
backup_dir="$HOME/kde-theme-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$backup_dir"
for file in kdeglobals plasmarc plasmashellrc plasma-org.kde.plasma.desktop-appletsrc kwinrc kglobalshortcutsrc; do
    [[ -f "$config_root/$file" ]] && cp -p -- "$config_root/$file" "$backup_dir/"
done
[[ -d "$config_root/rofi" ]] && cp -a -- "$config_root/rofi" "$backup_dir/rofi"
printf 'Backup: %s\n' "$backup_dir"

# Files.
install -Dm644 "$kde_dir/color-schemes/GruvboxFlat.colors" "$data_root/color-schemes/GruvboxFlat.colors"
mkdir -p "$data_root/plasma/desktoptheme" "$data_root/plasma/plasmoids"
cp -rT -- "$kde_dir/desktoptheme/gruvbox-flat" "$data_root/plasma/desktoptheme/gruvbox-flat"
for plasmoid in "$kde_dir"/plasmoids/*/; do
    name=$(basename -- "$plasmoid")
    cp -rT -- "$plasmoid" "$data_root/plasma/plasmoids/$name"
done
install -Dm644 "$kde_dir/applications/rofi-launcher.desktop" "$data_root/applications/rofi-launcher.desktop"
install -Dm644 "$repo_dir/rofi/config.rasi" "$config_root/rofi/config.rasi"
install -Dm644 "$repo_dir/rofi/themes/gruvbox-flat.rasi" "$config_root/rofi/themes/gruvbox-flat.rasi"
command -v kbuildsycoca6 >/dev/null && kbuildsycoca6 >/dev/null 2>&1 || true

# Colours and Plasma style. Clearing the scheme first forces a re-read after edits.
kwriteconfig6 --file kdeglobals --group General --key ColorScheme ''
plasma-apply-colorscheme GruvboxFlat
plasma-apply-desktoptheme gruvbox-flat
kwriteconfig6 --file kwinrc --group Plugins --key blurEnabled true
qdbus6 org.kde.KWin /KWin org.kde.KWin.reconfigure

# Panels.
qdbus6 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "$(<"$kde_dir/layout.js")"

# Shortcuts: KRunner keeps Alt+F2 and Search, rofi takes Alt+Space.
# Key codes are Qt key + modifier ints; flags 6 = SetPresent|NoAutoloading (otherwise it stays inactive).
accel=(busctl --user call org.kde.kglobalaccel /kglobalaccel org.kde.KGlobalAccel)
"${accel[@]}" setForeignShortcut asai 4 org.kde.krunner.desktop _launch "" "" 2 150994993 16777362 >/dev/null
"${accel[@]}" doRegister as 4 rofi-launcher.desktop _launch "Rofi Launcher" "Launch Rofi" >/dev/null
"${accel[@]}" setShortcut asaiu 4 rofi-launcher.desktop _launch "Rofi Launcher" "Launch Rofi" 1 134217760 6 >/dev/null

printf '%s\n' 'Done. Alt+Space opens rofi. To undo, copy the backup files back into ~/.config and log out and in.'
