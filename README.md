# TianfuGlass · 天府通 Glass

**v0.9.0 (Build 26)** · iOS 26+ · SwiftUI / App Intents Snippet

TianfuGlass 现在是一个**纯二维码展示工具**：由 iPhone「快捷指令」把二维码的原始文本传给 App，App 只生成并显示原生 Snippet 浮层。**不主动发起 API 请求、不登录、不读取 Cookie、不存储乘车码、不提供演示或诊断操作。**

## 使用方法

1. 在你自己的 iPhone 快捷指令中调用所需接口，取得二维码原始字符串，例如接口返回的 `result.code`。
2. 添加 TianfuGlass 的 **「显示天府通乘车码」** 操作；唯一参数 **「乘车码内容」** 指向上一步的原始字符串，勿转换成字典摘要或裁剪内容。
3. 运行快捷指令，由 iOS 显示悬浮乘车二维码。无需先打开 TianfuGlass App。

旧版 **「显示天府通乘车码 V3」** 仍保留，以兼容已经使用「有效期（秒）」参数的旧快捷指令。有效期只用于旧参数有效性检查，不会显示在 Snippet，也不会驱动网络请求。

注意：**本 App 接收的是二维码原始文本，不是二维码 PNG/JPEG 图片文件**。收到文本后在设备上生成黑白 QR 图案；保持原生 228pt 二维码、四模块 quiet zone、纯白底以及 iOS 系统管理的 Done 按钮和 Liquid Glass 效果。系统控制弹层初始高度、位置和展开动画，App 无法保证不发生高度变化。

## 范围与隐私

- 没有乘车码 API 客户端，也不使用 `URLSession` 网络取码。
- 没有 Cookie/TGT 设置页面、会话读取流程或 Keychain 凭证管理功能。
- 不在磁盘、本地日志或用户默认设置中保存输入的二维码原始文本。
- 不包含任何演示、调试、恢复或诊断用 App Intent/SwiftUI 界面。
- 保留原有正式「显示天府通乘车码」与 V3 的动作标识，尽量避免破坏既有快捷指令。
- 从旧版本覆盖安装后，**旧版本曾写入系统 Keychain 的凭证可能仍保留在设备中**。新版本不会读取、使用或发送这些旧条目；删除相关源码本身不等于清除系统 Keychain 历史数据。
- 本仓库是 **Public**；绝对不要提交真实 Cookie、Token 或有效的动态乘车码。

## 构建

[GitHub Actions](https://github.com/Ssiswent/TianfuGlass/actions/workflows/build-unsigned-ipa.yml) 使用 Xcode 27 编译，并自动在 [GitHub Releases](https://github.com/Ssiswent/TianfuGlass/releases) 发布未签名 IPA 与 SHA-256。普通 iPhone 安装前需要签名。

以前的成功扫码反馈只针对既有二维码编码与 Snippet 路径；本次代码清理需要在真机运行现有快捷指令重新确认。

## 历史兼容原则

保留单参数入口 `ShowTransitCodeSimpleIntent`、旧版 `ShowTransitCodeIntent`、内部 `TransitCodePresentationSnippetIntent` 与 `QRCodeMatrix` / `QRCodeModulesShape`。从快捷指令取得的内容在进入 QR 编码时保持原文不变。
