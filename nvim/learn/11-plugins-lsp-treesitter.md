# L2.5 · treesitter / LSP / formatter（plugin/40_plugins.lua）

## 目标
搞懂 Neovim 0.12 的三大外部能力：tree-sitter（语法树）、LSP（语言服务）、conform（格式化），并会用健康检查验证它们都正常工作。

## 前置
- L2.1–L2.4 完成。

## 核心概念

### 1. Tree-sitter（`40_plugins.lua:15`）
把文本解析成**语法树**，供高亮、折叠、缩进、textobject 等高级功能使用。Neovim 内置支持，但需两块补充：
- **解析器**（parser）：把文本变成树。Lua/vimdoc/markdown 已内置，其余靠 `nvim-treesitter` 安装（`40_plugins.lua:53` 的 `languages` 数组）。
- **查询文件**（query）：定义如何从树提取信息（`:h treesitter-query`），`nvim-treesitter` + `nvim-treesitter-textobjects` 提供。

```lua
Config.on_packchanged('nvim-treesitter', { 'update' }, ts_update, ':TSUpdate')  -- 更新后跑 :TSUpdate
add({ 'https://github.com/nvim-treesitter/nvim-treesitter', '...textobjects' })
local languages = { 'lua', 'vimdoc', 'markdown' }  -- 要装解析器的语言
```

### 2. LSP（`40_plugins.lua:81`）
Language Server Protocol：**server**（语言专用程序） + **client**（Neovim 本身）。Neovim 是 client（`:h vim.lsp`），server 需单独装，常用配置收在 `nvim-lspconfig` 插件里。
```lua
add({ 'https://github.com/neovim/nvim-lspconfig' })
vim.lsp.enable({ 'lua_ls' })   -- 按 nvim-lspconfig 的规则自动启用
```
个性化配置放 `after/lsp/lua_ls.lua`（返回一张 `vim.lsp.Config` 表）。

### 3. Formatter（`40_plugins.lua:112`）
`conform.nvim` 统一调度外部格式化工具：
```lua
require('conform').setup({
  default_format_opts = { lsp_format = 'fallback' },  -- 无专用 formatter 时用 LSP
  formatters_by_ft = { lua = { 'stylua' } },          -- 文件类型 → formatter
})
```
触发：`<Space>lf`（`20_keymaps.lua:189`）。

## 动手实操 + 验证（每个都要有可见输出）

1. **treesitter**：
   ```
   :checkhealth nvim-treesitter
   ```
   打开一个 lua/md 文件，执行 `:InspectTree` → 底部出现语法树窗口；`:InspectTree` 再切回。

2. **LSP**：
   ```
   :LspInfo
   ```
   应显示 `lua_ls` 已连接。在 lua 文件里：
   ```
   :lua =vim.lsp.get_clients()
   ```
   → 非空数组。`gd`（`:h gd` 跳定义）可用。

3. **formatter**：
   故意在 lua 文件写乱缩进，按 `<Space>lf` → 代码被 stylua 规整（本仓库有 `stylua.toml`，2 空格、120 列）。

## 验证反馈
| 命令 | 期望输出 |
|---|---|
| `:checkhealth nvim-treesitter` | 全绿 |
| `:checkhealth vim.lsp` | 全绿 |
| `:InspectTree` | 语法树窗口 |
| `:lua =vim.lsp.get_clients()` | 非空 |
| `<Space>lf` | 代码被格式化 |

## 常见坑
- **tree-sitter 装解析器需重启**：`40_plugins.lua:51` 注释——改 `languages` 后重启一次等待安装完成。
- **LSP server 是外部程序**：`lua_ls` 若没装（`lua-language-server`），`vim.lsp.enable` 不会报错但也不连。`:checkhealth vim.lsp` 会提示。
- **formatter 依赖 CLI 工具**：`stylua` 必须已在 PATH 里（`:!which stylua` 验证）。

## 网络大神总结

> **Neovim 团队（0.11+ 内置 LSP 设计者，bfredl 等）**：`vim.lsp.enable()` 把 LSP 配置从"每个 server 写一堆 boilerplate"简化成"一行声明 + 一张可选的 config 表"。**优先用内置 `vim.lsp`，只在需要时引入 lspconfig**——这是 0.11 之后官方反复强调的方向。

> **stevearc（conform.nvim 作者）**：conform 的 `lsp_format = 'fallback'` 是"最省心"的格式化策略——**有专用 formatter 用它，没有就用 LSP 的 format**。他主张"格式化应该是一键、静默、可预测的"，不要为了格式化引入一整套心智负担。

> **Folke（lazy.nvim/LazyVim 作者）**：treesitter + LSP + formatter 是"现代编辑器体验"的三根柱子。他的建议是**先把这三样配好，再谈花哨插件**——它们带来的跳转/补全/格式化收益，远大于任何一个装饰性插件。

## 延伸阅读
- `:h treesitter` · `:h lsp` · `:h vim.lsp.enable()` · `:h vim.lsp.config()`
- `:h conform` · `:h conform-options`

## 自测
- ☐ 能说清 tree-sitter 需要"解析器 + 查询文件"两块
- ☐ 能区分 LSP 的 server 与 client 各指什么
- ☐ 三者健康检查都能看到绿色
