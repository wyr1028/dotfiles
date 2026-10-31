#!/usr/bin/env bash
# 构建本仓库 vendored 的 linux-3-finger-drag（上游 ae22def + 三指质心补丁）
# 用法：
#   ./scripts/build-3fd.sh             # 只构建
#   ./scripts/build-3fd.sh --install   # 构建并安装到 /usr/bin，必要时重启服务
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC="$ROOT/third_party/linux-3-finger-drag"
INSTALL=0

for a in "$@"; do
  case "$a" in
    --install) INSTALL=1 ;;
    -h|--help) sed -n '2,7p' "$0"; exit 0 ;;
    *) echo "未知参数: $a" >&2; exit 1 ;;
  esac
done

command -v cargo >/dev/null 2>&1 || {
  echo "错误：未找到 cargo。请先安装 Rust 工具链（rustup 或 pacman -S rust）。" >&2
  exit 1
}

echo "==> 构建 $SRC"
(cd "$SRC" && cargo build --release --locked)

if [ "$INSTALL" = 1 ]; then
  sudo install -Dm755 "$SRC/target/release/linux-3-finger-drag" /usr/bin/linux-3-finger-drag
  echo "==> 已安装 /usr/bin/linux-3-finger-drag"

  if systemctl is-enabled --quiet three-finger-drag.service 2>/dev/null \
     || systemctl is-active --quiet three-finger-drag.service 2>/dev/null; then
    sudo systemctl restart three-finger-drag.service
    echo "==> 已重启 three-finger-drag.service"
  fi
fi
