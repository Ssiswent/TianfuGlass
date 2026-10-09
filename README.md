# TianfuGlass · 天府通 Glass

适用于 iOS 26+ / iOS 27 的 SwiftUI + App Intents Snippet。通过 iPhone「快捷指令」直接显示天府通乘车二维码，无需预先打开主 App。

当前版本：**v0.7.4（Build 20）**。

## 快捷指令使用方法

1. 在「获取 URL 内容」操作中调用你自己的乘车码接口。
2. 在 HTTP 请求头的 `Cookie` 字段中填写有效 Cookie。格式示例（`xxx` 均为占位符）：

```text
TGT=xxx; CNZZDATA1280142547=xxx; BA31C2997F81913F=xxx; UM_distinctid=xxx;
```

3. 从响应中提取 **`result.code`** 的原始字符串，而不是响应最外层的 `code` 状态码。
4. 使用 TianfuGlass 提供的唯一快捷指令操作 **「显示天府通乘车码」**，将参数 **「乘车码内容」** 设为 `result.code`。开启系统「运行时显示」。
5. 每次需要新乘车码时重新运行快捷指令。

App 首页也提供了可复制的 Cookie **格式占位符**，不会读取、保存或发送真实 Cookie。网络请求及 Cookie 管理完全由用户自己的快捷指令执行。

## 显示设计

- 由系统提供 Snippet 外层 Liquid Glass、Done 按钮与弹出动画。
- 顶部只有居中的 `tram.fill` 图标，没有额外背景、标题或装饰。
- 中间保留 228pt 黑白矢量二维码、四模块白色 quiet zone 和纯白背景，优先保证扫码。
- **不在 Snippet 视图中使用 `.glassEffect`**：v0.7.3 真机日志证实该效果可能导致 Snippet 视图归档失败，主 App 进程存活时只显示 Done。
- App 主界面只保留使用说明和 Cookie 格式，无测试/诊断功能。
- 只提供一个公开 App Intent，不再保留旧版 V3 操作；旧快捷指令如绑定 V3，需要重新选择新操作。

## 隐私与安全

**此仓库是公开仓库。严禁提交、发布、发送或截图泄露真实 Cookie、TGT、Token、动态二维码、会话 ID 或带账号信息的快捷指令。** 示例全部使用无效占位符。真实凭据仅由用户自行在本机快捷指令中配置。二维码由本地 Core Image 从 `result.code` 生成，不持久化存储。

## 构建

GitHub Actions 使用 Xcode 27 自动生成、编译并发布 **未签名 IPA** 至 [Releases](https://github.com/Ssiswent/TianfuGlass/releases)。IPA 必须先签名才能安装到普通 iPhone。CI 编译成功不代表已完成真机验收或实际闸机扫码验收。
