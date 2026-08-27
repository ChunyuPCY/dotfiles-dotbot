# L2.3 · keymaps 逐项精读（plugin/20_keymaps.lua）

## 目标
理解 Leader 分组体系（`Config.leader_group_clues`），逐个体验 `<Leader>` 映射背后的功能，并搞懂几个帮助函数（`nmap`、`nmap_leader`、`edit_plugin_file`）。

## 前置
- L2.1、L2.2 完成，已懂 `vim.keymap.set`（L1.5）。

## 核心概念

### 1. "两键 Leader 映射"设计（文件头注释已说明）
`<Leader>f` 是"Find"组，`<Leader>ff` 是组内"find files"。第一个键 = 语义分组，第二个键 = 动作。小写=全局、大写=局部（如 `<Leader>fs` workspace 符号 vs `<Leader>fS` document 符号）。

### 2. `Config.leader_group_clues`（`20_keymaps.lua:52`）
给 `mini.clue` 提供分组线索的表。**每加一个新 Leader 组，都要在这里登记**，否则 clue 窗口不会提示。
```lua
Config.leader_group_clues = {
  { mode = 'n', keys = '<Leader>b', desc = '+Buffer' },
  ...
}
```

### 3. 帮助函数
```lua
local nmap = function(lhs, rhs, desc)
  vim.keymap.set('n', lhs, rhs, { desc = desc })  -- 一般映射
end
local nmap_leader = function(suffix, rhs, desc)
  vim.keymap.set('n', '<Leader>' .. suffix, rhs, { desc = desc })  -- Leader 映射
end
```
`edit_plugin_file`（`20_keymaps.lua:100`）用 `string.format` 拼出 `:edit <config>/plugin/<file>`，所以 `<Space>ek/em/eo/ep` 能快速打开各配置文件。

## 逐组体验（这是"实操反馈"的核心）

按下面每组逐一**亲手按**，并观察效果。每组都问自己：它调用了哪个 mini 模块？

### b 组（Buffer）
- `<Space>bs` 临时 buffer → 用 `:ls` 看多了个 scratch
- `<Space>bd` 删除 buffer、`<Space>bw` 完全清除（观察 tabline 变化）

### e 组（Explore/Edit）
- `<Space>ei` 打开 init.lua、`<Space>ek` 打开 keymaps 配置
- `<Space>ed` 文件浏览器（mini.files，Miller 列），`l` 进入 `h` 返回

### f 组（Find，mini.pick）
- `<Space>ff` 找文件、`<Space>fg` 全文搜索、`<Space>fh` 查 help、`<Space>fb` 找 buffer、`<Space>fr` 恢复上次

### g 组（Git，mini.git/mini.diff）
- `<Space>gs` 光标处 git 信息、`<Space>gd` 看 diff、`<Space>go` 切换 overlay

### l 组（Language，LSP）
- `<Space>lr` 重命名、`<Space>ls` 跳定义、`<Space>ld` 诊断浮窗、`<Space>lf` 格式化（需 LSP/conform 就绪）

### 其它组
- m：mini.map（`<Space>mt` 开关代码缩略图）
- o：`<Space>ot` 去尾随空格、`<Space>oz` 缩放窗口
- s：session（`<Space>sn` 新建、`<Space>sr` 读取）
- t：终端（`<Space>tt`/`tT`）
- v：visits（`<Space>fv` 访问历史、`<Space>vv` 打 core 标签）

## 验证反馈
| 命令 | 期望输出 |
|---|---|
| `:map <Leader>` | 全部 Leader 映射（对齐分组的全景） |
| `:verbose nmap <Leader>ff` | 该映射定义位置 |
| 按住 `<Space>` 1 秒 | mini.clue 弹出分组提示 |

## 常见坑
- **RHS 用 `<Cmd>` 懒加载**：`20_keymaps.lua:71` 注释说明——字符串 RHS 不要求在映射创建时目标函数就存在，这是启动优化。
- **`gr` 被 mini.operators 占用**：所以 LSP 的 go-to-reference 用 `<Space>lR` 而非内建 `gr`（见文件 l 组注释）。
- **`(` `)` 被重映射**：`20_keymaps.lua:683` 把它们改成交换参数，要知道这不是默认行为。

## 网络大神总结

> **ThePrimeagen**：最高效的 Vim 用户不是快捷键最多的人，而是**把最常用的动作放进"第二本能"的人**。Leader 分组（f/b/g/l…）的价值是让你**按语义回想**，而不是背一长串孤立按键。

> **TJ DeVries（telescope 作者）**：picker（本配置的 `<Space>f` 家族）是"找东西"的终极形态——"任何你需要在文件/缓冲区/符号/历史里找的东西，都应该一个键到达"。他在设计 telescope 时追求的就是这种"一个入口，模糊匹配一切"的统一感。

## 延伸阅读
- `:h vim.keymap.set()` · `:h <Leader>`
- `:h MiniPick-overview` · `:h MiniClue-examples`

## 自测
- ☐ 能不看文件说出 `<Space>` 下 b/e/f/g/l 五组的语义
- ☐ 能解释 `nmap_leader` 与 `nmap` 的区别
- ☐ 能手按 `<Space>ff/fg/fh/ed` 完成一次"找文件→搜内容→查文档→开浏览器"流程
