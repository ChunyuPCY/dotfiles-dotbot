# L1.6 · vim.cmd 与 vim.fn

## 目标
掌握 `vim.cmd`（执行 Ex/Vimscript 命令）和 `vim.fn`（调用 Vimscript 函数），能读懂并写出混用 Lua 与 Vimscript 的代码。这是"Lua 配置与古老 Vim 世界"的桥梁。

## 前置
- L1.1–L1.5 完成。

## 核心概念

Neovim 同时支持 Lua 与 Vimscript，两者通过 `vim.cmd` / `vim.fn` 互操作。

### 1. vim.cmd：执行 Ex 命令
```lua
vim.cmd('set number')
vim.cmd('colorscheme catppuccin')
vim.cmd('normal! gg')                    -- 执行 normal 模式按键
vim.cmd[[ normal! gg ]]                  -- 长字符串用 [[ ]] 更清晰
```
也支持块式多行：
```lua
vim.cmd([[
  set number
  hi NormalFloat guibg=NONE
]])
```
`plugin/30_mini.lua:38` 就是 `vim.cmd('colorscheme catppuccin')`。

### 2. vim.fn：调用 Vimscript 函数
```lua
print(vim.fn.getcwd())                   -- 当前工作目录
print(vim.fn.expand('%:t'))              -- 当前文件名（去路径）
print(vim.fn.stdpath('config'))          -- 配置目录路径
print(vim.fn.argc(-1))                   -- 启动参数个数
```
`init.lua:121` 用了 `vim.fn.argc(-1)`；`plugin/20_keymaps.lua:101` 用了 `vim.fn.stdpath('config')`。

### 3. 为什么还需要它们
很多历史功能只有 Vimscript 版本，用 `vim.fn` 能直接复用；`vim.cmd` 则用来执行 `:set`、`:colorscheme`、`:edit` 等 Ex 命令（有些还没有 Lua 等价物）。

## 动手实操
1. 依次执行并观察：
   ```
   :lua print(vim.fn.getcwd())
   :lua print(vim.fn.stdpath('config'))
   :lua vim.cmd('normal! gg')
   :lua print(vim.fn.expand('%:t'))
   ```
2. 试试 `vim.cmd` 执行多行：
   ```
   :lua vim.cmd([[ set number
                   \ set wrap ]])
   ```
   （注意：行尾 `\` 是 Vimscript 的续行符）

3. 在 `init.lua` 里找 `vim.fn.argc` 和 `vim.fn.stdpath`，读它们的上下文（`init.lua:121`、`plugin/20_keymaps.lua:101`）。

## 验证反馈
| 命令 | 期望输出 |
|---|---|
| `:lua =vim.fn.getcwd()` | 当前目录字符串 |
| `:lua =vim.fn.stdpath('config')` | 配置目录（本仓库路径） |
| `:lua vim.cmd('normal! gg')` | 光标跳到首行 |

## 常见坑
- **`vim.fn` 需要 `vim.fn.expand` 而非裸 `expand`**：Vimscript 函数要通过 `vim.fn` 前缀访问。
- **`vim.cmd` 里的特殊字符**：`%` 等要转义或用 `vim.fn.expand` 先算好再拼字符串。
- **`normal!` 带 `!`**：`!` 表示"忽略用户自定义映射"，几乎总是要加 `!`，否则可能触发映射导致意外。

## 网络大神总结

> **Neovim 团队（:h lua-guide 定位）**：Neovim 的官方立场是"Lua 是一等配置语言，但 Vimscript 不会消失"。所以 `vim.cmd`/`vim.fn` 不是"旧写法"，而是**必要的桥**——能用 Lua 就用 Lua，缺了就调 `vim.fn`，需要 Ex 命令就 `vim.cmd`。混用不是耻辱，是务实。

> **echasnovski（mini.nvim 作者）**：mini.nvim 内部大量用 `vim.fn`（如 `vim.fn.winheight`）来复用 Vim 几十年的既有实现——"重新发明 Vim 已经有的东西，既不聪明也不快"。

## 延伸阅读
- `:h vim.cmd()` · `:h vim.fn` · `:h lua-vimscript`
- `:h :normal`（`normal!` 的 `!`）

## 自测
- ☐ 能用 `vim.fn.expand('%:t')` 取当前文件名
- ☐ 能用 `vim.cmd` 执行一条 `:set` 和一条 `:colorscheme`
- ☐ 能解释 `normal!` 里 `!` 的作用

---

## Phase 1 收尾自测
完成 01~06 后，检查是否达到 Phase 1 通过标准：

> **不看资料，独立写出"创建一个临时 buffer 并写入 3 行文本"的完整 `:lua` 命令。**

若能写出并解释其中 `vim.api`、`vim.cmd`、函数、表 各扮演的角色，Phase 1 即通过，进入 Phase 2。
