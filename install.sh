#!/usr/bin/env bash
# 一键恢复本机桌面配置到新的 CachyOS / Arch KDE 环境
# 用法：
#   ./install.sh             # 只装用户配置（$HOME）
#   ./install.sh --system    # 同时安装 /etc、/usr/local/bin、/boot 等系统文件（需要 sudo）
#   ./install.sh --dry-run   # 只打印将要执行的操作
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

echo "==> 1/4 用户配置 → $HOME"
run mkdir -p "$HOME"
run cp -a "$ROOT/home/." "$HOME/"

echo "==> 2/4 软件源（archlinuxcn）"
if [ "$DRY" = 1 ]; then
  echo "[dry] 检查并向 /etc/pacman.conf 追加 [archlinuxcn]"
else
  if ! grep -q '^\[archlinuxcn\]' /etc/pacman.conf; then
    sudo cp -a /etc/pacman.conf "/etc/pacman.conf.bak-$(date +%Y%m%d-%H%M%S)"
    printf '\n[archlinuxcn]\nServer = https://repo.archlinuxcn.org/$arch\n' | sudo tee -a /etc/pacman.conf >/dev/null
    echo "    已添加 archlinuxcn 源"
  fi
  sudo pacman -Sy --needed --noconfirm archlinuxcn-keyring || true
fi

echo "==> 3/4 软件包（可手动执行，见 packages/README.md）"
echo "    sudo pacman -S --needed - < $ROOT/packages/pkglist-explicit.txt"
echo "    yay  -S --needed - < $ROOT/packages/pkglist-aur.txt"

if [ "$WITH_SYSTEM" = 1 ]; then
  echo "==> 4/4 系统文件"
  run sudo cp -a "$ROOT/system/etc/." /etc/
  run sudo install -Dm755 "$ROOT/system/usr/local/bin/"* /usr/local/bin/
  run sudo install -Dm644 "$ROOT/system/usr/lib/systemd/system/three-finger-drag.service" \
      /usr/lib/systemd/system/three-finger-drag.service
  run sudo cp -a "$ROOT/system/boot/limine.conf" /boot/limine.conf
  run sudo cp -a "$ROOT/system/boot/limine-splash.png" /boot/limine-splash.png

  echo "    - 键盘灯光服务"
  run sudo systemctl daemon-reload
  run sudo systemctl enable --now laptop-lights.timer
  run sudo systemctl enable --now laptop-lights-save.service || true

  echo "    - 三指拖拽代理 + 看门狗"
  echo "      使用本仓库 vendored 的 linux-3-finger-drag（上游 ae22def + 三指质心补丁）"
  if [ "$DRY" = 1 ]; then
    echo "[dry] $ROOT/scripts/build-3fd.sh --install"
  elif command -v cargo >/dev/null 2>&1; then
    run "$ROOT/scripts/build-3fd.sh" --install
  else
    echo "      未找到 cargo，跳过构建；安装 Rust 后执行：$ROOT/scripts/build-3fd.sh --install"
  fi
  run sudo systemctl enable --now three-finger-drag.service
  run sudo systemctl enable --now three-finger-drag-watchdog.timer

  echo "    - 更新 limine"
  run sudo limine-update || true
fi

echo
echo "==> 完成。注销并重新登录生效；KDE 也可用："
echo "    kquitapp6 plasmashell && kstart plasmashell"
