# L5.2 · vim.lsp 深度

## 目标
深入 Neovim 内置 LSP API：`vim.lsp.config`、`vim.lsp.start`、`on_attach`、capabilities，能写自定义 `on_attach` 加 buffer 局部映射。

## 前置
- L2.5、L3.4 完成。

## 核心概念

### 1. `vim.lsp.config` / `vim.lsp.enable`（声明式）
`vim.lsp.enable({ 'lua_ls' })` 会根据 `nvim-lspconfig` 或 `vim.lsp.config('lua_ls', {...})` 声明的规则启动 server。`after/lsp/lua_ls.lua` 就是返回一张 config 表。

### 2. `vim.lsp.start`（命令式，手动起一个 server）
`40_plugins.lua:186` 的 zk 就是例子：
```lua
config = {
  name = 'zk', cmd = { 'zk', 'lsp' }, filetypes = { 'markdown' },
}
```
它绕过 lspconfig，直接指定可执行命令。适合冷门/自定义 server。

### 3. `on_attach`（client 连上后的钩子）
`after/lsp/lua_ls.lua:14`：
```lua
on_attach = function(client, buf_id)
  client.server_capabilities.completionProvider.triggerCharacters = { '.', ':', '#', '(' }
end
```
这是做 buffer 局部映射、按需改 capabilities 的地方。

### 4. capabilities（能力协商）
`30_mini.lua:221`：
```lua
vim.lsp.config('*', { capabilities = MiniCompletion.get_lsp_capabilities() })
```
通配 `*` 给所有 server 打上 mini.completion 支持的能力。

## 动手实操
在 `after/lsp/lua_ls.lua` 的 `on_attach` 里加一条 buffer 局部映射（演示 LSP 相关映射只在有 server 时出现）：
```lua
on_attach = function(client, buf_id)
  -- 只在该 buffer 生效的"跳转实现"映射
  vim.keymap.set('n', 'K', function()
    vim.lsp.buf.hover()
  end, { buffer = buf_id, desc = 'LSP hover' })
end
```
重启后打开 lua 文件：`:verbose nmap K` 显示 buffer 局部映射；`K` 触发 hover。

## 验证反馈
| 命令 | 期望输出 |
|---|---|
| `:lua =vim.lsp.get_clients()` | client 列表（含 capabilities 摘要） |
| `:lua =vim.lsp.get_clients()[1].server_capabilities` | 该 server 能力 |
| `:verbose nmap K` | buffer 局部映射来源 |
| `:h vim.lsp.ClientConfig` | 所有可用字段 |

## 常见坑
- **`on_attach` 每次 attach 都跑**：映射要带 `buffer = buf_id`，否则会重复注册到全局。
- **capabilities 要用 `'*'` 打底**：在 `on_attach` 前就设好（本配置在 `30_mini.lua` 里先 `vim.lsp.config('*', ...)`）。
- **`vim.lsp.start` vs `enable`**：`start` 是手动一次性，`enable` 是按需自动。多数情况用 `enable`。

## 网络大神总结

> **Neovim 团队（vim.lsp 设计者）**：内置 LSP 的核心设计是"**声明式优先，命令式兜底**"——能用 `vim.lsp.enable` + config 表表达的，就别手写 `start` 的 50 行样板。`on_attach` 只留"真正依赖 client 的动态逻辑"。

> **echasnovski（mini.completion 作者）**：`MiniCompletion.get_lsp_capabilities()` 这行体现了"**capabilities 是插件与 LSP 的握手**"——通过它，补全插件才能告诉 server"我要哪些补全能力"。理解 capabilities，你就理解了 LSP 插件集成的底层。

## 延伸阅读
- `:h vim.lsp.config()` · `:h vim.lsp.start()` · `:h vim.lsp.enable()`
- `:h vim.lsp.ClientConfig` · `:h LspAttach`
- `:h vim.lsp.buf.*`（所有 buffer 操作）

## 自测
- ☐ 能写一个带 `buffer` 参数的 `on_attach` 映射
- ☐ 能说清 `vim.lsp.start` 与 `vim.lsp.enable` 的区别
- ☐ 能解释 capabilities 的作用
