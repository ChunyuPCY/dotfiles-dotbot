# L5.3 · 性能调优

## 目标
学会测量启动时间，理解 `now/later` 懒加载如何影响性能，并能定位慢在哪。

## 前置
- L2.1（`now/later` 原理）完成。

## 核心概念

### 1. 测量启动时间
```bash
nvim --startuptime /tmp/startup.log +qa
```
（`/tmp/startup.log` 会按启动各阶段排序，能看到每个文件/插件耗时。）
Neovim 0.12 也有内置：
```
:lua =vim.startuptime()   -- 最近一次启动耗时
```

### 2. 懒加载三板斧（本仓库已用）
- `Config.later`：首屏后执行。
- `Config.now_if_args`：带文件启动才立即执行。
- 字符串 RHS 映射（`<Cmd>`）：目标函数在映射**执行时**才 require，不阻塞启动。

### 3. 定位慢点
```lua
:lua =MiniMisc.stat_summary(MiniMisc.bench_time(function() ... end, 100))
```
（`30_mini.lua:276` 的注释就有示例。）

## 动手实操
1. 测基线：
   ```bash
   nvim --startuptime /tmp/startup.log +qa
   ```
   查看 `startup.log` 末尾的 "Total" 耗时。
2. 找一个你暂时用不到的模块（如 `mini.map`），把它的 `later(function() ... end)` 临时注释掉，再测一次，观察耗时差。
3. 用 `:lua =vim.startuptime()` 在运行中再看一次。

## 验证反馈
| 命令 | 期望输出 |
|---|---|
| `cat /tmp/startup.log` | 各阶段耗时排序 |
| `:lua =vim.startuptime()` | 启动耗时毫秒数 |
| `:lua =vim.fn.stdpath('data')` | 数据目录（可清理缓存） |

## 常见坑
- **`later` 不是万能**：把必须首屏就绪的东西放 `later` 会导致闪屏。判断标准：这个功能"第一眼"是否必须？
- **启动耗时 ≠ 卡顿**：运行时卡顿更常来自大文件、diagnostic 全量刷新、tree-sitter 大 buffer（`mini.map` 注释就提醒 10000+ 行会 lag）。
- **别过度优化**：`later` 带来的复杂度要值得。启动 <100ms 已足够好，别为再省 20ms 增加心智负担。

## 网络大神总结

> **Folke（lazy.nvim 作者）**：他是"启动时间"领域最知名的人，核心观点是"**最快的插件是没加载的插件**"。但他在 LazyVim 文档里也反复提醒：**懒加载的价值是"用不到的不加载"，不是"什么都延迟"**——过度懒加载反而让配置难懂。

> **echasnovski（mini.nvim 作者）**：MiniMax 的 `now/later/now_if_args` 三级，是"**最小化到首屏时间**"的工程化表达。他的态度是：优化要**基于测量**（`--startuptime`、`bench_time`），而不是凭感觉。先测，再优化，再复测。

## 延伸阅读
- `:h startup` · `:h vim.startuptime()`
- `:h --startuptime`（命令行参数）
- `:h MiniMisc.bench_time()`

## 自测
- ☐ 能测出并读懂启动耗时分布
- ☐ 能定位并优化一个不必要的启动加载
- ☐ 能复述"先测量，再优化，再复测"的原则
