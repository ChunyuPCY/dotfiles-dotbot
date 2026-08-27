# L5.1 · after/ 与 ftplugin

## 目标
掌握 `after/` 目录的"覆盖"机制，理解 ftplugin（按文件类型配置），能为自己的语言写 buffer 局部配置。

## 前置
- Phase 2、3 完成。

## 核心概念

### 1. `after/` 目录的作用
Neovim 加载配置时，`after/` 在**所有其它路径之后**被 source，所以它能"覆盖"前面任何文件或插件的行为。本仓库用它：
```
after/ftplugin/markdown.lua   ← 只对 markdown 生效的配置
after/lsp/lua_ls.lua          ← lua_ls 的个性化
after/snippets/lua.json       ← 高优先级 lua 片段
```

### 2. ftplugin（`:h ftplugin`）
`after/ftplugin/<filetype>.lua` 会在该文件类型被打开时自动执行。它是 `FileType` autocmd 的**文件化**（你 L3.3 学的 autocmd 的官方推荐替代）。

### 3. 精读示例（`after/ftplugin/markdown.lua`）
```lua
vim.cmd('setlocal spell wrap')                  -- buffer 局部开 spell+wrap
vim.cmd('setlocal foldmethod=expr foldexpr=v:lua.vim.treesitter.foldexpr()')  -- 用 treesitter 折叠
vim.keymap.del('n', 'gO', { buffer = 0 })       -- 删掉某条 buffer 局部映射
vim.b.minisurround_config = { custom_surroundings = { L = {...} } }  -- buffer 局部 mini 配置
```
注意这里**全用 buffer/window 局部**（`setlocal`、`vim.b`、`vim.bo`），不会污染全局——这是 ftplugin 的核心纪律。

## 动手实操
为你的语言写一个 ftplugin（以 Python 为例，新建 `after/ftplugin/python.lua`）：
```lua
-- 打开 python 文件时：关 wrap、开拼写关闭（Python 一般不用）、设 tabstop=4
vim.cmd('setlocal nowrap')
vim.bo.tabstop = 4
vim.bo.shiftwidth = 4
vim.bo.expandtab = true
```
重启后打开 `.py` → tabstop=4；打开 `.lua` → 仍是全局的 2。

## 验证反馈
| 命令 | 期望输出 |
|---|---|
| 打开 .py 后 `:verbose set tabstop?` | 4 + 来自 ftplugin 行号 |
| 打开 .lua 后 `:verbose set tabstop?` | 仍是全局值 |
| `:scriptnames` | 看到 `after/ftplugin/python.lua` 被加载 |

## 常见坑
- **ftplugin 里用局部选项**：用 `setlocal`/`vim.bo`/`vim.wo`，别用 `set`/`vim.o`，否则会改全局默认，影响所有文件。
- **ftplugin 在 FileType 之后加载**：若想覆盖插件默认，放 `after/ftplugin/` 而非 `plugin/`。
- **文件名即 filetype**：`python.lua` 对应 `filetype=python`；多文件类型可用 `vim.ft` 或目录 `after/ftplugin/` 下多文件。

## 网络大神总结

> **Neovim 文档（:h usr_41 / ftplugin 设计）**：ftplugin 是 Vim 几十年来的官方机制——"**按文件类型拆分配置，且用局部选项避免互相污染**"。这是把配置"模块化到每个语言"的最正统方式，插件和用户都该遵守。

> **echasnovski（mini.nvim 作者）**：`after/ftplugin/markdown.lua` 里 `vim.b.minisurround_config` 演示了 mini 的"**buffer 局部配置**"能力（`:h mini.nvim-buffer-local-config`）——同一模块在不同文件类型可以有不同行为，这是比"全局一套配置"更精细的用法。

## 延伸阅读
- `:h ftplugin` · `:h after-directory` · `:h filetype`
- `:h 'rtp'`（runtimepath 加载顺序）
- `:h mini.nvim-buffer-local-config`

## 自测
- ☐ 能为自己的语言写一个 ftplugin 且验证 buffer 局部生效
- ☐ 能解释 `after/` 相对 `plugin/` 的加载顺序意义
- ☐ 能复述 ftplugin 里"必须用局部选项"的原因
