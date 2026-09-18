if status is-interactive
    # Commands to run in interactive sessions can go here
    fastfetch
end

# Flatpak additions
if status is-login; or status is-interactive
    set -gx XDG_DATA_DIRS (string join : $XDG_DATA_DIRS /var/lib/flatpak/exports/share /home/drv0/.local/share/flatpak/exports/share)
end


# --- Useful Aliases ---
# Navigation & Listing
alias ll "eza -la --icons --group-directories-first $argv"
alias l "ls -l"
alias la "ls -A"
alias .. "cd .."
alias ... "cd ../.."

# Convenience & Safety
alias cp "cp -i"
alias mv "mv -i"
alias rm "interactive --trash" # Or just rm -i if you prefer prompt warnings
alias df "df -h"
alias free "free -h"

# Git shortcuts (if you use git)
alias g "git"
alias gs "git status"
alias ga "git add"
alias gc "git commit -m"
alias gp "git push"
alias gl "git log --oneline --graph --decorate"

# Update shortcut
alias update-all="echo '== Packman update =='; and sudo pacman -Syu; echo '== Flatpak update =='; and flatpak update -y"

set fish_greeting
