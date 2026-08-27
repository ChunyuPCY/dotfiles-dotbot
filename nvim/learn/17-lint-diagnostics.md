# L3.6 · lint + 诊断（vim.diagnostic + nvim-lint）

## 目标
理解 Neovim 的**诊断系统**（`vim.diagnostic`），会配置 lint（静态检查），并让错误以可见方式显示在屏幕上。

## 前置
- L2.2（诊断配置）、L2.5（LSP 诊断）完成。

## 核心概念

### 1. 诊断系统（`:h vim.diagnostic`）
Neovim 统一的诊断展示层，**来源无关**——无论是 LSP、lint、还是 `vim.diagnostic.set()` 手动塞的，都进同一个系统。展示由 `vim.diagnostic.config()` 控制（本仓库 `10_options.lua:106` 配了保守显示）。

### 2. LSP 自带诊断 vs 独立 linter
- LSP server 通常已内置诊断（如 pyright 的类型检查）。
- 独立 linter（如 `ruff`、`eslint`）需额外调度，常用 **nvim-lint** 插件（和 conform 同作者思路，一张映射表）。

### 3. 诊断 API 快速上手
```lua
vim.diagnostic.get(0)              -- 当前 buffer 所有诊断
vim.diagnostic.open_float()        -- 浮窗看详情（<Space>ld）
vim.diagnostic.set(ns, buf, diags) -- 手动塞诊断
```

## 动手实操

### 方案 A（先用 LSP 自带诊断，最简单）
pyright 已经能报告 Python 类型错误。写一个错误类型：
```python
x: int = "hello"   # pyright 会报类型错误
```
观察：行号处出现红色下划线/符号；`<Space>ld` 弹详情；`<Space>fd` 列出 workspace 所有诊断。

### 方案 B（接独立 linter nvim-lint，可选进阶）
1. `plugin/40_plugins.lua` 加 `add({ 'https://github.com/mfussenegger/nvim-lint' })`。
2. 配置：
```lua
require('lint').linters_by_ft = { python = { 'ruff' } }
Config.new_autocmd('BufWritePost', nil, function()
  require('lint').try_lint()
end, 'Lint on save')
```
3. 装 `pip install ruff`，保存文件后看诊断。

## 验证反馈
| 命令 | 期望输出 |
|---|---|
| `:lua =vim.diagnostic.get(0)` | 非空诊断数组 |
| `<Space>ld` | 浮窗显示详情 |
| `<Space>fd` | 列出所有诊断 |
| `:lua =vim.diagnostic.config()` | 当前诊断配置 |

## 常见坑
- **诊断不显示≠没诊断**：`update_in_insert = false`（`10_options.lua:121`）意味着输入时暂不刷新，切回 Normal 或移动才更新。
- **ns 命名空间**：手动 `vim.diagnostic.set` 要指定 namespace（`vim.api.nvim_create_namespace`），否则覆盖默认。
- **severity 过滤**：`10_options.lua:108` 的 `signs.severity` 只显示 WARN~ERROR，HINT 只在 underline 显示。

## 网络大神总结

> **mfussenegger（nvim-lint / nvim-dap 作者）**：nvim-lint 的哲学是"**诊断已内建，插件只负责喂数据**"——它不重写展示，只把 linter 输出塞进 `vim.diagnostic`。这种"复用核心"的思路，和 conform 如出一辙，是当下插件设计的主流。

> **Neovim 团队**：`vim.diagnostic` 是 0.6+ 最重要的重构之一——"**一个统一的诊断系统，取代以前各插件自绘的标记**"。理解它，你就能看懂几乎所有现代插件的错误展示。

## 延伸阅读
- `:h vim.diagnostic` · `:h vim.diagnostic.config()`
- `:h vim.diagnostic.get()` · `:h vim.diagnostic.set()`
- [nvim-lint 仓库](https://github.com/mfussenegger/nvim-lint)

## 自测
- ☐ 能在屏幕上看到诊断并用 `<Space>ld` 看详情
- ☐ 能解释 `update_in_insert = false` 的影响
- ☐ 能说出 LSP 诊断与独立 linter 的区别
