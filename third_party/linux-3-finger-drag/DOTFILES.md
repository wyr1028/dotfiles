# linux-3-finger-drag（本仓库修改版）

- 上游：<https://github.com/lmr97/linux-3-finger-drag>
- 固定上游提交：`ae22defe47156e13476f08dce6cd98e5aaa49227`（v2.0.0）
- 许可：MIT，见 [LICENSE](LICENSE)

## 本地改动

上游的拖移只跟随一根“参考手指”（`drag_ref_slot`）的位移；本仓库改为跟随
**当前所有按下手指的质心**：

- 三指整体移动时位移与原来一致，速度不会变成三倍
- 单指抖动对光标的影响降到约 1/3，另外两指起到平均作用
- 手指抬起/落下时只重建基准，不产生光标跳变
- 拖移中途抬起一根手指，剩下手指的质心平滑接管

具体实现在 `src/runtime/gesture.rs` 的 `drive_drag()` / `centroid()`，
回归测试在 `src/runtime/gesture/tests.rs`。完整差异也可用
`centroid.patch` 应用到上游 `ae22def` 复现：

```bash
git clone https://github.com/lmr97/linux-3-finger-drag
cd linux-3-finger-drag
git checkout ae22defe47156e13476f08dce6cd98e5aaa49227
git apply /path/to/dotfiles/third_party/linux-3-finger-drag/centroid.patch
```

## 构建安装

```bash
./scripts/build-3fd.sh            # 只构建
./scripts/build-3fd.sh --install  # 构建并安装到 /usr/bin，必要时重启服务
```

`install.sh --system` 也会在检测到 `cargo` 时自动构建并安装本目录的版本。

> 这是 vendored 的第三方源码；`target/` 已被其 `.gitignore` 忽略，不要提交。
