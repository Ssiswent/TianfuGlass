# TianfuGlass · 天府通 Liquid Glass

iOS 26+ SwiftUI / App Intents 工程。当前诊断版本 **v0.5.0 (6)**。

## 诊断结论

由用户 iOS 27 真机确认：

- App 内 SwiftUI 文字 Sheet、二维码 Sheet：**PASS**。
- 从快捷指令列表运行「Glass 诊断 A · 纯文字」和「Glass 诊断 C · 直接返回文字」：**PASS**。
- 旧版「Glass 诊断 B · 测试二维码」：只出现系统顶部 Done，**FAIL**。

所以优先排查 **参数化 SnippetIntent 与二维码视图渲染**。不能把 Done-only 归因于接口、Cookie 或二维码生成失败（后两者在 App Sheet 中已可用）。Apple 官方说明，Snippet 由系统呈现，且 `SnippetIntent` 可能多次执行；应快速返回轻量内容，参数传递应保持最小且不可变。

## v0.5.0 改动

1. **B 的二维码不再使用 `Image(decorative: CGImage)`**，新建 QR 位图矩阵（在 SnippetIntent `perform()` 中生成），通过纯 SwiftUI `Shape` 的 Path 绘制黑色模块，保留 4 个模块的白色 quiet zone。无需在 `View.body` 中运行 `CIContext`。
2. 原「显示天府通乘车码 V3」也复用新的矢量二维码视图，但仍需真机验证。
3. 增加 **「Glass 诊断 D · 参数化文字」**：和 B 一样通过 `SnippetIntent` 传递一个 `@Parameter String`，视图只含文字。

## 下一轮只需要运行 D 和 B

安装新版本后，从「快捷指令」App 的**快捷指令列表**运行两个只有一个动作的新快捷指令，分别为：

- **D · 参数化文字**：预期显示标题及固定字符串 `GLASS-PARAMETER-TRANSFER-OK`。
- **B · 测试二维码**：预期在系统顶部 Snippet 显示黑白二维码与「离线演示 · 不可乘车」。

按结果判断：

| D | B | 代表什么 |
|---|---|---|
| PASS | PASS | 参数链和矢量二维码可以显示；下一步测试真实 code |
| PASS | 仅 Done | 参数链可用，重点检查二维码的 SwiftUI Shape、尺寸、绘制或系统限制 |
| 仅 Done | 仅 Done | 优先检查参数化 SnippetIntent 的恢复/传参，而非二维码 |
| 仅 Done | PASS | 两个 SnippetIntent 结构存在其他差异，需要重新审查 |

不要从 App 内的 `Button(intent:)` 结果推断快捷指令 Snippet 行为。控制中心 Control 调用也不支持展示 Snippet。

## 构建

[GitHub Actions · Build unsigned IPA (Xcode 27)](https://github.com/Ssiswent/TianfuGlass/actions/workflows/build-unsigned-ipa.yml)

Artifacts: `TianfuGlass-v0.5.0-unsigned-IPA`。未签名 IPA 需要自行签名后才能在普通 iPhone 上安装。

项目没有上传真实 Cookie、Token、乘车码或天府通 API，测试二维码不可用于乘车。

源码：`Sources/TianfuGlassApp.swift`、`Sources/QRCodeVectorSnippetView.swift`、`Sources/ShowTransitCodeIntent.swift`。
