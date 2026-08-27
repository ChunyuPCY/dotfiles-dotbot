# L3.4 · 接入你的语言 LSP

## 目标
为你的主力语言（Python/Go/TS/Rust 等任选其一）启用 LSP，完成"装 server → `vim.lsp.enable` → 个性化配置 → 验证"全流程。

## 前置
- L2.5（LSP 基础）完成。

## 核心概念

Neovim 是 LSP **client**，语言服务器是**外部程序**（server）。要让某个语言可用，需三步：
1. **装 server 程序**（用系统包管理器或 mason）。
2. **告诉 Neovim 用哪个 server**：`vim.lsp.enable({ 'xxx' })`，其中 `xxx` 是 `nvim-lspconfig` 里定义的配置名（如 `pyright`、`gopls`、`ts_ls`、`rust_analyzer`）。
3. **（可选）个性化**：在 `after/lsp/<名称>.lua` 返回一张 config 表（参考 `after/lsp/lua_ls.lua`）。

## 动手实操（以 Python + pyright 为例）

### 1. 装 server
```bash
pip install pyright      # 或 pyright 官方：npm i -g pyright
which pyright            # 确认在 PATH
```

### 2. 启用
在 `plugin/40_plugins.lua` 的 `vim.lsp.enable({...})` 里加：
```lua
vim.lsp.enable({
  'lua_ls',
  'pyright',     -- 新增
})
```

### 3. 个性化（可选）
新建 `after/lsp/pyright.lua`（仿照 `after/lsp/lua_ls.lua`）：
```lua
return {
  settings = {
    python = {
      analysis = { typeCheckingMode = 'basic' },
    },
  },
}
```

### 4. 验证
重启 nvim，打开 `.py` 文件：
```
:LspInfo
:lua =vim.lsp.get_clients()
```
- `:LspInfo` 应显示 pyright 已 attach。
- 输入 `import os` 后 `os.` 应有补全；`gd`（跳定义）对 `os.path` 生效；`<Space>lr` 重命名变量生效。

## 验证反馈
| 命令 | 期望输出 |
|---|---|
| `:LspInfo` | pyright 已连接 |
| `:lua =vim.lsp.get_clients()` | 含 `pyright` 客户端 |
| `:checkhealth vim.lsp` | 绿色 |
| 输入 `os.` | 弹出补全菜单 |

## 常见坑
- **server 不在 PATH**：`:!which pyright` 先验证，否则 `vim.lsp.enable` 静默失败。`:checkhealth vim.lsp` 会列出。
- **配置名要匹配**：`vim.lsp.enable` 用的名字是 `nvim-lspconfig` 的 server 名，不是可执行文件名（如 TypeScript 是 `ts_ls` 不是 `tsserver`）。查 `:h lspconfig-all` 或 `nvim-lspconfig` 文档。
- **after/lsp 文件名**：需与 `vim.lsp.enable` 的名字一致，Neovim 才会自动 source（`:h vim.lsp.config()`）。

## 网络大神总结

> **Neovim 团队（vim.lsp 内置化主推者）**：0.11 之后，官方反复强调"**`vim.lsp.enable()` 一行就是完整配置**"——不要再为每个 server 复制粘贴 50 行 `on_attach`。config 表只写"和默认不同的部分"。

> **mason.nvim 作者（William Boman / williamboman）**：mason 解决了"装 LSP server 很烦"这件事。他的建议是：**若你只用 Neovim，用 mason 管 server；若命令行也要用这些工具，用系统包管理器**。本仓库 `40_plugins.lua:151` 就装了 mason，可 `:Mason` 打开。

## 延伸阅读
- `:h vim.lsp.enable()` · `:h vim.lsp.config()` · `:h vim.lsp.Config`
- `:h lspconfig-all`（所有可用的 server 名）
- `:h mason`

## 自测
- ☐ 你的语言 `:LspInfo` 显示已连接
- ☐ 补全、`gd` 跳转、`<Space>lr` 重命名三样都能用
- ☐ 能说出 server 名与可执行文件名可能不同
