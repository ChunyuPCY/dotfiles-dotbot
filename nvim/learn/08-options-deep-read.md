# L2.2 · options 逐项精读（plugin/10_options.lua）

## 目标
把 `plugin/10_options.lua` 每一行都过一遍，每个 `vim.o.xxx` 都用 `:h 'xxx'` 查含义，并能用 `:verbose set` 反查。目标是"每个选项都知道它改了什么、为什么改"。

## 前置
- L2.1 完成，已懂 `vim.o/vim.opt` 作用域（L1.3）。

## 精读方法（重要，贯穿 Phase 2）
不要死记，用"改 → 看效果 → 还原"三连：
1. 打开 `plugin/10_options.lua`（`<Space>eo`）。
2. 挑一个选项，`<Space>fh` 查 `:h 'xxx'`。
3. 用 `:lua vim.o.xxx = 新值` 临时改，观察屏幕/行为变化。
4. 确认理解后 `git checkout -- plugin/10_options.lua` 还原（或不还原，因为这只是 `:lua` 临时改，重启即还原）。

## 逐块导读

### General（全局）
```lua
vim.g.mapleader = ' '      -- <Space> 作 Leader（:h mapleader）
vim.o.mouse = 'a'          -- 鼠标全模式启用（:h 'mouse'）
vim.o.undofile = true      -- 持久化 undo，重启后还能撤销（:h 'undofile'）
vim.o.shada = "'100,<50,..." -- ShaDa 文件大小限制（:h 'shada'）
```
**重点验证**：`:verbose set mouse?` 看值；关掉鼠标 `:lua vim.o.mouse = ''` 看鼠标失灵，再改回 `'a'`。

### UI（界面）
```lua
vim.o.number = true        -- 行号（:h 'number'）
vim.o.relativenumber?      -- 注意：本仓库用的是 number，没开相对行号
vim.o.cursorline = true    -- 高亮当前行（:h 'cursorline'）
vim.o.signcolumn = 'yes'   -- 常显符号列，防闪（:h 'signcolumn'）
vim.o.wrap = false         -- 不自动折行（:h 'wrap'）
vim.o.fillchars / listchars -- 显示特殊符号（:h 'listchars'）
```
**重点验证**：`set list!` 切换看 `listchars` 效果（tab 显示 `> `）；`:verbose set cursorline?` 看来源。

### Folds（折叠）
```lua
vim.o.foldmethod = 'indent'  -- 按缩进折叠（:h 'foldmethod'）
vim.o.foldlevel = 10         -- 默认不折叠（:h 'foldlevel'）
```
**重点验证**：`:lua vim.o.foldlevel = 1` 看代码折叠；`zM` 全折叠、`zR` 全展开（`:h fold-commands`）。

### Editing（编辑）
```lua
vim.o.expandtab = true     -- Tab 转空格（:h 'expandtab'）
vim.o.shiftwidth = 2       -- 缩进 2 空格（:h 'shiftwidth'）
vim.o.tabstop = 2          -- Tab 显示宽度（:h 'tabstop'）
vim.o.ignorecase/smartcase -- 搜索忽略大小写 + 大写则区分（:h 'smartcase'）
vim.o.incsearch = true     -- 边输边搜（:h 'incsearch'）
```
**重点验证**：`/Foo` vs `/foo` 体会 smartcase；`:set ignorecase` 后搜索。

### 诊断（vim.diagnostic，本文件最后一段）
```lua
Config.later(function() vim.diagnostic.config(diagnostic_opts) end)
```
用的是 `later()` 延迟加载，避免启动时 source `vim.diagnostic`。**重点验证**：`:lua =vim.diagnostic.config()` 看当前诊断配置。

## 动手实操
挑 5 个你日常最相关、但还没搞懂的选项，走完整"改→看→查→还原"流程，例如：
1. `wrap`（折行）
2. `scrolloff`（光标距边缘留白，本仓库设了 10）
3. `foldmethod`/`foldlevel`
4. `ignorecase`/`smartcase`
5. `listchars`（用 `set list!` 看）

## 验证反馈
| 命令 | 期望输出 |
|---|---|
| `:verbose set scrolloff?` | `scrolloff=10` + 定义位置 |
| `:lua =vim.diagnostic.config()` | 诊断配置表 |
| `:set list!` | 显示/隐藏特殊符号 |

## 常见坑
- **`wrap` 与 `breakindent` 配合**：`wrap=false` 时 `breakindent` 看似无意义，但文件里两者都设了，因为有的 buffer 会局部开 wrap（见 `after/ftplugin/markdown.lua`）。
- **`shada` 是启动期选项**：改了要在 `init.lua` 底部设（见文件头注释），否则 source 太晚不生效。
- **选项 vs 插件**：本仓库把 `mini.basics` 的 `options.basic = false`（`30_mini.lua:90`），就是故意把选项管理留在本文件，避免插件悄悄改选项。

## 网络大神总结

> **Folke（lazy.nvim 作者）**：他的一句话广为流传——**"默认值大多是好的，只改你真正需要的"**。配置不是比赛谁 `vim.o` 写得多，而是把少数几个"改变了你工作流"的选项挑出来。

> **echasnovski（mini.nvim 作者）**：MiniMax 里 "Manage options ... for didactic purposes" 这句注释是刻意的：**把选项显式写出来，是学习 Neovim 最好的方式**——每个 `vim.o.xxx` 都是一次 `:h 'xxx'` 的索引。

## 延伸阅读
- `:h option-list`（全量选项 + 作用域）
- `:h 'shada'` · `:h 'foldmethod'` · `:h 'listchars'` · `:h 'smartcase'`

## 自测
- ☐ 能解释 `tabstop` / `shiftwidth` / `expandtab` 三者的区别
- ☐ 能用 `:verbose set` 定位任意选项来源
- ☐ 能复述本文件为何把 `vim.diagnostic.config` 放 `later`
