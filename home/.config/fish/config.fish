source /usr/share/cachyos-fish-config/cachyos-config.fish

# Add npm global bin (pi coding agent)
fish_add_path ~/.npm-global/bin

# overwrite greeting
# potentially disabling fastfetch
#function fish_greeting
#    # smth smth
#end

# --- fcitx5 input method ---
# Wayland 下不要再设 GTK_IM_MODULE / QT_IM_MODULE=fcitx：
# 否则 GTK 应用（如 Firefox）会走 fcitx 的 D-Bus 前端，候选框退回 XWayland
# 绘制并显示成默认白色主题。让 GTK/Qt 使用原生 text-input 协议即可。
set -gx XMODIFIERS @im=fcitx
set -gx QT_IM_MODULES 'wayland;fcitx'
starship init fish | source

# --- eza aliases (Tokyo Night styled ls) ---
alias ls='eza --icons --group-directories-first'
alias ll='eza -l --icons --group-directories-first --git'
alias la='eza -la --icons --group-directories-first --git'
alias lt='eza --tree --level=2 --icons'
