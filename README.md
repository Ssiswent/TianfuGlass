# TianfuGlass · 天府通 Liquid Glass

轻量 iOS 26+ SwiftUI / App Intents 工程。当前诊断版本 **v0.4.0 (5)**。

## 问题与范围

设备通过快捷指令触发 App Intent 后，只看见系统顶部 `Done`，未看到自定义 Snippet。本版本重点是把 SwiftUI 图片渲染与 App Intent 的系统呈现机制分开测试，**并未宣称修复了 Done-only 问题**。

没有包含真实天府通 Cookie、Token、二维码或联网接口。二维码仅使用明确标记为测试的固定数据。

## 请在 iPhone 上按顺序测试

安装新版、打开「天府通 Glass」，主页有五个按钮：

1. **测试 1 · 打开文字弹窗**：App 自身的 SwiftUI `.sheet`，应看见“SwiftUI 文字弹窗测试成功”和关闭按钮。
2. **测试 2 · 打开二维码弹窗**：App 自身的 `.sheet`，显示离线测试二维码和关闭按钮。
3. **测试 3 · SnippetIntent 文字**：在 App 中运行之前的 A 诊断 Intent。由系统决定是否呈现。
4. **测试 4 · SnippetIntent 二维码**：在 App 中运行之前的 B 诊断 Intent。
5. **测试 5 · 直接返回视图**：在 App 中运行新增的 C Intent（不再经由独立 SnippetIntent）。

然后从「快捷指令」列表运行两个**各自只有一个动作**的新快捷指令：
- `Glass 诊断 A · 纯文字`：旧的 SnippetIntent 路径。
- `Glass 诊断 C · 直接返回文字`：新增的静态视图返回路径。

如果测试 1/2 成功，而 A/C 在快捷指令中都仍只出现 Done，问题范围会收敛到系统对 Snippet 的呈现或 App Intents 调用环境，**不是 QRCodeRenderer / API / Cookie 的问题**。如果 A 失败但 C 成功，优先审查 SnippetIntent 链式返回与参数生命周期。单独从 App 内的 Button(intent:) 触发，不保证系统展示 Snippet，需与快捷指令的测试结果一起判断。

**若从控制中心“控件 Control”调用 App Intent，Apple 官方明确说明该调用不支持显示 snippets。** 请从「快捷指令」App 列表运行诊断。

## 获取 IPA

打开 [Actions → Build unsigned IPA (Xcode 27)](https://github.com/Ssiswent/TianfuGlass/actions/workflows/build-unsigned-ipa.yml)，在成功的运行中下载 `TianfuGlass-v0.4.0-unsigned-IPA`，解压得到 `TianfuGlass-v0.4.0-unsigned.ipa`。

未签名 IPA 在普通 iPhone 上安装前需要合法的签名流程。测试版不用账号凭证。

## 技术结构

- `Sources/TianfuGlassApp.swift`: SwiftUI 主界面、两种 App 内 sheet 诊断、三个 Intent 按钮、共享二维码视图。
- `Sources/ShowTransitCodeIntent.swift`: 原 A/B、V3 意图，以及新增直接静态视图的 C 诊断。
- `project.yml`: XcodeGen 生成 iOS 项目。
- `.github/workflows/build-unsigned-ipa.yml`: GitHub Actions Xcode 27 Release 编译、未签名 IPA 打包与上传。

系统决定 Snippet 弹出位置、大小和 Done 按钮，不能由 SwiftUI 修改为自由居中的模态弹窗。
