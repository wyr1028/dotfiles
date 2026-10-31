source /usr/share/cachyos-fish-config/cachyos-config.fish

# Add npm global bin (pi coding agent)
fish_add_path ~/.npm-global/bin

# overwrite greeting
# potentially disabling fastfetch
#function fish_greeting
#    # smth smth
#end

# --- fcitx5 input method (for Chinese input in English UI) ---
set -gx GTK_IM_MODULE fcitx
set -gx QT_IM_MODULE fcitx
set -gx XMODIFIERS @im=fcitx
set -gx INPUT_METHOD fcitx
set -gx SDL_IM_MODULE fcitx
starship init fish | source

# --- eza aliases (Tokyo Night styled ls) ---
alias ls='eza --icons --group-directories-first'
alias ll='eza -l --icons --group-directories-first --git'
alias la='eza -la --icons --group-directories-first --git'
alias lt='eza --tree --level=2 --icons'
