# L1.3 · 选项作用域：vim.o / vim.bo / vim.wo / vim.g / vim.opt

## 目标
搞懂 Neovim 选项的三种作用域（全局 / 缓冲区 / 窗口），能正确选用 `vim.o/bo/wo/g/opt`，并会用 `:verbose set` 反查选项来源。

## 前置
- L1.1、L1.2 完成。
- 打开 `plugin/10_options.lua` 对照阅读。

## 核心概念

Neovim 的选项分三类作用域：
- **global**：全局，影响整个实例。
- **buffer-local**：每个缓冲区一份。
- **window-local**：每个窗口一份。

对应访问器：

| 访问器 | 作用域 | 示例 |
|---|---|---|
| `vim.o.xxx` | 全局（buffer 选项会写全局默认） | `vim.o.number = true` |
| `vim.bo[buf].xxx` | 缓冲区，`buf=0` 表当前 | `vim.bo[0].expandtab = false` |
| `vim.wo[win].xxx` | 窗口，`win=0` 表当前 | `vim.wo[0].wrap = true` |
| `vim.g.xxx` | 全局**变量**（不是选项，是存数据） | `vim.g.mapleader = ' '` |
| `vim.b.xxx` | 缓冲区变量 | `vim.b.minisurround_config` |
| `vim.opt.xxx` | 万能，支持赋值列表/表 | `vim.opt.listchars = { tab = '> ' }` |

关键区别：
- `vim.o/bo/wo` 是**点号访问单值**，读一个、写一个。
- `vim.opt` 是**支持列表赋值**的表接口，适合一次设多个值。`plugin/10_options.lua` 里就是 `vim.opt` 或 `vim.o` 两种写法。
- `vim.g`（还有 `vim.b`、`vim.w`）存的是**变量**，不是 `:set` 选项。所以 `vim.g.mapleader = ' '` 对应 `:let g:mapleader = ' '`，不是 `:set`。

### 每个选项属于哪个作用域？
查 `:h 'number'`，文档开头会标注 `local to window` / `local to buffer` / `global`。例如：
- `'number'` → local to window（所以 `vim.wo` 或 `vim.o` 都能设，但窗口级覆盖）
- `'expandtab'` → local to buffer
- `'undofile'` → global

## 动手实操
逐条在 nvim 里执行并观察：
```
:lua vim.o.number = true
:lua vim.bo[0].expandtab = false
:lua vim.wo[0].wrap = true
:lua vim.g.mapleader = ' '
:lua vim.opt.scrolloff = 5
:lua vim.opt.listchars = { tab = '> ', trail = '·' }
```

## 验证反馈
| 命令 | 期望输出 |
|---|---|
| `:verbose set number?` | 值 + 谁设的（如 `Last set from Lua`） |
| `:lua =vim.bo[0]` | 一张含 `expandtab` 等的表 |
| `:lua =vim.wo[0]` | 一张含 `number`/`wrap` 等的表 |
| `:lua =vim.g` | 含 `mapleader`、`my_test` 等全局变量 |
| `:verbose set listchars?` | `tab=> ,trail=·`（验证列表赋值） |

## 常见坑
- **误把变量当选项**：`vim.g.mapleader = ' '` 不能用 `:set` 查，要用 `:lua =vim.g.mapleader` 或 `:echo g:mapleader`。
- **点号 vs 列表**：`vim.o.listchars = 'tab:> '` 是整体替换字符串；`vim.opt.listchars = { tab = '> ' }` 才是结构化设置。混淆会导致 `listchars` 被覆盖。
- **`vim.bo[0]` 读当前 buffer**：写 `vim.bo[buf]` 时 `buf=0` 是约定俗成的"当前"。

## 网络大神总结

> **echasnovski（mini.nvim 作者）**：`plugin/10_options.lua` 里那句 "Manage options ... for didactic purposes" 点破了 mini.basics 的设计——它本可替你设一堆选项，但**把选项显式写在你能看到的地方，比藏进插件更利于学习和掌控**。这也是 mini 一贯的"显式优于隐式"哲学。

> **Folke（lazy.nvim 作者）**：区分"选项"和"变量"是新手最容易混的地方。他的 LazyVim 里 `opts` 表（变量）和 `vim.opt`（选项）分得极清——**用 `vim.g` 传配置数据给插件，用 `vim.opt` 改编辑器行为**，两者不要混。

## 延伸阅读
- `:h vim.o` · `:h vim.opt`（必读，讲清点号与列表接口）
- `:h option-list`（每个选项的作用域）
- `:h lua-vim-variables`（g/b/w/t/v 变量族）

## 自测
- ☐ 能说出 `vim.o`、`vim.bo`、`vim.wo`、`vim.g` 各自管什么
- ☐ 能判断一个选项是 buffer-local 还是 window-local（靠 `:h`）
- ☐ 会用 `vim.opt` 一次设多个 `listchars`
