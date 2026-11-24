local wezterm = require('wezterm')
local Config = require('config')

local smart_splits = wezterm.plugin.require('https://github.com/smart-splits-nvim/backend-wezterm')

require('utils.backdrops')
   -- :set_focus('#000000')
   -- :set_images_dir(require('wezterm').home_dir .. '/Pictures/Wallpapers/')
   :set_images()
   :random()

require('events.left-status').setup()
require('events.right-status').setup({ date_format = '%a %H:%M:%S' })
require('events.tab-title').setup({ hide_active_tab_unseen = false, unseen_icon = 'circle' })
require('events.new-tab-button').setup()

local config = Config:init()
   :append(require('config.appearance'))
   :append(require('config.bindings'))
   :append(require('config.domains'))
   :append(require('config.fonts'))
   :append(require('config.general'))
   :append(require('config.launch')).options

-- Ctrl+Shift+h/j/k/l 调整 WezTerm pane 大小（避开 macOS 的 Cmd+H 和 shell 的 Ctrl+方向键）
smart_splits.apply_to_config(config, {
   direction_keys = { 'h', 'j', 'k', 'l' },
   modifiers = {
      move = 'CTRL',
      resize = 'CTRL|SHIFT',
   },
   at_edge = 'stop',
})

return config
