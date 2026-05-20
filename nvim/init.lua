-- stylua: ignore start
-- ==============================================================
-- [ 插件管理引擎 (PackUtils) (暴露给全局，供 configs/*.lua 调用) ]
-- ==============================================================
_G.PackUtils = {
  is_building = {},      -- 记录各插件的构建状态，防止重复构建
  is_initialized = {},   -- 记录具体的配置代码块是否已执行
  plugin_loaded = {},    -- 记录插件是否已挂载（避免重复 packadd）
  disabled_plugins = {}, -- 专门记录被禁用的插件，供 load 拦截使用
}
-- stylua: ignore end

-- [ 解析插件名 ]
function PackUtils.get_name(spec)
  if type(spec) == 'table' then return spec.name end

  local plugin_name = vim.fs.basename(spec)

  -- 仅当以 .git 结尾时才进行替换
  if plugin_name:ends_with '.git' then return plugin_name:sub(1, -5) end

  return plugin_name
end

-- [ 同步清理 ] 自动删除孤儿，并注册禁用名单
function PackUtils.sync(active_specs, disabled_specs)
  disabled_specs = disabled_specs or {}
  local protected_names = {}

  -- 将插件加入受保护名单
  for _, spec in ipairs(active_specs) do
    protected_names[PackUtils.get_name(spec)] = true
  end

  for _, spec in ipairs(disabled_specs) do
    local name = PackUtils.get_name(spec)
    protected_names[name] = true
    PackUtils.disabled_plugins[name] = true -- 写入字典，供 load 拦截
  end

  -- 扫描磁盘
  local pack_dir = vim.fn.stdpath 'data' .. '/site/pack'
  local installed_plugins = {}
  local packages = vim.fn.expand(pack_dir .. '/*', false, true)
  for _, pkg in ipairs(packages) do
    for _, type_dir in ipairs { 'start', 'opt' } do
      local path = pkg .. '/' .. type_dir
      if vim.fn.isdirectory(path) == 1 then
        local dirs = vim.fn.expand(path .. '/*', false, true)
        for _, dir in ipairs(dirs) do
          local name = dir:match '([^/]+)$'
          if name ~= 'README.md' and name ~= 'doc' then table.insert(installed_plugins, name) end
        end
      end
    end
  end

  -- 找出既不在 active 也不在 disabled 里面的孤儿
  local to_delete = {}
  for _, installed in ipairs(installed_plugins) do
    if not protected_names[installed] then table.insert(to_delete, installed) end
  end

  if #to_delete > 0 then
    vim.schedule(function()
      vim.notify('🧹 Clean Up Orphaned Plugins: ' .. table.concat(to_delete, ', '), vim.log.levels.INFO)
      vim.pack.del(to_delete)
    end)
  end
end

-- ==============================================================
-- [ 颜色主题 ]
-- ==============================================================
vim.cmd.colorscheme 'catppuccin'

local function set_transparent() -- set UI component to transparent
  local groups = {
    'Normal',
    'NormalNC',
    'EndOfBuffer',
    'NormalFloat',
    'FloatBorder',
    'SignColumn',
    'StatusLine',
    'StatusLineNC',
    'TabLine',
    'TabLineFill',
    'TabLineSel',
    'ColorColumn',
  }
  for _, g in ipairs(groups) do
    vim.api.nvim_set_hl(0, g, { bg = 'none' })
  end
  vim.api.nvim_set_hl(0, 'TabLineFill', { bg = 'none', fg = '#767676' })
end

set_transparent()
