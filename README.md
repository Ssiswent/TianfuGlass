# TianfuGlass · 天府通 Liquid Glass

iOS 26+ SwiftUI + App Intents Snippet，当前测试版本 **v0.6.1（Build 10）**。

> **注意：本仓库目前是 Public。** 请勿提交真实 Cookie、TGT、Token、乘车码、含登录信息的快捷指令文件或截图。

## 主要使用方式

保留原「天府通」快捷指令中的网络请求和 Cookie（只留在自己的 iPhone 上）。从响应中读取 `result.code` 的**原始字符串**：

```json
{
  "msg": "success",
  "code": 1,
  "result": {
    "isBinded": true,
    "expiresIn": "60",
    "code": "<二维码原始字符串>"
  }
}
```

请注意：外层 `code: 1` 是状态码，**不是**二维码内容。

在「获取 URL 的内容」之后使用两个「获取字典值」：
1. 从 API 返回取 `result`。
2. 从该 `result` 取 `code`。
3. 检查响应成功且 `code` 有值，然后添加新版 **「显示天府通乘车码」** App Intent；把唯一的「乘车码内容」设为第二步的魔法变量。
4. 删除旧的二维码生成 / 快速查看操作，以及不需要的重复循环。

**新版操作仅有一个参数，不需要有效期。** 为避免破坏用户已经创建的快捷指令，旧版 **「显示天府通乘车码 V3」** 继续保留并接受旧的有效期参数，但输出界面也不会显示时间。要在快捷指令编辑界面去掉这个旧参数，删除旧 V3 操作并添加新版操作。

二维码原文直接编码，不进行 Base64 解码、trim 或其他变换。空白内容或过长内容会被拒绝；二维码模块保持黑白及四模块 quiet zone，不在二维码上叠加玻璃材质。**新码必须重新运行快捷指令获取。**

## UI 与系统约束

- Snippet 由 iOS 顶部弹层展示，不需要打开 TianfuGlass 主界面。
- 系统管理 Snippet 的位置、Done 按钮、Liquid Glass 外观和入场动画；不干预或试图禁用原生动画。
- 正式乘车码 Snippet 只显示标题及二维码；演示二维码才显示「不可乘车」提示。
- 本项目不主动请求 API、保存 Cookie 或持久化乘车码。请勿把实时码写入日志或公开截图。

## 验证情况

用户已在 iOS 27 真机验证 App 原生弹窗、A/C 文字 Snippet、D 参数化文字 Snippet、B 矢量二维码 Snippet 可正常展示。

**v0.6.1 新版单参数 Intent 与实际闸机扫码尚未真机验收。** 请先用 `TIANFU-GLASS-TEST-NOT-VALID` 验证，只在显示正确后换成 `result.code`。

## CI / Releases

推送源码到 `main` 后 GitHub Actions 使用 Xcode 27 构建未签名 IPA，验证压缩包，自动发布独立 GitHub **Pre-release**，并上传 SHA-256 文件。

[下载 Releases](https://github.com/Ssiswent/TianfuGlass/releases)

IPA 仍需经签名流程才能安装到普通 iPhone。构建成功不等于闸机兼容性验收成功。
