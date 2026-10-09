# TianfuGlass · 天府通 Glass

iOS 26+ / iOS 27 的 SwiftUI + App Intents Snippet 应用，通过用户已有的「天府通」快捷指令呈现乘车二维码。版本：**v1.0.0（Build 1）**。

## 仅需准备 Cookie

沿用已有的快捷指令以及请求接口的步骤，**只需要填写有效 Cookie**。例如，在原有 Cookie 文本位置填写以下格式（`xxx` 都是无效占位符，需要替换）：

```text
TGT=xxx; CNZZDATA1280142547=xxx; BA31C2997F81913F=xxx; UM_distinctid=xxx;
```

**不要将真实 Cookie、乘车码或含凭据的快捷指令提交到本 Public 仓库。** App 首页「复制格式」仅复制示例，不读取、不保存真实 Cookie。

## 快捷指令设置

沿用原来的「如果 字典值 有任何值」条件，在相应分支中配置：

```text
如果「字典值」有任何值
    显示天府通乘车码
        乘车码内容：字典值
        运行时显示：开启
否则
    提示更新 Cookie
结束如果
```

- 「显示天府通乘车码」接收原始二维码字符串并以系统 Snippet 显示，不需要打开 App。
- 「提示更新 Cookie」不需要参数，会使用同样的系统 Snippet 浮层提示更新 Cookie。
- 没有获取到有效的字典值不必然是 Cookie 过期，也可能是网络或接口响应异常，所以错误提示会使用「可能已失效」并建议检查网络。
- 首次升级后如果「提示更新 Cookie」在快捷指令中未出现，请在快捷指令 App 中重新搜索 TianfuGlass 的操作。
- 系统 Done 按钮与 Liquid Glass Snippet 外部容器由 iOS 控制，不在 Snippet 内容中添加 `.glassEffect`，以避免曾经复现的视图归档错误。

## UI 和实现

- 主 App 使用原生 SwiftUI Liquid Glass 卡片、系统按钮，展示配置说明与 Cookie 格式。
- 二维码 Snippet 只保留居中列车图标及纯白底的黑白矢量二维码，保持四模块 quiet zone；不显示 Cookie 和原始字符串。
- 错误 Snippet 只包含图标、简短提示及排查说明，不发网络请求或持久化数据。
- 已移除 V3 兼容入口与所有诊断测试代码。当前仅两个对外可见 App Intents：显示二维码、提示更新 Cookie。
- 不包含 App 内 API 客户端，接口访问全部留在现有快捷指令中。

## 构建

GitHub Actions 使用 Xcode 27 编译并在 [Releases](https://github.com/Ssiswent/TianfuGlass/releases) 发布未签名 IPA，需签名后才能安装。CI 通过不等于完成真机 Snippet 及真实闸机扫码验收。

版本号重新从 **1.0.0 / Build 1** 开始；部分签名/安装工具可能不支持覆盖安装时将 Build 20 降为 Build 1，如遇到安装拒绝请先考虑签名工具是否允许降级，不要轻易删除未备份的快捷指令或数据。
