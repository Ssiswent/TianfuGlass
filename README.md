# TianfuGlass · 天府通 Liquid Glass

iOS 26+ SwiftUI / App Intents 工程。当前诊断版本 **v0.5.2 (8)**。

## 诊断结论

由用户 iOS 27 真机确认：

- App 内 SwiftUI 文字 Sheet、二维码 Sheet：**PASS**。
- 从快捷指令列表运行「Glass 诊断 A · 纯文字」和「Glass 诊断 C · 直接返回文字」：**PASS**。
- 旧版「Glass 诊断 B · 测试二维码」仅出现 Done；用户已确认 **v0.5.0 中 D、B 均 PASS**，矢量二维码可正常显示，但两者的内容出现从右下角移入居中的动画。

**v0.5.2 决策：保留系统原生 Snippet 入场动画。** 用户在 v0.5.1 真机录屏确认，禁用 SwiftUI 内容动画后系统转场仍存在；该入场动画由 iOS 管理，不需要在 App 内进一步规避。现已撤回此前为动画实验加入的固定 292pt 宽度、`.contentTransition(.identity)` 和 `.transaction` 禁用动画操作；保留 v0.5.0 已真机通过的矢量二维码与参数化 Snippet 行为。v0.5.2 仍需签名安装后复验。Apple 官方说明，Snippet 由系统呈现，且 `SnippetIntent` 可能多次执行；应快速返回轻量内容，参数传递应保持最小且不可变。

## v0.5.0 二维码渲染改动（已真机验证）

1. **B 的二维码不再使用 `Image(decorative: CGImage)`**，新建 QR 位图矩阵（在 SnippetIntent `perform()` 中生成），通过纯 SwiftUI `Shape` 的 Path 绘制黑色模块，保留 4 个模块的白色 quiet zone。无需在 `View.body` 中运行 `CIContext`。
2. 原「显示天府通乘车码 V3」也复用新的矢量二维码视图，但仍需真机验证。
3. 增加 **「Glass 诊断 D · 参数化文字」**：和 B 一样通过 `SnippetIntent` 传递一个 `@Parameter String`，视图只含文字。

## v0.5.2 验证及后续工作

安装后只需从「快捷指令」列表运行 D（参数化文字）与 B（测试二维码），确认仍能显示完整内容；系统原生的入场动画属于预期行为，不再作为失败项。无需改变「减弱动态效果」设置。

待确认后再接入真实的 `result.code`（传入 App Intent 的字符串），不要在仓库中加入 Cookie 或账号令牌。二维码原始值可能是短期有效凭证；不要把它写入诊断日志。

## 构建

[GitHub Actions · Build unsigned IPA (Xcode 27)](https://github.com/Ssiswent/TianfuGlass/actions/workflows/build-unsigned-ipa.yml)

GitHub [Releases](https://github.com/Ssiswent/TianfuGlass/releases) 自动发布 `TianfuGlass-v0.5.2-build8-unsigned.ipa` 等预发布测试版；Actions Artifact 保留备份。未签名 IPA 需要自行签名后才能在普通 iPhone 上安装。

项目没有上传真实 Cookie、Token、乘车码或天府通 API，测试二维码不可用于乘车。

源码：`Sources/TianfuGlassApp.swift`、`Sources/QRCodeVectorSnippetView.swift`、`Sources/ShowTransitCodeIntent.swift`。
