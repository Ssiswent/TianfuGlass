# TianfuGlass · 天府通 Glass

iOS 26+ / iOS 27 SwiftUI + App Intents Snippet，用于在 iPhone「快捷指令」中直接展示天府通乘车二维码，不打开 App 主界面。

当前测试版本 **v0.6.6 (Build 15)**。**仓库为 Public**：禁止提交真实 Cookie、TGT、Token、动态二维码内容或包含账号信息的快捷指令。

## 使用

1. 原来的「天府通」快捷指令继续自行请求接口，并从响应字典中提取 `result.code`（不要误取外层响应状态 `code`）。
2. 添加 **「显示天府通乘车码」** 操作；唯一参数「乘车码内容」选择 `result.code` 原始字符串。新操作不需要有效期。
3. 保留该操作的系统「运行时显示」选项，从快捷指令列表或其他支持 Snippet 的入口执行。
4. 每次需要新乘车码时重新运行快捷指令。

保留兼容入口「显示天府通乘车码 V3」，但其有效期输入现在不显示在乘车码界面上。代码不会把原始二维码字符串解码、裁剪或写入持久化存储。

## UI 设计与 iOS 27 限制

- 卡片顶部仅保留居中的 `tram.fill` SF Symbol，不显示文字标题。
- 图标采用**已在 v0.6.4 真机成功显示**的结构：`Image` 本身不加 `.glassEffect`，由独立的圆形背景使用 `.glassEffect(.regular, in: .circle)`。v0.6.5 将 `.glassEffect` 直接应用到图标导致整个图标在实际 Snippet 消失，因此 v0.6.6 恢复经过验证的 40pt / 18pt 图标布局。玻璃圆形底座在不同背景下可能非常淡；保证图标可见优先于强调独立玻璃效果。
- 二维码绘制仍使用 `QRCodeMatrix` 与 `QRCodeModulesShape`，保持 228pt 黑白模块区、纯白背景与四模块 quiet zone。不能把二维码置于半透明玻璃上。
- 正式乘车码不显示有效期、不增加额外确认或刷新按钮。原生 Done 按钮由 iOS 提供。
- **不干预 Snippet 弹出位置、Liquid Glass 系统动画、完成按钮**。
- 运行快捷指令时灵动岛出现临时 App 图标和完成勾号是 iOS 的运行状态提示，并非此 App 自行创建的 Live Activity。App Intents 没有提供可在保留 Snippet 的同时关闭此系统提示的公开 API。不要通过关闭「运行时显示」、修改设备动态效果或添加不可靠的隐藏技巧尝试规避。

## 验证状态

已由用户真机确认：

- A / C 纯文字 Snippet、D 参数化文字 Snippet：通过。
- B 矢量二维码 Snippet：通过。
- v0.6.4 顶部 `tram.fill` 图标：可见，玻璃圆形底座不明显。
- v0.6.5 顶部图标：**消失（失败）**；二维码、Done 正常。

v0.6.6 撤回导致图标消失的单独改动，**需要真机确认显示恢复**。同时，真实闸机读取乘车码还没有通过正式验收；CI 成功不代表闸机一定兼容。

## 构建及下载

主分支中的 `Sources/**`、`project.yml` 或工作流变更自动触发 [GitHub Actions](https://github.com/Ssiswent/TianfuGlass/actions/workflows/build-unsigned-ipa.yml)，使用 Xcode 27 编译，发布包含未签名 IPA 及 SHA-256 的独立 [GitHub Pre-release](https://github.com/Ssiswent/TianfuGlass/releases)。未签名 IPA 在普通 iPhone 安装前需要自行签名。
