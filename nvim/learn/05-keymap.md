# L1.5 · vim.keymap.set

## 目标
掌握 `vim.keymap.set`（0.7+ 的标准映射 API），能独立加一条带 `desc` 的映射，并用 `:verbose nmap` 验证。

## 前置
- L1.1–L1.4 完成。
- 对照 `plugin/20_keymaps.lua` 顶部的 `nmap` 帮助函数。

## 核心概念

`vim.keymap.set(mode, lhs, rhs, opts)` 是取代旧 `vim.api.nvim_set_keymap` 的新标准：
- `mode`：模式字符串，如 `'n'`(normal)、`'i'`(insert)、`'v'/'x'`(visual)、`'t'`(terminal)。
- `lhs`：左键（你要按的键），如 `'<Leader>xx'`。
- `rhs`：右键（触发的东西），可以是**字符串**（Ex 命令/Vimscript）或 **Lua 函数**。
- `opts`：选项表，最常用 `desc`（描述，给 mini.clue/which-key 用）、`buffer`（限定 buffer）、`remap`、`silent`。

### 三种 rhs 写法（都能在本仓库看到）
```lua
-- 1) 字符串 RHS：延迟到执行时才解析，适合"懒加载"（见 20_keymaps.lua:73 注释）
vim.keymap.set('n', '<Leader>ff', '<Cmd>Pick files<CR>', { desc = 'Files' })

-- 2) 函数 RHS：直接调用 Lua 函数（见 20_keymaps.lua:91）
local new_scratch_buffer = function()
  vim.api.nvim_win_set_buf(0, vim.api.nvim_create_buf(true, true))
end
vim.keymap.set('n', '<Leader>bs', new_scratch_buffer, { desc = 'Scratch' })

-- 3) 字符串拼接 + 函数工厂（见 20_keymaps.lua:100）
local edit_plugin_file = function(filename)
  return string.format('<Cmd>edit %s/plugin/%s<CR>', vim.fn.stdpath('config'), filename)
end
```

### `<Cmd>` 与 `<CR>`（必懂）
`<Cmd>Pick files<CR>` 里的 `<Cmd>` 表示"不切模式，直接在命令行执行命令"，`<CR>` 是回车。好处：不打断当前模式、不依赖目标函数已加载（懒加载关键）。

## 动手实操
1. 在 `plugin/20_keymaps.lua` 顶部（`local nmap` 定义之后）加：
   ```lua
   vim.keymap.set('n', '<Leader>xx', function()
     print('hello, ' .. vim.fn.expand('%:t'))
   end, { desc = 'Test feedback' })
   ```
2. 保存 `:source %`，按 `<Space>xx` → 命令行打印 `hello, <当前文件名>`。
3. 查证：`:verbose nmap <Leader>xx` → 显示触发方式 + desc + 定义在哪个文件。

## 验证反馈
| 命令 | 期望输出 |
|---|---|
| `:verbose nmap <Leader>xx` | 映射详情 + 定义位置 |
| `:map <Leader>` | 所有 Leader 映射（应含你的 xx） |
| 按 `<Space>` 等 1 秒 | mini.clue 弹出（含 xx 的 desc） |

## 常见坑
- **忘记 `desc`**：无 `desc` 的映射不会出现在 mini.clue 提示里，等于"看不见自己配了什么"。
- **`<Leader>` 要等已定义**：`mapleader` 在 `plugin/10_options.lua` 里才设成空格，映射文件加载顺序必须在其后（本仓库 10 → 20 正好）。
- **`remap` 默认 false**：字符串 RHS 里的键不会被二次展开（除非显式 `remap = true`，见 `20_keymaps.lua:683` 的括号交换映射）。

## 网络大神总结

> **TJ DeVries（nvim-lua-guide 作者）**：`vim.keymap.set` 相比旧 API 最大的进步是把 `desc` 变成一等公民——**描述不是给机器看的，是给未来的你自己看的**。配合 which-key/mini.clue，你的按键体系会自己"教"你。

> **ThePrimeagen**：映射要遵循"动词-对象"（verb-object）的可组合思想——先学会 Vim 内建动词，再用 `<Leader>` 映射补充工作流，而不是把每个动作都绑成一个孤立快捷键。

## 延伸阅读
- `:h vim.keymap.set()` · `:h map-modes` · `:h key-notation`（键记法）
- `:h <Cmd>` · `:h <CR>`

## 自测
- ☐ 能写字符串 RHS 和函数 RHS 两种映射
- ☐ 能解释 `<Cmd>` 相比 `:` 的好处
- ☐ 能用 `:verbose nmap` 定位任意映射来源
