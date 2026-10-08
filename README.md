# TianfuGlass · 天府通 Liquid Glass

iOS 26+ / iOS 27 SwiftUI + App Intents Snippet。当前候选版本 **v0.6.0 (9)**。

**本仓库当前是 Public。严禁提交真实 Cookie、TGT、Token、二维码载荷或完整快捷指令。**

## 现在的目标

使用原有的「天府通」快捷指令执行 API 请求，然后调用「显示天府通乘车码 V3」展示二维码。**不打开 TianfuGlass App 主界面**；Snippet 的位置、Done 按钮、转场和 Liquid Glass 均遵循 iOS 原生行为，不干预系统动画。

### 一次性接入快捷指令

保留现有的「获取 URL 内容」及其个人 Cookie 配置；**这些数据只留在设备的快捷指令中**，不要提交到仓库。

原 API 结构类似：

```json
{
  "msg": "success",
  "code": 1,
  "result": {
    "isBinded": true,
    "expiresIn": "60",
    "code": "<真实二维码字符串>"
  }
}
```

注意：**外层 `code: 1` 是状态码，不是二维码内容**。真正的数据是 `result.code`。

在「获取 URL 内容」后：

1. 用「获取字典值」从 API 返回中取 `result`，再从 `result` 中取 `code`，得到二维码的完整原文字符串。
2. 检查返回成功、`result.code` 非空；失败时显示错误提示并停止，不调用二维码显示 Intent。可按需检查 `isBinded`。
3. 添加「显示天府通乘车码 V3」，**乘车码内容**选择刚刚提取的 `result.code` 魔法变量。首次测试可输入 `TIANFU-GLASS-TEST-NOT-VALID`，验证显示后再切回真实值。
4. **有效期（秒）**先填 `60`。成功后，可以从 `result` 再读取 `expiresIn`，将字符串数字 `"60"` 转换成数字后传入。
5. 删除原来用于最终显示的「创建二维码」「快速查看」「显示结果」等操作；只保留新的 App Intent 作为最后展示步骤。

可以继续从「快捷指令」列表、主屏幕图标等支持 Snippet 的入口运行。控制中心的 Control 运行环境不一定支持 Snippet，不能由此推断应用出错。

### 显示与有效期

- 乘车码原始 UTF-8 文本原样传入 QR 编码器；**不对看似 Base64 的原文进行解码**。
- 对空白内容、超过 2000 UTF-8 字节的内容、范围之外的有效期（1～3600 秒）提供明确错误。
- 二维码保持黑白、方形和安静区（quiet zone），二维码模块不会应用模糊玻璃材质。
- 有效期文本来自传入参数，属于接口提供的**标称有效期**，并非精确实时倒计时；不会自动刷新。每次需要新码时重新运行快捷指令获取。
- App 不需要访问网络或保存 Cookie。本项目自身没有持久化二维码，但 iOS / 快捷指令的运行上下文由系统管理；不要将生产凭证加入日志、屏幕录制或公开分享的快捷指令。

## 验证状态

已由用户在 iOS 27 真机确认：

- App 内原生文字 Sheet、二维码 Sheet：PASS。
- 快捷指令 A（纯文字）、C（直接静态视图）：PASS。
- 快捷指令 D（参数化文字）、B（纯矢量二维码）：**v0.5.0 PASS**。
- 系统原生 Snippet 入场动画：**用户选择保留**，不抑制系统转场。

**尚未真机验收：v0.6.0 完整真实 `result.code` → `显示天府通乘车码 V3` 路径、闸机扫码与过期后的刷新。** CI 编译不能替代这些测试。先测试无敏感数据的字符串，再接入真实接口。

## GitHub Actions / Releases

GitHub Actions 使用 Xcode 27 编译、打包 unsigned IPA，校验 ZIP 完整性与 SHA-256，并在成功后自动发布到 [GitHub Releases](https://github.com/Ssiswent/TianfuGlass/releases) 的独立 Pre-release，同时保留短期 Artifact 备份。

未签名 IPA 必须经过合适的签名流程，才能安装到普通 iPhone。即使 CI 通过，也不代表乘车码能被闸机接受。
