# L1.1 · Lua 变量、类型、表

## 目标
掌握 Lua 最核心的语法（变量、类型、表），能直接在 Neovim 里用 `:lua` 写表达式并立即看到结果。这是后面所有配置的语言基础。

## 前置
- 会打开 nvim，会切到命令行模式（`:`）。
- 了解这个仓库用的是 Lua 配置（`init.lua`），而非 Vimscript。

## 核心概念

Lua 是动态类型语言，只有 8 种类型：`nil`、`boolean`、`number`、`string`、`function`、`table`、`userdata`、`thread`。Neovim 内置 LuaJIT。

### 1. 变量与作用域
```lua
a = 1            -- 全局变量（默认，别乱用）
local b = 2      -- 局部变量（推荐，快且不污染全局）
print(a, b)      --> 1  2
```
Neovim 配置里几乎处处用 `local`。全局只在刻意暴露时用，比如 `init.lua:66` 的 `_G.Config = {}`。

### 2. 类型与字符串
```lua
print(type(1), type('x'), type(nil), type({}), type(print))
--> number string nil table function
local s = '单引号' .. '拼接'       -- .. 是字符串拼接
local n = 'a' .. 2                 -- 数字会自动转字符串
print(#s)                          -- # 取长度（字符串或表）
```
注意：Lua 从 1 开始索引（不是 0），`#` 取字符串/数组长度。

### 3. 表（table）——Lua 唯一的复合数据结构
表同时是数组、字典、对象。Neovim 配置大量使用表来传"配置"。
```lua
local t = {}                -- 空表
t.a = 1                     -- 点号赋值 → 字典
t['b'] = 'two'              -- 方括号等价
t[1] = 'first'              -- 数字键 → 数组
print(t.a, t.b, t[1])       --> 1 two first
print(#t)                   --> 1 （# 只数连续的数组部分）
```
配置里常见写法（来自 `plugin/30_mini.lua`）：
```lua
require('mini.basics').setup({
  options = { basic = false },
  mappings = { windows = true },
})
```
这里 `{ ... }` 就是一个表，作为**唯一参数**传给 `setup`。

## 动手实操
1. 打开 nvim，输入：
   ```
   :lua print(1 + 1)
   ```
   回车，命令行下方出现 `2`。这就是你的"Lua REPL"。

2. 依次执行并观察：
   ```
   :lua local t = { a = 1, b = 'x' } print(t.a .. t.b)
   :lua t = {10, 20, 30} print(#t, t[1], t[3])
   :lua =vim.g.mapleader
   ```
   第三行用 `:=`（`:lua =` 的简写），直接把表达式结果打印到命令行，比 `print` 更省事。

3. 改一个真实文件验证"表作为配置"：临时在 `plugin/10_options.lua` 末尾追加：
   ```lua
   vim.g.my_test = { a = 1, b = 'x' }
   ```
   保存后 `:source %`，再 `:lua =vim.g.my_test`，应显示 `{ a = 1, b = "x" }`。

## 验证反馈
| 命令 | 期望输出 |
|---|---|
| `:lua print(type({}))` | `table` |
| `:lua print(#"hello")` | `5` |
| `:lua =vim.g.my_test` | `{ a = 1, b = "x" }` |
| `:lua =vim.g.my_test.a` | `1` |

## 常见坑
- **从 1 开始**：`t[0]` 不是数组第一个元素，是 `t[1]`。
- **`#` 对混合表不可靠**：只有"连续数组"部分才有意义的长度。
- **全局变量坑**：忘写 `local` 会把变量丢进 `_G`，可能覆盖别人的全局。Neovim 配置里始终 `local`。

## 网络大神总结

> **Roberto Ierusalimschy（Lua 作者）**：Lua 设计的核心理念是"表是唯一的（数据）构造机制"——一个简单结构干所有事（数组、字典、对象）。这也是为什么 Neovim 团队选它做配置语言：足够小、足够快、表达能力够用。

> **TJ DeVries（telescope 作者、Neovim 核心贡献者）**：把 `:lua` 当交互式 REPL 用，是学 Neovim Lua 的最快路径——"你在命令行里写 Lua 的那一刻，配置就从'黑盒'变成了'可以探索的现场'"。

## 延伸阅读
- `:h lua` · `:h lua-guide`（官方 Lua 入门，Neovim 场景）
- 《Programming in Lua》第 2 章；[learnxinyminutes.com/docs/lua](https://learnxinyminutes.com/docs/lua/)

## 自测
- ☐ 能解释 `local` 与全局的区别及何时用哪个
- ☐ 能写一个含字典和数组两种用法的表
- ☐ 能用 `:lua =` 打印任意表达式结果
