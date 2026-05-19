-- vim.loader.enable() -- Enable faster startup by caching compiled Lua modules

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.g.have_nerd_font = true

-- vim.o.laststatus =0 -- 关闭底部状态栏
vim.o.number = true -- 开启左侧数字
vim.o.relativenumber = true -- 使用相对数
vim.o.cursorline = true -- 高亮当前行
vim.o.scrolloff = 10 -- 在光标上方/下方保留 10 行内容
vim.o.sidescrolloff = 10 -- 将光标左侧/右侧保留 10 个字符的位置

vim.o.mouse = 'a' -- 鼠标功能全开

vim.o.showmode = false -- 关闭系统模式显示，后面使用 mini.nvim

-- 共享系统剪切
vim.schedule(function() vim.o.clipboard = 'unnamedplus' end)

vim.o.breakindent = true -- 一行文字如果这行，这行部分会有缩进显示

vim.o.undofile = true

vim.o.ignorecase = true -- / 搜索时忽略大小写
vim.o.smartcase = true -- / 搜索时智能大小写

vim.o.signcolumn = 'yes'

-- ======================================================
-- [ 设置 tab 键 ]
-- ======================================================
vim.o.tabstop = 2 -- tab width
vim.o.shiftwidth = 2 -- indent width
vim.o.softtabstop = 2 -- 软制表符 不使用制表符和退格键进行换行
vim.o.expandtab = true -- 使用 空格 代替 制表符
vim.o.smartindent =true
vim.o.autoindent = true

vim.o.updatetime = 250 -- Decrease update time
vim.o.timeoutlen = 300 -- Decrease mapped sequence wait time

vim.o.splitright = true -- Configure how new splits should be opened
vim.o.splitbelow = true

vim.o.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

vim.o.inccommand = 'split' -- Preview substitutions live, as you type!

vim.o.confirm = true

vim.opt.iskeyword = "_,49-57,A-Z,a-z" -- 指定 keyword
vim.o.winborder = "rounded" -- 让全局默认边框变成rounded
