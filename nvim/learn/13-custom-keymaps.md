# L3.2 · 自定义 Leader 映射

## 目标
新增一条带 `desc` 的 Leader 映射，并同步登记到 `Config.leader_group_clues`，让 `mini.clue` 能提示它。

## 前置
- L1.5、L2.3 完成，已懂 Leader 分组与 `nmap_leader`。

## 需求
加一个 `<Space>hh`：在当前行下方插入一行 `===` 分隔线（演示函数 RHS + 操作 buffer）。

## 动手实操

### 1. 写映射函数
在 `plugin/20_keymaps.lua` 的 "o is for 'Other'" 段附近（`<Space>oz` 之后）加：
```lua
local insert_separator = function()
  local line = vim.api.nvim_get_current_line()
  local sep = string.rep('=', math.max(#line, 10))
  vim.api.nvim_put({ sep, '' }, 'l', false, true)
end
nmap_leader('hh', insert_separator, 'Insert separator')
```
- `vim.api.nvim_put` 在当前行下方插入（`:h nvim_put`）。
- `nmap_leader` 已在文件顶部定义。

### 2. 登记 clue（如果新建了分组）
`hh` 属于已有的 `o`（Other）组，无需新建组。但若你想新建一个组，例如 `<Space>w` 组，需在 `Config.leader_group_clues`（`20_keymaps.lua:52`）里加：
```lua
{ mode = 'n', keys = '<Leader>w', desc = '+MyGroup' },
```

### 3. 保存验证
`:source %` 后按 `<Space>hh` → 当前行下出现分隔线。

## 验证反馈
| 命令 | 期望输出 |
|---|---|
| `:verbose nmap <Leader>hh` | 映射详情 + 位置 |
| 按住 `<Space>` 1 秒 | clue 显示 `hh Insert separator` |
| 按 `<Space>hh` | 插入 `===` 行 |

## 常见坑
- **RHS 函数里别用 `vim.cmd('normal!')` 做复杂操作**：应优先用 `vim.api`（如 `nvim_put`），更干净、可 dot-repeat。
- **新组要登记 clue**：忘了登记，clue 不报错，但也不会提示，等于"隐形映射"。
- **`nmap_leader` 只做 Normal 模式**：要在 Visual 模式加，用文件里的 `xmap_leader`。

## 网络大神总结

> **TJ DeVries（telescope 作者）**：函数 RHS 是 Lua 配置相对 Vimscript 的最大优势——"**你的按键可以直接调一个带名字、可测试的 Lua 函数**"，而不是一段神秘字符串。写映射先写函数，可读性会好一个量级。

> **ThePrimeagen**：好映射的标准是"**能不看屏幕盲按**"。做映射时自问：三周后我还记得这是干嘛的吗？`desc` + clue 就是为此服务的——让编辑器自己提醒你。

## 延伸阅读
- `:h vim.keymap.set()` · `:h nvim_put()`
- `:h MiniClue.set_mapping_desc()`（改映射描述）

## 自测
- ☐ 映射能触发且有 `desc`
- ☐ clue 能显示该映射
- ☐ 能解释为何用 `vim.api.nvim_put` 而非 `normal!`
