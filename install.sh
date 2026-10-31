#!/usr/bin/env bash
# 一键恢复本机桌面配置到新的 CachyOS / Arch KDE 环境
# 用法：
#   ./install.sh            # 只装用户配置（$HOME）
#   ./install.sh --system   # 同时安装 /etc、/usr/local/bin 等系统文件（需要 sudo）
#   ./install.sh --dry-run  # 只打印将要执行的操作
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WITH_SYSTEM=0
DRY=0
for a in "$@"; do
  case "$a" in
    --system) WITH_SYSTEM=1 ;;
    --dry-run) DRY=1 ;;
    -h|--help) sed -n '2,8p' "$0"; exit 0 ;;
    *) echo "未知参数: $a" >&2; exit 1 ;;
  esac
done

run() { if [ "$DRY" = 1 ]; then echo "[dry] $*"; else "$@"; fi; }

echo "==> 安装用户配置到 $HOME"
run mkdir -p "$HOME"
# -a 保留权限/时间；用 /. 保证隐藏文件也被复制
run cp -a "$ROOT/home/." "$HOME/"

echo "==> 安装软件包（可选，按需取消注释）"
echo "    sudo pacman -S --needed - < $ROOT/packages/pkglist-explicit.txt"
echo "    yay -S --needed - < $ROOT/packages/pkglist-aur.txt"

if [ "$WITH_SYSTEM" = 1 ]; then
  echo "==> 安装系统文件到 /"
  run sudo cp -a "$ROOT/system/etc/." /etc/
  run sudo install -Dm755 "$ROOT/system/usr/local/bin/"* /usr/local/bin/
  run sudo cp -a "$ROOT/system/boot/limine.conf" /boot/limine.conf

  echo "==> 启用服务"
  run sudo systemctl enable --now laptop-lights.timer
  run sudo systemctl enable --now laptop-lights-save.service || true
  run sudo modprobe -r ite_8291 2>/dev/null || true

  echo "==> 更新 limine 启动项"
  run sudo limine-update || true
fi

echo "==> 完成。注销并重新登录（KDE 需重启 plasmashell/kwin）生效："
echo "    kquitapp6 plasmashell && kstart plasmashell"
echo "    kwin_x11 --replace 或 systemctl --user restart plasma-kwin_wayland.service"
