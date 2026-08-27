# L2.1 · init.lua 启动流程

## 目标
彻底搞懂 Neovim 的启动加载顺序，以及 `init.lua` 里 5 个核心设计：全局 `Config` 表、`new_autocmd`、`on_packchanged`、`vim.pack.add`、`now/later/now_if_args`。读完你能解释"这个配置是怎么一步步跑起来的"。

## 前置
- Phase 1 完成。
- 用 nvim 打开本仓库：`nvim ~/.dotfiles/nvim`，边读边 `<Space>fh` 查 help。

## 核心概念

### 1. 加载顺序（必背）
Neovim 启动时按固定顺序加载配置（`:h config`）：
```
init.lua                 ← 唯一入口
  └─ plugin/*.lua        ← 自动按文件名排序 source（10_options → 20_keymaps → 30_mini → 40_plugins）
      └─ after/**        ← 最后加载，用于"覆盖"（after/lsp、after/ftplugin、after/snippets）
```
- 数字前缀是为了**控制顺序**：`10_options` 先设选项，`20_keymaps` 才能用 `<Leader>`，`40_plugins` 最后装外部插件。
- `after/` 目录是在所有 `plugin/` 之后加载，专门用来**覆盖**插件/默认行为（见 L5.1）。

### 2. 五个核心概念（逐个能口头解释）

**① `_G.Config = {}`（`init.lua:66`）**
全局配置表。用 `_G.Config` 而不是 `local`，是为了让所有 `plugin/*.lua` 文件（各自有独立作用域）都能共享同一个表。所以你能在 `20_keymaps.lua` 里用 `Config.leader_group_clues`，在 `30_mini.lua` 里用 `Config.now`。
```lua
_G.Config = {}
Config.new_autocmd = function(...) end   -- 之后直接 Config.xxx 访问
```

**② `Config.new_autocmd`（`init.lua:77`）**
把 `nvim_create_augroup` + `nvim_create_autocmd` 包成一个带默认 `group` 的便捷函数。所有本配置的 autocmd 都进 `custom-config` 组，便于统一管理/查看。
```lua
local gr = vim.api.nvim_create_augroup('custom-config', {})
Config.new_autocmd = function(event, pattern, callback, desc)
  local opts = { group = gr, pattern = pattern, callback = callback, desc = desc }
  vim.api.nvim_create_autocmd(event, opts)
end
```

**③ `Config.on_packchanged`（`init.lua:87`）**
vim.pack 插件状态变化（安装/更新/删除）时的钩子包装器（你已逐行问过）。用于"插件更新后自动跑点东西"，如 `40_plugins.lua:43` 在 nvim-treesitter 更新后执行 `:TSUpdate`。

**④ `vim.pack.add`（`init.lua:100`）**
Neovim 0.12 的**内置**插件管理器（`vim.pack`）。`vim.pack.add({ 'url' })` 在"保证已从源码安装"的前提下加载插件，状态记在 `nvim-pack-lock.json`。
```lua
vim.pack.add({ 'https://github.com/nvim-mini/mini.nvim' })
```
相关命令：`:lua vim.pack.update()` 更新、`:lua vim.pack.del({...})` 删除、`:h vim.pack-examples`。

**⑤ `Config.now / later / now_if_args`（`init.lua:119-123`）**
基于 `mini.misc.safely` 的延迟加载助手，是**启动性能优化**的核心：
```lua
local misc = require('mini.misc')
Config.now = function(f) misc.safely('now', f) end           -- 立即执行
Config.later = function(f) misc.safely('later', f) end       -- 首屏渲染后再执行
Config.now_if_args = vim.fn.argc(-1) > 0 and Config.now or Config.later  -- 看是否带文件启动
Config.on_event = function(ev, f) misc.safely('event:' .. ev, f) end
Config.on_filetype = function(ft, f) misc.safely('filetype:' .. ft, f) end
```
- `now`：必须在首屏前执行的（colorscheme、statusline 等）。
- `later`：首屏后才做的（多数 mini 模块），让 `nvim` 尽快出画面。
- `now_if_args`：`nvim file.txt` 打开文件时立刻执行，否则延迟——因为打开文件就需要 tree-sitter/LSP 之类。

## 动手实操
1. 启动后看加载警告：`:messages`。
2. 列出已装插件：`:lua =vim.pack.get_plugins()`（0.12 API）。
3. 确认入口加载成功：`:lua print(Config.now ~= nil and 'init loaded')` → `init loaded`。
4. 追踪来源：`:lua =vim.g.Config ~= nil` → `true`（证明全局表生效）。

## 验证反馈
| 命令 | 期望输出 |
|---|---|
| `:lua =vim.pack.get_plugins()` | 一堆插件的 spec 表 |
| `:autocmd custom-config` | 该组所有 autocmd |
| `:lua =Config.now` | `function` |
| `:lua =Config.later` | `function` |

## 常见坑
- **`Config` 是全局的**：在 `plugin/` 里别用 `local Config` 覆盖它。
- **顺序依赖**：`20_keymaps.lua` 依赖 `10_options.lua` 设的 `<Leader>`，改文件名前缀会破坏顺序。
- **`later` 里别放必须首屏就绪的东西**：否则首屏会闪一下再补上。

## 网络大神总结

> **echasnovski（mini.nvim 作者）**：`now`/`later` 这种"分批加载"是 MiniMax 的精髓——"最小化到首屏的时间"（`minimize the time until first screen draw`）。原则：**只把真正影响第一眼的东西放 `now`，其余一律 `later`**。启动时间不是玄学，是每个 `later` 省出来的。

> **Folke（lazy.nvim 作者）**：lazy.nvim 的 `lazy = true` / `event` / `cmd` / `keys` 其实和这里的 `later`/`on_event`/`on_filetype` 是同一个思想——**按需加载**。他常引用一句话：最快的插件是"没加载的插件"。

## 延伸阅读
- `:h config` · `:h runtimepath`（插件目录如何被找到）
- `:h vim.pack-examples` · `:h vim.pack-events` · `:h vim.pack-lockfile`
- `:h MiniMisc.safely()`

## 自测
- ☐ 能画出"init.lua → plugin/* → after/*"的加载顺序图
- ☐ 能解释为什么 `Config` 用 `_G` 而非 `local`
- ☐ 能解释 `now` 与 `later` 的取舍依据
