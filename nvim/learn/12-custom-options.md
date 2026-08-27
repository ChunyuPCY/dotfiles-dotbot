# L3.1 · 自定义选项

## 目标
第一次真正动手改配置：新增一组自己的选项，并完整走"需求 → 改动 → 自检 → 验证"闭环。

## 前置
- Phase 2 完成，已懂选项作用域（L1.3）与 `plugin/10_options.lua` 结构（L2.2）。

## 需求
在本配置中加入三个改动：
1. 缩进改为 4 空格（`tabstop=4 shiftwidth=4`）。
2. 启用相对行号 `relativenumber`（配合 `number` 使用）。
3. 允许读取项目级 `.nvimrc`（`exrc`）。

## 动手实操

### 1. 改缩进
在 `plugin/10_options.lua` 的 "Editing" 段，把：
```lua
vim.o.shiftwidth    = 2
vim.o.tabstop       = 2
```
改为 4。保存 `:source %`。

**验证**：`:verbose set shiftwidth?` → `shiftwidth=4` + 行号；按 `<Tab>` 缩进 4 空格。

### 2. 加相对行号
在 UI 段 `vim.o.number = true` 后加一行：
```lua
vim.o.relativenumber = true
```
**验证**：`:verbose set relativenumber?` → 行号变成"相对当前行的距离"。

### 3. 开 exrc（注意：必须在 init.lua 底部设）
`10_options.lua` 文件头注释（`init.lua` 结构说明 + `10_options.lua:15`）明确说：**像 `exrc` 这种启动期选项，必须在 init.lua 底部设**，否则太晚。
在 `init.lua` 底部（`Config.gh` 之后）加：
```lua
vim.o.exrc = true
```
重启 nvim。**验证**：`:set exrc?` → `exrc`；在任意项目根放一个 `.nvimrc` 写 `set number`，进该目录打开 nvim 会额外执行它。

## 验证反馈
| 命令 | 期望输出 |
|---|---|
| `:verbose set shiftwidth?` | 4 + 定义位置 |
| `:verbose set relativenumber?` | 值 + 位置 |
| `:set exrc?` | `exrc` |

## 常见坑
- **`exrc` 要在 init.lua 设**：`plugin/` 在 init.lua 之后才 source，太晚。这是本仓库文件头反复强调的。
- **改完忘 `:source %`**：选项类改动 `:source %` 即生效，但 `exrc` 这种启动期必须重启。
- **`relativenumber` 与 `number` 不冲突**：两者可共存，relativenumber 把除当前行外的行号变相对值。

## 网络大神总结

> **Folke（lazy.nvim 作者）**：改配置时记住"**最小可用改动**"——一次只改一个选项、立即验证，比一次塞十个再排查省时间得多。他用 `:verbose set` 反查来源的习惯，几乎每个高级 Vim 用户都在用。

> **Christian Chiarulli（LunarVim 创始人）**：他的新手建议是"**从改一个现有配置开始，而不是从零写**"——在成熟配置上改数值、看效果、理解含义，比对着空白文件硬背 `:h option-list` 高效十倍。

## 延伸阅读
- `:h 'relativenumber'` · `:h 'exrc'` · `:h 'tabstop'`
- `:h vim.o`（写选项的两种风格）

## 自测
- ☐ 三项改动都落地且有 `:verbose set` 验证
- ☐ 能解释为什么 `exrc` 必须放 init.lua 底部
- ☐ 改错时用 `git checkout -- <文件>` 成功还原过
