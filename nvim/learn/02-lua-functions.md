# L1.2 · Lua 函数、闭包、控制流

## 目标
掌握函数（一等公民）、闭包、`if`/循环，能读懂本仓库里所有 `function(...) ... end` 的写法，并自己写一个函数挂到 `Config` 上。

## 前置
- L1.1 完成。
- 已通读 `init.lua` 里的 `Config.new_autocmd`（`init.lua:77-80`）。

## 核心概念

### 1. 函数是一等公民：可赋值、可传参、可返回
```lua
local add = function(a, b) return a + b end   -- 匿名函数赋给变量
local function sub(a, b) return a - b end      -- 语法糖，等价
print(add(2, 3), sub(5, 2))                    --> 5 3
```
`init.lua:77` 就是这种写法：
```lua
Config.new_autocmd = function(event, pattern, callback, desc)
  local opts = { group = gr, pattern = pattern, callback = callback, desc = desc }
  vim.api.nvim_create_autocmd(event, opts)
end
```
`callback` 是一个函数，被存进 `opts` 表传给 Neovim。**把函数当数据传递**是本配置的核心套路。

### 2. 闭包：函数捕获外层变量
```lua
local function make_counter()
  local n = 0
  return function() n = n + 1 return n end
end
local c = make_counter()
print(c(), c(), c())   --> 1 2 3
```
`init.lua:88` 的 `Config.on_packchanged` 里，`f` 函数捕获了外层的 `plugin_name`、`kinds`、`callback`——这就是闭包。

### 3. 控制流
```lua
if x == 1 then
  print('one')
elseif x == 2 then
  print('two')
else
  print('other')
end

for i = 1, 3 do print(i) end          -- 数值 for
for k, v in pairs(t) do print(k, v) end  -- 泛型 for，遍历表
for i, v in ipairs(arr) do print(i, v) end -- 遍历数组（连续部分）
```
注意：Lua 没有 `continue`；用 `if` 包裹或 `goto`。`nil` 和 `false` 是假，其余（含 `0`、`''`）都是真。

## 动手实操
1. 在 nvim 里跑：
   ```
   :lua local add = function(a,b) return a+b end print(add(2,3))
   ```
   → `5`

2. 练习闭包：
   ```
   :lua local f = function(x) return function(y) return x+y end end print(f(10)(5))
   ```
   → `15`

3. 仿照 `Config.new_autocmd` 写一个自己的函数：在 `init.lua` 底部（`Config.gh` 之后）加：
   ```lua
   Config.my_echo = function(msg, times)
     times = times or 1
     for _ = 1, times do print(msg) end
   end
   ```
   保存后 `:source %`，然后 `:lua Config.my_echo('hi', 3)` → 打印 3 行 `hi`。

## 验证反馈
| 命令 | 期望输出 |
|---|---|
| `:lua =type(Config.new_autocmd)` | `function` |
| `:lua =Config.my_echo` | `function: 0x...` |
| `:lua Config.my_echo('x', 2)` | 两行 `x` |
| `:lua =("0" == "0") and "真" or "假"` | 因 `"0"` 是真值 → 逻辑结果为 `"假"`（演示真值规则） |

## 常见坑
- **`and/or` 不是返回布尔**：`a and b or c` 返回的是值，不是 `true/false`。上面的验证里 `"0"` 为真，所以 `"0" and "真"` 返回 `"真"`，`"真" or "假"` 返回 `"真"`，最终 `"真"`。但若第一个是 `false`，会走 `or` 的 `"假"`——这是经典陷阱。
- **参数默认值**：Lua 没有内置默认参数，用 `times = times or 1` 模拟（如上）。
- **`pairs` vs `ipairs`**：`ipairs` 只走数组连续部分，遇 `nil` 即停。

## 网络大神总结

> **TJ DeVries（telescope 作者）**：Neovim 配置的最佳实践是"写函数，而不是堆数据"——把一段逻辑包成带名字的函数（如 `Config.new_autocmd`），配置就会从"一堆散设置"变成"一个可读、可测试的程序"。他的 [nvim-lua-guide](https://github.com/nanotee/nvim-lua-guide) 是公认最好的入门指南之一。

> **echasnovski（mini.nvim 作者）**：mini.nvim 每个模块的 `setup({...})` 都只接受**一个表参数**，这既利用了 Lua "表即配置" 的简洁，也让配置天然可扩展——新增字段不破坏旧写法。

## 延伸阅读
- `:h lua-guide`（`:h lua-function`、`:h lua-loop` 等小节）
- 《Programming in Lua》第 6 章（函数）；[nvim-lua-guide](https://github.com/nanotee/nvim-lua-guide)

## 自测
- ☐ 能解释 `Config.new_autocmd` 里 `callback` 为何能"稍后才被调用"
- ☐ 能写出一个返回函数的函数（闭包），并说明它捕获了什么
- ☐ 能复述 `and/or` 的返回值陷阱
