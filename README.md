# dotfiles — CachyOS + KDE Plasma (Tokyo Night) 桌面配置

本仓库是这台笔记本（机械革命 / ite8291r3 键盘背光）完整桌面环境的配置快照：
KDE Plasma + Wayland、Tokyo Night 主题、fcitx5 中文输入法、fish + fastfetch、
键鼠/触控板手势、键盘 RGB 灯控、limine 引导美化、snapper 快照、软件包清单。

> 所有内容均来自本机实际文件。**不含**任何硬件 ID、UUID、密码、密钥或令牌（见文末「已剔除」）。

## 目录结构

```
home/            → 直接覆盖到 $HOME（含隐藏文件）
  .bashrc .zshrc .gitconfig .npmrc
  .config/
    fish/                 fish 配置（cachyos 预设 + eza 别名 + fcitx5 环境变量 + starship）
    kitty/kitty.conf      Kitty：单窗口模式（禁用标签页）、Tokyo Night、字号 14、Ctrl+Alt+T
    starship.toml
    alacritty/            Alacritty（Tokyo Night）
    konsolerc + .local/share/konsole/TokyoNight.*   Konsole 配色/配置
    btop/                 系统监视器主题
    fastfetch/config.jsonc
    micro/                micro 编辑器设置 + catppuccin 配色
    fcitx5/               输入法（pinyin、经典界面、主题）+ .local/share/fcitx5/themes
    environment.d/im.conf Wayland 下输入法环境变量
    gtk-3.0/ gtk-4.0/     GTK 主题（Tokyo Night）+ gtk.css
    Kvantum/              Kvantum 主题设置
    xsettingsd/
    Code/User/settings.json            VSCodium 设置
    Code - OSS/User/settings.json      VS Code 设置
    kdeglobals kwinrc kcminputrc kglobalshortcutsrc plasma-org.kde....
    dolphinrc katerc kate/ kioslaverc mimeapps.list user-dirs.* ...
    kdeconnect/config     仅配置，不含证书/私钥
    autostart/            Clash Verge、fcitx5
    kdedefaults/ KDE/ session/ systemd/ dconf/ fcitx/ ibus/
  .local/share/
    plasma/desktoptheme/TokyoNight        Plasma 桌面主题
    plasma/plasmoids/org.kde.plasma.kickoff.nofavorites   自定义启动器（去掉收藏页）
    color-schemes/TokyoNight.colors
    applications/*.desktop                桌面快捷方式
    clash-verge/config.yaml               已脱敏的 mihomo 配置
    fcitx5/themes/  user-places.xbel
  Pictures/Wallpapers/tokyonight.png
system/          → 镜像根分区（需 --system）
  etc/default/limine            limine 配置（字体放大等）
  boot/limine.conf              已脱敏的引导项（machine-id / UUID 已替换）
  etc/limine-entry-tool.conf
  etc/systemd/system/laptop-lights*.{service,timer}
  usr/local/bin/laptop-lights   键盘背光/灯光总控脚本（按时间自动亮度）
  usr/local/bin/kb-white kb-calibrate ite8291r3-ctl
  etc/laptop-lights.conf        RGB 颜色校准参数（当前纯白：120,255,120）
  etc/modprobe.d/blacklist-ite8291.conf
  etc/linux-3-finger-drag/3fd-config.json   三指拖拽参数（acceleration 0.75）
  usr/lib/systemd/system/three-finger-drag.service   自建 system 单元（DynamicUser + input 组）
  etc/systemd/system/three-finger-drag.service.d/override.conf   Restart=always，防止代理挂掉后触控板无事件源
  etc/systemd/system/three-finger-drag-watchdog.{service,timer}  每 3 秒体检并自动重启
  usr/local/bin/three-finger-drag-watchdog      看门狗（检测 grab 丢失 / D 状态卡死 / 虚拟设备消失）
  usr/local/bin/touchpad-fix                    手动一键重启触控板代理
  etc/polkit-1/rules.d/49-touchpad-fix.rules    免密重启 three-finger-drag.service
  etc/pacman.conf                   全量配置（含 archlinuxcn 源）
  boot/limine-splash.png            引导背景图（limine.conf 的 wallpaper 引用）
  etc/snapper/configs/root      快照配置（定时快照 + 自动清理）
  etc/vconsole.conf etc/locale.conf
packages/        软件包清单（显式安装 + AUR / archlinuxcn）
third_party/linux-3-finger-drag/   触控板代理源码（上游 ae22def + 三指质心补丁）
scripts/         构建脚本（build-3fd.sh）
install.sh       恢复脚本
```

## 恢复

```bash
git clone https://github.com/wyr1028/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh --dry-run     # 先看要做什么
./install.sh               # 用户配置
./install.sh --system      # 系统文件（/etc、/usr/local/bin、limine）
```

软件包：

```bash
sudo pacman -S --needed - < packages/pkglist-explicit.txt
yay  -S --needed - < packages/pkglist-aur.txt
```

## 这套配置包含的主要改动

| 部分 | 说明 |
|---|---|
| 主题 | KDE 全局主题 Tokyo Night + 自编译桌面主题 / 配色方案 / Kvantum / GTK3/4 |
| 启动器 | 复制 kickoff 为 `org.kde.plasma.kickoff.nofavorites`，隐藏「收藏」页 |
| 字体 | Noto Sans CJK 全局；limine 引导字体放大；Markdown 预览字号 16/18 |
| 输入法 | fcitx5 + pinyin + 中文词库；Wayland 走 text-input 协议，X11 走 XIM |
| 终端 | Kitty 为主终端（单窗口无标签、Ctrl+Alt+T、Ctrl+Shift+Enter 新窗口）；Konsole(Tokyo Night) / Alacritty 备用；fish + starship + eza |
| 系统信息 | 自定义 fastfetch（左图标小、左右 padding、无最后一行分割线） |
| 键盘灯光 | `ite8291r3` 经 usb 直写；`laptop-lights` 按时间自动亮度（白天 100 / 夜间 45），其余灯全关、仅键盘常亮白色；行间偏色补偿（TOP_SHIFT/BOTTOM_SHIFT） |
| 触控板 | `linux-3-finger-drag` 代理独占抓取触控板转发虚拟设备；拖移跟随**三指质心**而非单根参考手指，单指抖动被平均；acceleration 0.75、dragEndDelay 0；systemd DynamicUser 单元 + override `Restart=always`；watchdog 定时器每 3s 自愈；`Ctrl+Alt+Shift+T` 热键重启代理（polkit 免密） |
| 引导 | limine + CachyOS 主题、term_palette、字体缩放 3x3 |
| 快照 | snapper root 配置：定时快照 + 自动清理，与 limine 快照启动项联动 |
| 软件 | archlinuxcn 源、yay、WeChat、Steam、VS Code/OSS、WPS、Clash Verge、Bilibili、网易云 |

## 已剔除（不会上传）

- `.ssh/`、`.gnupg/`、`kdeconnect/privateKey.pem`、`certificate.pem`
- `.pi/agent/auth.json`（API 密钥）、`gh` 的 token（存在系统 keyring，未落盘）
- 浏览器/应用数据：`mozilla/`、`bilibili/`、`Code - OSS` 的用户数据与缓存、`wechat-universal`、`Kingsoft` 账户信息
- `clash-verge` 订阅链接与 `secret`（`config.yaml` 中已替换为 `<redacted>`）
- 硬件标识：limine 中的 `machine-id` / `UUID` / 校验和，`kwinoutputconfig.json` 的 EDID hash 与显示器 UUID
- 各类缓存、日志、回收站、Steam 游戏数据、Pi 会话记录（含截图与对话）

## 备注

- `install.sh` 不会自动覆盖 `$HOME` 中同名文件之间的合并逻辑，建议先备份。
- 系统文件里的 `laptop-lights` 依赖 `ite8291r3-ctl`（AUR: `ite8291r3-ctl-git` 或本仓库 `usr/local/bin/ite8291r3-ctl` 包装脚本）。
- limine 配置为参考用：新机器请用 `limine-entry-tool` 重新生成，再套用 `term_*` 与 `term_font_scale` 等美化项。
- `/usr/bin/linux-3-finger-drag` 的源码已 vendored 到 `third_party/linux-3-finger-drag/`（上游 `ae22def`，附加三指质心修改，见其中的 `DOTFILES.md` 与 `centroid.patch`）。`install.sh --system` 在检测到 `cargo` 时会自动构建安装；也可手动运行 `scripts/build-3fd.sh --install`。
- `/usr/share` 下没有手改文件：中文翻译、breeze-dark、fcitx5 词库（zhwiki / moegirl / web-slang）都来自仓库包（`fcitx5-pinyin-zhwiki` 等），已包含在软件包清单里。
- 键盘 RGB 由 `ite_8291_lb` 内核模块 + `laptop-lights` 控制，其余灯光（logo/灯条）全部关闭。
- 键盘白色校准值来自实机调试，换机器需重新用 `kb-calibrate` 标定。
