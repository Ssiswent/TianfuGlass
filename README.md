# TianfuGlass · 天府通 Liquid Glass

一个轻量的 iOS 26+ SwiftUI / App Intents 示例项目，在 Apple 快捷指令中显示乘车码 Snippet。当前版本 **v0.3.1 (4)**。

## 状态

- GitHub Actions Xcode 27 Release 编译及未签名 IPA 打包已通过（[首次成功构建](https://github.com/Ssiswent/TianfuGlass/actions/runs/37727543751)）。
- 已确认 IPA 内包含三项可被快捷指令发现的操作及 Snippet 元数据。
- **尚未证明 iPhone 上的 Snippet 显示问题已解决。** 原先的现象是系统仅出现 Done、没有自定义内容。
- 系统决定 Snippet 的弹出位置和 Done 按钮；本项目不能将其强制改为自定义的居中模态窗口。

## 获取 IPA

打开 [Actions → Build unsigned IPA (Xcode 27)](https://github.com/Ssiswent/TianfuGlass/actions/workflows/build-unsigned-ipa.yml)，选择成功运行的构建，下载 `TianfuGlass-v0.3.1-unsigned-IPA` Artifact，解压得到 `TianfuGlass-v0.3.1-unsigned.ipa`。

**未签名 IPA 不能直接安装到普通 iPhone；必须通过合适的开发或侧载签名流程签名。** 不要在仓库中提交签名私钥或登录 Cookie。

## 诊断（不需要真实 Cookie）

1. 安装并打开 App，确认首页能显示离线演示二维码。
2. 新建一个空白快捷指令，只放入「Glass 诊断 A · 纯文字」，从快捷指令列表执行。如果仍然只有 Done，先停止后续诊断。
3. A 成功后，新建另一个快捷指令运行「Glass 诊断 B · 测试二维码」。
4. A/B 都正常后，在原「天府通」快捷指令里使用「显示天府通乘车码 V3」，传入接口解析出的 `result.code` 原文，并按需填写 `expiresIn` 秒数。
5. 尽量从快捷指令列表或主屏幕运行；从控制中心直接调用 App Intent 的 Control 方式不支持 Snippet 显示。

App 不包含真实 API、Cookie 或乘车凭证，演示二维码不可用于乘车。

## 开发及 CI

通过 `project.yml` 使用 [XcodeGen](https://github.com/yonaskolb/XcodeGen) 生成 `TianfuGlass.xcodeproj`。源码位于 `Sources/`，CI 配置位于 `.github/workflows/build-unsigned-ipa.yml`。

提交源码或工作流至 `main` 会自动运行一次构建，也可以在 Actions 页面手动运行。
