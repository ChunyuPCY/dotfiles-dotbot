local utils = require 'utils'
local gh = utils.gh

local specs = {
  -- mini.lua 各种对字符的surround包裹{} [] ''
  gh 'nvim-mini/mini.nvim',
  -- treesitter.lua 需要安装tree-sitter-cli工具包
  {
    src = gh 'nvim-treesitter/nvim-treesitter',
    version = 'main',
  },
  -- gitsigns.lua 突出增、删、改过的行
  gh 'lewis6991/gitsigns.nvim',
}

-- 禁用插件：不会加载，不会下载（如果是最近添加的），已在硬盘上不会被删除
local disabled = {}

-- ==============================================================
-- 快捷管理命令
-- ==============================================================

-- 获取所有已安装插件的名称列表（用于 Tab 补全）
local function get_plugin_names(arg_lead)
  local installed = vim.pack.get(nil, { info = false })
  local names = {}
  for _, p in ipairs(installed) do
    local name = p.spec.name
    -- 只添加匹配开头字符串的插件
    if name:lower():find(arg_lead:lower(), 1, true) == 1 then table.insert(names, name) end
  end
  -- 排序让补全列表更整洁
  table.sort(names)
  return names
end

-- :PackUpdate 命令更新插件，不带参数更新全部，默认显示审查界面（需按 :w 确认）；可以加 ! 强制直接更新
vim.api.nvim_create_user_command('PackUpdate', function(opts)
  local targets = #opts.fargs > 0 and opts.fargs or nil
  local force = opts.bang -- 如果输入了 PackUpdate! 则 opts.bang 为 true
  if targets then
    vim.notify('Checking updates for: ' .. table.concat(targets, ', '), vim.log.levels.INFO)
  else
    vim.notify('Checking updates for all plugins...', vim.log.levels.INFO)
  end
  vim.pack.update(targets, { force = force })
end, {
  nargs = '*',
  bang = true, -- 声明支持 ! 符号
  complete = get_plugin_names,
  desc = 'Update plugins (use ! to skip confirmation)',
})

-- :PackStatus 命令查看插件当前状态和版本
vim.api.nvim_create_user_command('PackStatus', function(opts)
  local targets = #opts.fargs > 0 and opts.fargs or nil
  vim.pack.update(targets, { offline = true })
end, {
  nargs = '*',
  complete = get_plugin_names,
  desc = 'Check plugin status without downloading',
})

-- 执行启动流程

-- 同步清理孤儿插件并注册禁用名单
PackUtils.sync(specs, disabled)

-- 正式下载/更新插件
vim.pack.add(specs)

-- 加载 configs/ 注册所有监听器
local config_path = vim.fn.stdpath 'config' .. '/lua/configs'

if vim.fn.isdirectory(config_path) == 1 then
  for name, type in vim.fs.dir(config_path) do
    if type == 'file' and name:match '%.lua$' then pcall(require, 'configs.' .. name:gsub('%.lua$', '')) end
  end
end
