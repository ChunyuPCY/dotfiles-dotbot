-- =====================================================
-- [ 全局变量 ]
-- =====================================================
_G.Config = {}

local gr = vim.api.nvim_create_augroup('custom-config', {clear=true})
Config.new_autocmd = function(event, pattern, callback, desc)
  local opts = { group = gr, pattern = pattern, callback = callback, desc = desc }
  vim.api.nvim_create_autocmd(event, opts)
end

Config.on_packchanged = function(plugin_name, kinds, callback, desc)
  local f = function(ev)
    local name, kind = ev.data.spec.name, ev.data.kind
    if not (name == plugin_name and vim.tbl_contains(kinds, kind)) then return end
    if not ev.data.active then vim.cmd.packadd(plugin_name) end
    callback(ev.data)
  end
  Config.new_autocmd('PackChanged', '*', f, desc)
end

local function run_build(name, cmd, cwd)
  local result = vim.system(cmd, { cwd = cwd }):wait()
  if result.code ~= 0 then
    local stderr = result.stderr or ''
    local stdout = result.stdout or ''
    local output = stderr ~= '' and stderr or stdout
    if output == '' then output = 'No output from build command.' end
    vim.notify(('Build failed for %s:\n%s'):format(name, output), vim.log.levels.ERROR)
  end
end

Config.run_build = run_build

---Because most plugins are hosted on GitHub, you can use the helper
---function to have less repetition in the following sections.
---@param repo string
---@return string
local function gh(repo) return 'https://github.com/' .. repo end
Config.gh = gh

-- =====================================================
-- [ 主题颜色 ]
-- =====================================================
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

