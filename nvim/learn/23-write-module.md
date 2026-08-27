# L5.4 · 写自己的模块（综合实战）

## 目标
综合前面所学，写一个属于自己的小功能模块（挂到 `Config` 上，遵循本仓库约定），走完"设计 → 实现 → 加载 → 验证"全流程。

## 前置
- 所有前置课时完成。

## 核心原则
本仓库的约定（读 `init.lua` 头注释 + 各文件头注释）：
1. **全局辅助函数挂 `Config`**（`_G.Config`）。
2. **加载时机用 `now/later/now_if_args`**。
3. **autocmd 用 `Config.new_autocmd`**，进 `custom-config` 组。
4. **文件放进 `plugin/` 或 `after/`**，保持分层。
5. **带 `desc` 的映射 + 注释说明**。

## 动手实操：写一个"当前行高亮闪烁"小功能

用 `vim.api.nvim_set_hl` + 定时器 + autocmd 实现"光标进入某行时短暂高亮"。

新建 `plugin/50_my_module.lua`（数字 50 让它最后加载）：
```lua
-- 我的第一个模块：光标行短暂高亮提示
local gr = vim.api.nvim_create_augroup('my-flash', {})
vim.api.nvim_set_hl(0, 'MyFlashLine', { fg = '#000000', bg = '#ffd700', bold = true })

Config.flash_line = function(buf)
  buf = buf or 0
  local ns = vim.api.nvim_create_namespace('my-flash-line')
  local line = vim.api.nvim_win_get_cursor(0)[1] - 1
  vim.api.nvim_buf_set_extmark(buf, ns, line, 0, {
    hl_group = 'MyFlashLine', line_hl_group = 'MyFlashLine', hl_eol = true,
  })
  vim.defer_fn(function() vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1) end, 500)
end

vim.keymap.set('n', '<Space>hh', function() Config.flash_line() end, { desc = 'Flash line' })
```

## 验证反馈
| 命令 | 期望输出 |
|---|---|
| `:source %` 后按 `<Space>hh` | 当前行闪烁 500ms 金色 |
| `:verbose nmap <Space>hh` | 映射来源 |
| `:lua =Config.flash_line` | `function` |
| `:scriptnames` | 看到 `plugin/50_my_module.lua` |

## 常见坑
- **文件名数字前缀**：`50_` 让它最后加载，避免依赖未就绪。
- **`vim.defer_fn` 是异步**：清理用闭包捕获 `buf`/`ns`，避免作用域失效。
- **extmark 需 namespace**：`nvim_create_namespace` 一次创建，多次复用，别每次现建。

## 网络大神总结

> **TJ DeVries（telescope 作者、Neovim 核心）**：写第一个自己的插件/模块，是"从配置用户到配置作者"的分水岭。他反复说"**你的 config 就是一个每天都在运行的 Lua 程序**"——所以值得用写程序的纪律（模块化、命名、可测试）对待它。

> **echasnovski（mini.nvim 作者）**：mini 模块的代码本身就是最好的教材——"**每个模块独立、有 setup、有全局表、有 doc**"。想进阶就打开 `mini.files` 或 `mini.surround` 的源码读，看作者如何组织一个"小而完整"的模块。

## 延伸阅读
- `:h nvim_buf_set_extmark` · `:h vim.defer_fn()` · `:h nvim_create_namespace`
- 打开 `vim.fn.stdpath('data') .. '/site/pack/core/opt/mini.nvim/lua/mini'` 读 mini 源码
- `:h lua-guide`（综合回顾）

## 自测
- ☐ 独立写出一个模块并验证生效
- ☐ 遵循了本仓库的 5 条约定
- ☐ 能读懂 mini 某个模块的源码结构

---

## 结业标准
完成全部课时后，你应该能：
1. 从零读懂任何一个 Neovim 配置。
2. 独立为任意语言配好 LSP + formatter + lint + treesitter。
3. 写出自己的模块/映射/autocmd，并知道如何验证和调试。
4. 熟练使用文本对象、picker、surround 等高阶编辑能力，效率明显提升。

**下一步**：把这份学习成果反馈回配置本身——你会发现自己开始"看不顺眼"某些写法，然后去改进它。那一刻，你就不再是"配置的消费者"，而是"配置的主人"。
