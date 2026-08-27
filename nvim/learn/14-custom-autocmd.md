# L3.3 · 自定义 autocommand

## 目标
用 `Config.new_autocmd` 写一个自己的 autocommand，理解事件（event）/模式（pattern）/回调（callback），并会用 `:autocmd custom-config` 验证。

## 前置
- L2.1（`new_autocmd` 原理）、L1.2（闭包）完成。

## 核心概念回顾
```lua
Config.new_autocmd(event, pattern, callback, desc)
```
- `event`：触发事件，如 `FileType`、`BufWritePost`、`LspAttach`（`:h autocmd-events`）。
- `pattern`：匹配目标，如文件类型字符串、文件通配符，或 `nil`（全部）。
- `callback`：Lua 函数，可接收一个 `ev` 参数（`ev.buf` 等）。
- 所有 autocmd 进 `custom-config` 组。

## 需求
实现"打开 Lua 文件时自动禁用鼠标"（演示 `FileType` 事件 + buffer-local 修改）。真实场景你可能会换成"打开某种文件时设 wrap / 设 spell"。

## 动手实操
在 `plugin/10_options.lua` 的 "Autocommands" 段（`10_options.lua:92`）加：
```lua
Config.new_autocmd('FileType', 'lua', function()
  vim.bo.mouse = ''
end, 'Disable mouse for Lua')
```

保存 `:source %`（注意：autocmd 若重复 source 会重复注册，最好重启 nvim 验证）。

**验证**：打开任意 `.lua` 文件 → 鼠标点击/滚轮失效；打开 `.md` 文件 → 鼠标正常。`:autocmd custom-config` 能看到这条。

## 验证反馈
| 命令 | 期望输出 |
|---|---|
| `:autocmd custom-config` | 含 "Disable mouse for Lua" |
| 打开 lua 文件 | 鼠标失效 |
| 打开非 lua 文件 | 鼠标正常 |

## 常见坑
- **重复注册**：`plugin/*.lua` 每次启动 source 一次，不会重复；但你在运行中多次 `:source %` 会叠加。autocmd 可用 `nvim_del_autocmd` 清理，或直接重启验证。
- **`FileType` 的 pattern 是文件类型名**，不是文件名：`'lua'` 匹配 `filetype=lua`。
- **buffer-local 选项用 `vim.bo`**：autocmd 里改当前 buffer 用 `vim.bo`（等价 `vim.bo[0]`），不是 `vim.o`（会改全局默认）。

## 网络大神总结

> **echasnovski（mini.nvim 作者）**：`FileType` 事件 + buffer-local 选项是"**按文件类型定制**"的标准范式（`after/ftplugin/` 就是它的文件化形态）。他建议：能用 `ftplugin` 就别用散落的 autocmd——但理解 autocmd 是理解一切插件行为的钥匙。

> **TJ DeVries**：autocmd 是 Neovim 的"事件驱动"核心，`LspAttach`/`FileType`/`User` 是最常用的三个。**理解 autocmd 的生命周期，就等于理解了插件何时、为何运行。**

## 延伸阅读
- `:h autocommand` · `:h autocmd-events` · `:h nvim_create_autocmd`
- `:h ftplugin`（FileType 事件的文件化版本）

## 自测
- ☐ 能用 `:autocmd custom-config` 看到自己的 autocmd
- ☐ 能解释 `pattern='lua'` 匹配的是什么
- ☐ 能说出 autocmd 与 ftplugin 的关系
