# TianfuGlass · 天府通 Glass

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
