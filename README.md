# TianfuGlass · 天府通 Glass

当前候选版本：**v0.8.1（Build 20）**。

> 本仓库是公开仓库。禁止在源码、CI、README、日志、截图及 Issues 中上传真实 Cookie、TGT、Token 或动态乘车码。用户此前在对话中展示过会话凭证，建议通过官方渠道重新登录使旧凭证失效。

## v0.8.1 · App Shortcuts 空白 Snippet 修复候选

- iOS 27 真机反馈：v0.8.0 自动注册的「演示天府通乘车码」在快捷指令 App 执行时仅出现系统 Done 按钮，二维码内容缺失；**不能认定新 App Shortcuts 已经成功显示**。
- 修复实验：自动注册的「演示天府通乘车码」和「获取天府通乘车码」改为由 App Intent 的 `perform()` 直接返回 `ShowsSnippetView`，不再通过第二层 `TransitCodePresentationSnippetIntent` 转发。复用原有 `QRCodeMatrix` 和 `VectorTransitCodeSnippetView`，未更改二维码绘制、Cookie 和网络行为。
- 同时自动注册「诊断文字弹窗」作为对照，直接调用历史已通过的 `GlassDirectViewDiagnosticIntent`。验收先运行文字诊断，再运行演示二维码，最后才运行真实 API 取码。
- **该版本属于有边界的诊断候选**。不能以 Xcode 编译成功代替真实 iOS 27 Snippet 展示；仍需真机验证。此前成功的「显示天府通乘车码」/V3 兼容入口不修改。
- 保留由系统管理的 Liquid Glass、Done、弹层位置和入场动画；不关闭设备动态效果。

## v0.8.0 · 由 App 自动取码并悬浮展示

- 新增无参数「获取天府通乘车码」App Shortcut，通过后台 URLSession POST 请求固定的 HTTPS 天府通 API，并把有效 result.code 原文交给现有 SnippetIntent。
- 新增「演示天府通乘车码」App Shortcut，无需网络或 Cookie，便于验证系统自动发现的入口。
- App 内新增「登录会话」设置：用户**首次自行粘贴 Cookie 字符串**（包含 TGT，不含 cookie: 前缀）。使用设备 Keychain 的 WhenUnlockedThisDeviceOnly 方式保存、覆盖、清除。不会保存到 UserDefaults、App Shortcut 参数或项目文件。
- 不直接嵌入用户提供过的真实 Cookie。API 客户端禁用缓存和 cookie jar、设置 12 秒超时，验证 HTTP 状态、返回结构、绑定状态及二维码原文，不保存实时二维码，也不在错误提示中回显响应/凭证。
- 继续保留旧的「显示天府通乘车码」和 V3 操作，复用已在地铁闸机成功识别的黑白矢量二维码、纯白静区、系统 Done 与 Liquid Glass。

### 建议验收顺序

1. 安装候选 IPA，首次打开 App，在「登录会话」中保存自己当前有效 Cookie。
2. 在 Spotlight、Siri 或「快捷指令」App 的 TianfuGlass 操作列表找到「演示天府通乘车码」，验证是否不打开主界面就能悬浮显示演示二维码。
3. 再运行「获取天府通乘车码」，检查是否能自动请求新的 result.code 并展示。每次执行请求新码，不使用旧码缓存。
4. 验证会话失效、网络失败和服务端无效响应都有明确错误；最后在地铁闸机验收真实取码链路。

**不能只凭 Xcode 构建就认定 iOS 27 的自动发现和后台 Snippet 已真机通过**。是否能在 Spotlight、Siri 或其他触发入口显示，由系统运行环境决定。自定义 ControlWidget 仍不能直接展示 Snippet。当前不支持自动续期、后台扫码成功回调或自动关闭系统 Snippet。

---
## 历史版本

iOS 26+ / iOS 27 SwiftUI + App Intents Snippet，用于在 iPhone「快捷指令」中直接展示天府通乘车二维码，不打开 App 主界面。

当前测试版本 **v0.7.2 (Build 18)**。**仓库为 Public**：禁止提交真实 Cookie、TGT、Token、动态二维码内容或包含账号信息的快捷指令。

## 使用

1. 原来的「天府通」快捷指令继续自行请求接口，并从响应字典中提取 `result.code`（不要误取外层响应状态 `code`）。
2. 添加 **「显示天府通乘车码」** 操作；唯一参数「乘车码内容」选择 `result.code` 原始字符串。新操作不需要有效期。
3. 保留该操作的系统「运行时显示」选项，从快捷指令列表或其他支持 Snippet 的入口执行。
4. 每次需要新乘车码时重新运行快捷指令。

保留兼容入口「显示天府通乘车码 V3」，但其有效期输入现在不显示在乘车码界面上。代码不会把原始二维码字符串解码、裁剪或写入持久化存储。

## v0.7.2 · 大图标与柔和浮雕

- 延续 v0.7.1 的蓝青渐变**满幅背景**，仍然没有内部白色圆底、额外玻璃圆片或文字。
- 以图标画布中心为锚点，仅将地铁车头、车窗、车灯和轨道整体**放大 20%**；背景尺寸不变，列车主体更饱满、更适合灵动岛的小尺寸显示。
- 参考更简洁的现代 iOS App Icon：保留轻微车身冷白渐变、柔和阴影和细薄高光边缘，避免增加复杂纹理或额外图层。
- 只修改 `scripts/generate_app_icon.swift` 的绘制，保持原有 1024px PNG 输出、`AppIcon` 资源目录、CI 自动构建与校验工作流。构建后 GitHub Release 同时提供真实 PNG 预览。
- **不修改** SwiftUI Snippet、QRCodeMatrix、矢量二维码、白色静区、快捷指令参数或系统 Liquid Glass / 灵动岛动画。v0.7.2 真机图标观感待确认。

## v0.7.1 · 简化图标及立体列车

- 完全移除原图标中间额外的半透明椭圆/白色玻璃圆底；保留全幅蓝青渐变背景，主视觉只剩居中的白色地铁车头。
- 给地铁车身增加轻微明暗渐变与投影，并在窗户上增加很轻的玻璃高光，保持灵动岛小尺寸下可辨认，禁止过度纹理、额外图标边框或文字。
- `scripts/generate_app_icon.swift` 是图标的唯一来源。GitHub Actions 每次构建直接运行生成脚本；本地 Xcode 构建在 PNG 不存在或脚本比 PNG 新时重新生成，避免缓存旧图标。
- CI 检查 `CFBundleIcons` 中的 `AppIcon`，Release 附带 PNG 预览与未签名 IPA。**本版本图标尚未经过用户真机视觉验收。**
- App Intents Snippet、原生 Done / 灵动岛执行状态、二维码白底和扫码数据逻辑保持不变。

## v0.7.0 · 正式 App 图标

- 不再使用自动生成的空白占位图标。新增原创的**蓝青渐变背景与简化白色正面列车**作为 App Icon；没有文字，缩小至灵动岛尺寸仍有可辨识轮廓。
- `scripts/generate_app_icon.swift` 用 Swift / CoreGraphics 绘制 1024×1024 PNG；`Sources/Assets.xcassets/AppIcon.appiconset/Contents.json` 将其声明为 `AppIcon`；Xcode 构建设置选择此图标，并由系统进行图标裁剪和显示。
- 这是**Liquid Glass 风格的单张高分辨率应用图标**，不是由 Icon Composer 生成的多层 .icon 文件。iOS 会按照当前系统外观显示标准应用图标，但完整多层折射和材质响应需另行制作 Icon Composer 原生分层文件。
- GitHub Actions 会自动生成图标、确认最终 IPA 的 `CFBundleIcons` 包含 `AppIcon`，并额外在 Releases 附上一张 1024px 图标预览。
- **灵动岛的快捷指令执行提示无法由此关闭**，这次只替换默认占位图标，不改变系统运行指示、Snippet、二维码或原生动画。
- 实际在灵动岛、主屏幕和深色/着色模式的观感，需要 v0.7.0 真机验收。

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
