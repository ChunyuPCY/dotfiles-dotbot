# Neovim 学习计划 · 总览

> 目标：通过**改这个仓库本身**，真正掌握 Neovim 0.12 的配置与高效使用。
> 教材：本仓库的代码（`init.lua` + `plugin/` + `after/` + `snippets/`）+ Neovim 内置 help（`<Space>fh` 查）+ 每篇文末的"网络大神总结"。
> 核心原则：**没有输出就没有底气**。每课 = 读代码 → 动手改 → 用命令验证输出，绝不"改完就算了"。

---

## 学习路径图

```
Phase 1  Lua + Neovim API 基础（先会"说话"）          → 01 ~ 06
Phase 2  逐文件通读现有配置（搞懂"这套配置在干嘛"）     → 07 ~ 11
Phase 3  动手定制（每课落一个真实需求）                 → 12 ~ 18
Phase 4  工作流熟练（练成肌肉记忆）                     → 19
Phase 5  进阶（按需，走向独立配置能力）                 → 20 ~ 23
```

| 序号 | 文件 | 课时 | 主题 |
|---|---|---|---|
| 00 | [00-overview.md](00-overview.md) | — | 总览 + 反馈环路 + 进度表 |
| 01 | [01-lua-variables.md](01-lua-variables.md) | L1.1 | 变量、类型、表 |
| 02 | [02-lua-functions.md](02-lua-functions.md) | L1.2 | 函数、闭包、控制流 |
| 03 | [03-options-scopes.md](03-options-scopes.md) | L1.3 | vim.o/bo/wo/g/opt 作用域 |
| 04 | [04-vim-api.md](04-vim-api.md) | L1.4 | vim.api 常用函数 |
| 05 | [05-keymap.md](05-keymap.md) | L1.5 | vim.keymap.set |
| 06 | [06-vim-cmd-fn.md](06-vim-cmd-fn.md) | L1.6 | vim.cmd 与 vim.fn |
| 07 | [07-init-flow.md](07-init-flow.md) | L2.1 | init.lua 启动流程 |
| 08 | [08-options-deep-read.md](08-options-deep-read.md) | L2.2 | options 逐项精读 |
| 09 | [09-keymaps-deep-read.md](09-keymaps-deep-read.md) | L2.3 | keymaps 逐项精读 |
| 10 | [10-mini-modules.md](10-mini-modules.md) | L2.4 | mini.nvim 模块地图 |
| 11 | [11-plugins-lsp-treesitter.md](11-plugins-lsp-treesitter.md) | L2.5 | treesitter/LSP/formatter |
| 12 | [12-custom-options.md](12-custom-options.md) | L3.1 | 自定义选项 |
| 13 | [13-custom-keymaps.md](13-custom-keymaps.md) | L3.2 | 自定义 Leader 映射 |
| 14 | [14-custom-autocmd.md](14-custom-autocmd.md) | L3.3 | 自定义 autocommand |
| 15 | [15-lsp-language.md](15-lsp-language.md) | L3.4 | 接入你的语言 LSP |
| 16 | [16-formatter.md](16-formatter.md) | L3.5 | conform 格式化 |
| 17 | [17-lint-diagnostics.md](17-lint-diagnostics.md) | L3.6 | lint + 诊断 |
| 18 | [18-treesitter-extend.md](18-treesitter-extend.md) | L3.7 | treesitter 扩展 |
| 19 | [19-workflow.md](19-workflow.md) | L4 | 工作流练习 |
| 20 | [20-ftplugin.md](20-ftplugin.md) | L5.1 | after/ 与 ftplugin |
| 21 | [21-vim-lsp-advanced.md](21-vim-lsp-advanced.md) | L5.2 | vim.lsp 深度 |
| 22 | [22-performance.md](22-performance.md) | L5.3 | 性能调优 |
| 23 | [23-write-module.md](23-write-module.md) | L5.4 | 写自己的模块 |

---

## 反馈环路（先读，最重要）

任何修改后，按顺序走一遍，保证每步都有看得见的输出：

```bash
# 1) 语法/加载自检（终端跑，无输出即通过）
nvim --headless "+lua print('config OK')" +qa

# 2) 让改动生效
:source %                 # 在配置文件里重载当前文件
# 或直接重启 nvim（很多插件配置必须重启）
```

| 验证什么 | 命令（nvim 内） | 看到什么 |
|---|---|---|
| 选项当前值 + 来源 | `:verbose set number?` | 值 + 定义在哪个文件第几行 |
| 选项完整信息 | `:lua =vim.api.nvim_get_option_info('number')` | 信息表 |
| 映射是否存在 | `:verbose nmap <Leader>ff` | 触发方式 + 定义位置 |
| 全部 Leader 映射 | `:map <Leader>` | 映射列表 |
| autocommand 是否注册 | `:autocmd custom-config` | 组内所有 autocmd |
| 立即看表达式结果 | `:=vim.o.mouse` / `:=1+1` | 结果直接显示 |
| 结构化打印任意 Lua 值 | `:lua print(vim.inspect(vim.o))` | 缩进排版的表 |
| 插件是否加载 | `:lua print(package.loaded['mini.pick'] ~= nil)` | `true`/`false` |
| mini 模块实际配置 | `:lua print(vim.inspect(require('mini.pick').config))` | 生效的配置表 |
| LSP 客户端 | `:lua =vim.lsp.get_clients()` | 服务器名、根目录 |
| 当前 buffer 诊断 | `:lua =vim.diagnostic.get(0)` | 诊断数组 |
| 报错信息 | `:messages` | 最近报错堆栈 |
| 组件健康检查 | `:checkhealth vim.lsp nvim-treesitter` | 绿/黄/红 |

**习惯**：改一处 → 验证一处。本仓库是 git 仓库，改动后 `git diff` 对比、`git checkout -- <文件>` 还原，这是你的安全网。

---

## 进度追踪表

| 课时 | 主题 | 完成 | 备注 |
|---|---|---|---|
| L1.1–L1.6 | Lua + API 基础 | ☐ | |
| L2.1 | init.lua 流程 | ☐ | |
| L2.2 | options 逐项 | ☐ | |
| L2.3 | keymaps 逐项 | ☐ | |
| L2.4 | mini 模块 | ☐ | |
| L2.5 | treesitter/LSP/formatter | ☐ | |
| L3.1–L3.7 | 动手定制 | ☐ | 每课一个真实需求 |
| L4 | 工作流 | ☐ | 持续练习 |
| L5 | 进阶 | ☐ | 按需 |

---

## 常用自检命令（贴最顺手处）

```bash
nvim --headless "+lua print('config OK')" +qa   # 配置加载自检
```

```lua
-- nvim 内
:checkhealth                              -- 总体检
:checkhealth vim.lsp nvim-treesitter      -- 指定组件
:lua =vim.o                              -- 所有选项
:lua =vim.lsp.get_clients()              -- LSP 状态
:lua =vim.diagnostic.get(0)              -- 当前文件诊断
:verbose set <opt>?                       -- 选项来源
:verbose nmap <Leader>xx                  -- 映射来源
:autocmd custom-config                    -- autocmd 列表
:messages                                  -- 看报错
```
