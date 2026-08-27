# L2.4 · mini.nvim 模块地图（plugin/30_mini.lua）

## 目标
理解 mini.nvim 的"一个插件、多个模块"设计，能说出每个模块"干什么、怎么触发"，并亲手启用一个被注释掉的模块。

## 前置
- L2.1–L2.3 完成。

## 核心概念

mini.nvim 是一个**单一插件**，内含几十个独立模块，各自 `require('mini.xxx').setup()` 启用。启用后通常生成一个全局 `MiniXxx` 表，供后续调用（如映射里的 `MiniBufremove.delete()`）。

### 设计要点
- **模块独立**：用哪个 `setup` 哪个，不用就不加载（配 `later()` 懒加载）。
- **`setup(config)` 只接受一个表**：默认值已够好，多数模块甚至直接 `setup()` 空参。
- **两段加载**（`30_mini.lua:23`）：Step one 用 `now()` 保证首屏所需；其余 `later()`。

### 模块速查表（对照文件逐个看注释）
| 模块 | 用途 | 触发示例 |
|---|---|---|
| mini.basics | 通用映射/选项/autocmd 集合 | `<C-s>` 保存、`\w` 折行 |
| mini.icons | 图标提供者 | 被 pick/files 等自动用 |
| mini.notify | 通知 | `:lua vim.notify('hi')`、`<Space>en` 历史 |
| mini.sessions | 会话 | `<Space>sn/sr/sw` |
| mini.starter | 启动屏 | 直接 `nvim` 打开时 |
| mini.statusline/tabline | 状态栏/标签栏 | 界面底部/顶部 |
| mini.completion | 两阶段补全 | `<Tab>` 选补全 |
| mini.files | 文件浏览（Miller 列） | `<Space>ed` |
| mini.misc | 杂项（cwd/光标恢复） | `<Space>oz` 缩放 |
| mini.extra | 额外 picker | `<Space>f` 家族 |
| mini.ai | a/i 文本对象 | `ci)` `di(` `yaq` |
| mini.align | 对齐 | `gaip,` |
| mini.bracketed | `[`/`]` 前后跳 | `]b` `[b` |
| mini.bufremove | 删 buffer | `<Space>bd/bw` |
| mini.clue | 按键提示 | 按住 `<Space>` |
| mini.cmdline | 命令行增强 | `:` 自动补全 |
| mini.comment | 注释 | `gcip` `gc` |
| mini.diff | git diff 高亮/操作 | `<Space>go` |
| mini.git | git 集成 | `<Space>gs` |
| mini.hipatterns | 高亮模式 | TODO/十六进制色 |
| mini.indentscope | 缩进作用域 | `cii` |
| mini.input | 输入浮窗 | LSP rename 输入 |
| mini.jump/jump2d | 跳转 | `fxff` |
| mini.keymap | 多步/组合映射 | `<CR>`/`<BS>` 智能行为 |
| mini.map | 代码缩略图 | `<Space>mt` |
| mini.move | 移动选中 | `<M-j/k/h/l>` |
| mini.operators | 文本运算符 | `griw` `g==` |
| mini.pairs | 自动配对 | `(` 自动 `()` |
| mini.pick | 统一 picker | `<Space>ff` |
| mini.snippets | 片段 | `<C-j>` 展开 |
| mini.splitjoin | 参数分合 | `gS` |
| mini.surround | 环绕 | `sa` `sd` `sr` |
| mini.trailspace | 尾随空格 | `<Space>ot` |
| mini.visits | 访问追踪 | `<Space>fv` |

## 动手实操
1. 打开 `plugin/30_mini.lua`，找一个被注释的模块，例如 `mini.animate`（`30_mini.lua:364`）或 `mini.cursorword`（`30_mini.lua:479`）。
2. 用 `gcc` 取消注释（`:h commenting`）：
   ```lua
   later(function() require('mini.animate').setup() end)
   ```
3. 重启 nvim，移动光标 → 应看到动画。
4. 验证模块已加载：`:lua print(package.loaded['mini.animate'] ~= nil)` → `true`。

## 验证反馈
| 命令 | 期望输出 |
|---|---|
| `:lua =vim.inspect(require('mini.pick').config)` | mini.pick 实际配置 |
| `:lua print(package.loaded['mini.animate'] ~= nil)` | `true`（启用后） |
| `:h mini.nvim` | 全模块总览文档 |

## 常见坑
- **模块名 vs 全局表名**：`require('mini.pick')` 的模块名是 `mini.pick`，全局表是 `MiniPick`（驼峰）。别混。
- **`later` 里的模块不能立即用**：首屏前若调用 `MiniXxx` 会报 nil，所以映射都用 `<Cmd>` 懒触发。
- **禁用 vs 不启用**：没 `setup()` 的模块只是没副作用，`require` 它仍是安全的（会返回模块表）。

## 网络大神总结

> **echasnovski（mini.nvim 作者）**：mini 的设计哲学是"**少而精、独立、开箱即用**"（minimal, independent, works out of the box）。他主张**用几个深度集成的模块，而不是十几个互相打架的插件**——单一作者维护意味着接口统一、冲突少。这也是 MiniMax 这个"全 mini"配置成立的底气。

> **Folke（lazy.nvim 作者）**：mini.nvim 的模块化其实和 lazy.nvim 的"按需加载"殊途同归，但侧重点不同——**Folke 解决"何时加载"，echasnovski 解决"加载什么"**。二者结合（本仓库正是这样：vim.pack 管加载，mini 管功能）是当下最清爽的组合之一。

## 延伸阅读
- `:h mini.nvim` · `:h mini.nvim-general-principles`
- `:h mini.pick` · `:h mini.files`（最常用的两个）

## 自测
- ☐ 能说出 5 个你最常用模块的触发方式
- ☐ 能解释 `later()` 里为何不能立即用 `MiniXxx`
- ☐ 成功启用一个被注释的模块并验证
