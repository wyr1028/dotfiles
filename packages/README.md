# 软件包

- `pkglist-explicit.txt`：`pacman -Qqe` 显式安装的包（含官方仓库）
- `pkglist-aur.txt`：`pacman -Qqm` 来自 AUR / archlinuxcn / 第三方源的包

恢复：
```bash
sudo pacman -S --needed - < pkglist-explicit.txt
yay  -S --needed - < pkglist-aur.txt
```

需要先启用 archlinuxcn 源（`/etc/pacman.conf`）：
```
[archlinuxcn]
Server = https://repo.archlinuxcn.org/$arch
```
