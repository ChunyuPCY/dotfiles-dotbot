# L3.5 · 格式化（conform.nvim）

## 目标
为你的语言配置格式化，理解 `formatters_by_ft` 与 `lsp_format = 'fallback'`，并验证 `<Space>lf` 一键格式化。

## 前置
- L2.5（conform 基础）完成。

## 核心概念

conform.nvim 的核心配置只有一张映射表 + 全局选项：
```lua
require('conform').setup({
  default_format_opts = { lsp_format = 'fallback' },
  formatters_by_ft = { lua = { 'stylua' } },
})
```
- `formatters_by_ft`：文件类型 → 一串 formatter（按顺序尝试）。
- `lsp_format = 'fallback'`：若该文件类型**没有**专用 formatter，就回退用 LSP 的 `textDocument/formatting`。
- 触发：`<Space>lf`（`20_keymaps.lua:189`），对应 `require('conform').format()`。

## 动手实操

### 1. 装 CLI 工具
以 Python + black 为例：
```bash
pip install black
which black
```

### 2. 加配置
`plugin/40_plugins.lua` 的 conform 段加：
```lua
formatters_by_ft = { lua = { 'stylua' }, python = { 'black' } },
```

### 3. 验证
打开 `.py` 文件，故意写乱缩进/超长行，按 `<Space>lf` → 代码被 black 规整。`:messages` 无报错。

## 验证反馈
| 命令 | 期望输出 |
|---|---|
| `:!which stylua` / `:!which black` | 工具路径 |
| `<Space>lf` | 代码被格式化 |
| `:lua =require('conform').list_formatters(0)` | 当前 buffer 可用的 formatter |

## 常见坑
- **工具未装**：conform 找不到 formatter 会报错，`:messages` 能看到。先 `:!which xxx` 验证。
- **多个 formatter 有顺序**：`formatters_by_ft` 是数组，按顺序尝试第一个可用的。
- **`fallback` 的语义**：`lsp_format = 'fallback'` 是"没专用 formatter 才用 LSP"，不是"两者都跑"。

## 网络大神总结

> **stevearc（conform.nvim 作者）**：conform 的设计目标是"**格式化应该安静、异步、无感**"。他的建议是配合 `BufWritePre` 自动格式化（`format_on_save`），但新手阶段**先手动 `<Space>lf`**，理解发生了什么，再决定是否自动化。

> **Folke（LazyVim 作者）**：LazyVim 里格式化、lint 都靠 conform + nvim-lint 这对"轻量双子星"——**它们都只做"调度外部工具"这一件事，配置统一成一张映射表**。这是比"一个语言一个插件"更清爽的现代做法。

## 延伸阅读
- `:h conform` · `:h conform-formatters` · `:h conform-options`
- `:h conform.format()`

## 自测
- ☐ 你的语言能 `<Space>lf` 格式化
- ☐ 能解释 `lsp_format = 'fallback'` 何时触发
- ☐ 会用 `:!which` 验证工具存在
