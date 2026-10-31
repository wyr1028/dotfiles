# 最近桌面设置变更 / Pi 会话记录

本文汇总 **2026-10-31 ~ 2026-11-01** 期间，Pi 会话里与桌面环境有关的改动、结论和排障过程。
内容为整理后的摘要，不是原始对话记录；不包含密码、密钥、令牌等敏感信息。

环境：CachyOS + KDE Plasma 6（Wayland）+ Tokyo Night 主题 + fcitx5。

---

## 1. 输入法候选框在 Firefox 里变成白色（已修复）

### 现象

- Konsole / Kate 等程序里，fcitx5 候选框是深色 Plasma 主题，正常。
- Firefox（以及某些 GTK 程序）里，候选框变成 **白色 / fcitx 默认主题**。
- 输入本身能用，只是候选框样式不对。

### 根因

fish 配置里长期导出了：

```fish
set -gx GTK_IM_MODULE fcitx
set -gx QT_IM_MODULE fcitx
set -gx SDL_IM_MODULE fcitx
```

这些变量通过 `systemctl --user` 的会话环境被 KDE 启动的 GUI 程序继承（当时 systemd 用户环境里还能看到
`STARSHIP_SHELL=fish` 等 fish 变量，可确认是从 fish 导入的）。

于是 Firefox 走的是 fcitx 的 **D-Bus 前端**。而 fcitx5 的经典界面在
“Wayland display + 非 Wayland 前端（dbus/GTK）”这种情况下，会退回 **XWayland 的 X11 候选窗**
绘制（见 fcitx5 `classicui.cpp` 的 `uiForInputContext()` 逻辑），最终显示成默认白色主题。

Konsole 走的是原生 Wayland `text-input` 协议，所以候选框仍然是深色 Plasma 主题。

### 修复

1. `~/.config/fish/config.fish` 不再导出 toolkit 输入法模块，只保留：

   ```fish
   set -gx XMODIFIERS @im=fcitx
   set -gx QT_IM_MODULES 'wayland;fcitx'
   ```

2. 清理当前 systemd 用户会话里的旧变量：

   ```bash
   systemctl --user unset-environment GTK_IM_MODULE QT_IM_MODULE SDL_IM_MODULE INPUT_METHOD
   ```

3. `~/.config/environment.d/im.conf` 保持为“Wayland 使用原生 text-input”的配置：

   ```ini
   XMODIFIERS=@im=fcitx
   QT_IM_MODULES=wayland;fcitx
   ```

### 验证

- 从任务栏/开始菜单重新打开 Firefox 后，候选框恢复为深色 Plasma 主题。
- 实测：Firefox 在 `GTK_IM_MODULE` 未设置时，输入上下文变为 `frontend:wayland`，
  候选框由 Wayland 侧绘制，样式正常。
- 修改后新开的 fish 终端不再带 `GTK_IM_MODULE`；旧终端需要重开。

### 相关文件

- `home/.config/fish/config.fish`
- `home/.config/environment.d/im.conf`

> 备注：KDE 这边输入法由 KWin 以 `fcitx5-wayland-launcher` 启动（`kwinrc [Wayland] InputMethod=...`），
> Wayland 下应让 GTK/Qt 使用原生 text-input，而不是强制 `*=fcitx`。

---

## 2. 开始菜单 Cachy 图标替换

- 需求：左下角开始菜单的 CachyOS 图标不好看，换成自定义图标。
- 结果：使用自绘的 “C” 渐变圆环图标，并加粗描边。
- 当前 Kickoff 配置：`icon=launcher-c-42`。
- 图标位置：

  ```
  ~/.local/share/icons/hicolor/scalable/apps/launcher-c-42.svg
  ```

图标是青绿到蓝色的渐变圆弧（`#7cf5dd` → `#1a8fd1`），已纳入本仓库。

---

## 3. 启动器去掉 Favorites 页

- 自定义 Kickoff plasmoid：`org.kde.plasma.kickoff.nofavorites`
- 保留“所有应用 / 分类”，去掉收藏页。
- 文件：`home/.local/share/plasma/plasmoids/org.kde.plasma.kickoff.nofavorites/`

---

## 4. Kitty 终端设置

- 单窗口模式：禁用标签页（`tab_bar_min_tabs 999` 等）。
- `Ctrl+Alt+T` 打开 Kitty，其他默认用 Konsole 打开的文件类型也尽量改到 Kitty。
- Tokyo Night 配色、字号 14。
- 关闭窗口时不再提示“仍有程序在运行”：

  ```conf
  confirm_os_window_close 0
  ```

- 文件：`home/.config/kitty/kitty.conf`

---

## 5. 三指拖移 / 触控板

- 使用 `linux-3-finger-drag` 代理：独占抓取真实触控板，转发虚拟设备实现三指拖移。
- 已从“跟随单根参考手指”改为 **跟随三指质心**，单指抖动被平均，抬指不跳变。
- 源码 vendored 到 `third_party/linux-3-finger-drag/`（上游 `ae22def` + `centroid.patch`）。
- 当前参数：`acceleration = 0.75`，`dragEndDelay = 0`。
- 双击拖移 / TapDragLock 关闭（不会误触发锁定）。
- 稳定性：
  - systemd 单元 + `Restart=always` override；
  - `three-finger-drag-watchdog.timer` 每 3 秒体检并自动重启；
  - `Ctrl+Alt+Shift+T` 热键执行 `touchpad-fix`，polkit 免密重启代理。
- 构建：`scripts/build-3fd.sh --install`，或 `install.sh --system` 在检测到 cargo 时自动构建。

---

## 6. 混合显卡 / 外接屏

- 内置屏通常走核显；外接显示器 / 游戏自动走独显。
- 不需要为了“自动切独显”去改 MUX 或 `KWIN_DRM_DEVICES`。
  - **不要**设置 `KWIN_DRM_DEVICES=/dev/dri/card1`，否则 KWin 可能看不到直连独显的 HDMI/DP 口。
- Vulkan / Proton 游戏默认已走独显；OpenGL / 老游戏可在 Steam 启动项加：

  ```
  prime-run %command%
  ```

- 非 Steam 程序用 `prime-run ./game`，或在 `.desktop` 的 `Exec=` 前加 `prime-run`。
- 验证：`vulkaninfo --summary`、`nvidia-smi`；注意这些命令本身会把独显从 D3cold 唤醒。

---

## 7. Limine 与键盘灯

- Limine 字体已调大，并更换了引导背景图。
- 键盘灯状态写入控制器 NVRAM，关机前自动保存：

  - `laptop-lights-save.service`：关机/重启前执行 `laptop-lights --save`；
  - 修复 `laptop-lights.timer` 因 `RemainAfterExit=yes` 不重复触发的问题；
  - 目标效果：Limine 阶段也是“键盘灯亮、其他装饰灯灭”。

---

## 8. 其他桌面相关

- 安装网易云音乐（`netease-cloud-music-gtk-bin`）和哔哩哔哩（`bilibili-bin`）。
- WPS 界面切换为中文。
- 桌面偶发卡顿排查结论：图标渲染 + pacman 快照写盘 + 面板重绘在几秒内撞在一起，属于一次性掉帧，不是故障。

---

## 9. 说明

- 未收录与桌面无关的会话（如 CPU 降压、课程作业、WPS 公式排版等）。
- 本仓库为公开仓库：<https://github.com/wyr1028/dotfiles>
