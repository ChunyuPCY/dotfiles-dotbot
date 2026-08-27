# L3.7 · treesitter 扩展

## 目标
为配置加入一种新语言的 tree-sitter 解析器，验证语法高亮/文本对象增强。

## 前置
- L2.5（treesitter 基础）完成。

## 核心概念回顾
`plugin/40_plugins.lua:53` 的 `languages` 数组决定装哪些解析器；改完要重启一次等待安装（`40_plugins.lua:51` 注释）。

## 动手实操（以 JavaScript 为例）

1. 在 `plugin/40_plugins.lua` 的 `languages` 数组加 `'javascript'`：
```lua
local languages = {
  'lua', 'vimdoc', 'markdown',
  'javascript',   -- 新增
}
```
2. 保存，重启 nvim（会触发 `vim.treesitter.start` 安装解析器，等待完成）。
3. 打开 `.js` 文件，验证：
   - `:InspectTree` → 有语法树。
   - `:checkhealth nvim-treesitter` → javascript 已安装。
   - mini.ai 的函数 textobject `aF`/`iF`（`30_mini.lua:332`）在 js 函数上可用。

## 验证反馈
| 命令 | 期望输出 |
|---|---|
| `:checkhealth nvim-treesitter` | javascript 绿色 |
| `:InspectTree` | js 语法树窗口 |
| 光标在函数内按 `ciF` | 改变函数体内内容 |

## 常见坑
- **改 `languages` 后必须重启**：安装发生在上次启动时，不重启不会装。
- **编译依赖**：部分语言解析器需 C 编译器（`:checkhealth nvim-treesitter` 会提示 Requirements）。
- **内置解析器 vs nvim-treesitter**：lua/vimdoc/markdown 是 Neovim 自带，但查询文件（query）仍可能需 `nvim-treesitter` 补齐（见 `40_plugins.lua:34` 故障排查）。

## 网络大神总结

> **Neovim 团队（treesitter 集成的推动者）**：treesitter 取代 regex 高亮是 Neovim 迈向"结构化理解代码"的关键一步。**它能给你的不只是更好看的颜色，而是精确的文本对象、折叠、缩进**——`MiniAi.gen_spec.treesitter`（`30_mini.lua:332`）就是活例子。

> **ThePrimeagen**：他常强调"**用 treesitter 文本对象，别再用纯括号匹配**"——`aF`/`iF`（函数）、`ac`（class）这类基于语法的对象，才是"理解代码"而非"数括号"。

## 延伸阅读
- `:h treesitter` · `:h treesitter-query` · `:h lsp-vs-treesitter`
- `:h MiniAi.gen_spec.treesitter()`
- `:h vim.treesitter.language.get_filetypes()`

## 自测
- ☐ 新语言 `:checkhealth` 绿色
- ☐ `:InspectTree` 有语法树
- ☐ 能说清"解析器"与"查询文件"各是什么

---

## Phase 3 收尾自测
完成 12~18 后，检查：

> **你的配置已经从"抄来的"变成"能解释每处改动为什么、怎么验证的"。**

具体地：你能对任意一处自己的改动，说出"需求 → 改了什么 → 用什么命令验证 → 出错了怎么还原"。若答不出，回到对应课时重做。
