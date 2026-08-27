# L1.4 · vim.api 常用函数

## 目标
掌握最常用的 `vim.api.nvim_*` 函数（buffer/窗口/行操作），能独立写出"创建临时 buffer 并写入文本"的命令。这是所有插件背后真正在调用的底层接口。

## 前置
- L1.1–L1.3 完成。

## 核心概念

`vim.api` 是 Neovim 的 RPC API，几乎一切底层操作都走它。常用族：

### 1. Buffer
```lua
local buf = vim.api.nvim_create_buf(true, true)   -- (listed, scratch)
vim.api.nvim_buf_set_lines(buf, 0, -1, false, {'a', 'b'})  -- 写入行
vim.api.nvim_buf_get_lines(buf, 0, -1, false)     -- 读取行（返回数组）
vim.api.nvim_get_current_buf()                     -- 当前 buffer 句柄
```
`plugin/20_keymaps.lua:85` 的 `new_scratch_buffer` 就用了这套：
```lua
local new_scratch_buffer = function()
  vim.api.nvim_win_set_buf(0, vim.api.nvim_create_buf(true, true))
end
```

### 2. 窗口与光标
```lua
vim.api.nvim_win_set_buf(0, buf)         -- 把当前窗口(0)切到 buf
vim.api.nvim_set_current_line('hello')   -- 替换当前行文本
vim.api.nvim_win_get_cursor(0)           -- 返回 {行, 列}（1-based）
vim.api.nvim_win_set_cursor(0, {1, 0})
```

### 3. 高亮（配置里很常见，见 30_mini.lua:55）
```lua
vim.api.nvim_set_hl(0, 'ColorColumn', { bg = 'NONE' })  -- 改高亮组
vim.api.nvim_get_hl(0, { name = 'NormalFloat', link = false })
```

### 4. 常用简写
- `0` = 当前 buffer/窗口（约定俗成）。
- `vim.api` 之外的常用入口还有 `vim.cmd`（执行 Ex 命令）、`vim.fn`（调 Vimscript 函数）、`vim.keymap`、`vim.diagnostic`、`vim.lsp`、`vim.treesitter`。

## 动手实操
1. 依次执行：
   ```
   :lua vim.api.nvim_set_current_line('hello api')
   :lua vim.api.nvim_set_current_line(vim.api.nvim_get_current_line() .. '!')
   ```
   → 当前行先变 `hello api` 再变 `hello api!`

2. 创建一个 scratch buffer 并写 3 行：
   ```
   :lua local b = vim.api.nvim_create_buf(true, true) vim.api.nvim_buf_set_lines(b, 0, -1, false, {'one','two','three'})
   ```
   然后 `:lua vim.api.nvim_win_set_buf(0, b)` → 窗口跳到该 buffer，显示三行。

3. 验证 buffer 列表：`:ls` 能看到新 buffer（scratch 是 unlisted 可能不显示；改用 `listed=true` 试试：`:lua vim.api.nvim_create_buf(true, false)`）。

## 验证反馈
| 命令 | 期望输出 |
|---|---|
| `:lua =vim.api.nvim_get_current_line()` | 当前行文本 |
| `:lua =vim.api.nvim_buf_get_lines(0, 0, -1, false)` | 当前 buffer 全部行（数组） |
| `:lua =vim.api.nvim_win_get_cursor(0)` | `{ 行, 列 }` |

## 常见坑
- **索引 base**：`nvim_buf_set_lines` 的起止行是 0-based 且 `-1` 表"末尾"；但 `nvim_win_get_cursor` 返回的是 1-based。两套索引混用最易出错。
- **scratch 参数**：`nvim_create_buf(listed, scratch)`，`listed=false` 的 buffer 不出现在 `:ls`，但不等于不存在。
- **必须先有 buffer 才能写行**：对无效 buffer 句柄操作会报错，可先 `nvim_create_buf`。

## 网络大神总结

> **TJ DeVries（Neovim 核心贡献者）**：`vim.api` 是"编辑器的一切都可用代码操作"的入口。他反复强调：**学会 `nvim_create_buf`/`nvim_buf_set_lines` 这几个函数，你就能自己写插件**——因为插件本质上就是"创建 buffer + 写行 + 设置窗口"的组合。理解了 api，就理解了整个插件生态的底座。

## 延伸阅读
- `:h api` · `:h api-index`（全量函数速查）
- `:h nvim_create_buf` · `:h nvim_buf_set_lines` · `:h nvim_set_hl`

## 自测
- ☐ 不看资料写出"创建 buffer + 写 3 行 + 切过去"的命令
- ☐ 能说出 `0` 在 api 里代表什么
- ☐ 能区分 `nvim_buf_set_lines` 与 `nvim_win_get_cursor` 的索引 base
