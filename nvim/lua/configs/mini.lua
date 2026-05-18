--  A collection of various small independent plugins/modules
vim.pack.add { Config.gh 'nvim-mini/mini.nvim' }

-- If a nerd font is available, load the icons module for pretty icons in various plugins.
if vim.g.have_nerd_font then
  -- vim.notify 'load mini icons'
  require('mini.icons').setup()
  -- Statusline. Sets `:h 'statusline'` to show more info in a line below window.
  -- Example usage:
  -- - Left most section indicates current mode (text + highlighting).
  -- - Second from left section shows "developer info": Git, diff, diagnostics, LSP.
  -- - Center section shows the name of displayed buffer.
  -- - Second to right section shows more buffer info.
  -- - Right most section shows current cursor coordinates and search results.
  --
  -- See also:
  -- - `:h MiniStatusline-example-content` - example of default content. Use it to
  --   configure a custom statusline by setting `config.content.active` function.
  local statusline = require 'mini.statusline'
  statusline.setup { use_icons = vim.g.have_nerd_font }

  -- You can configure sections in the statusline by overriding their
  -- default behavior. For example, here we set the section for
  -- cursor location to LINE:COLUMN
  ---@diagnostic disable-next-line: duplicate-set-field
  statusline.section_location = function() return '%2l:%-2v' end

  -- Tabline. Sets `:h 'tabline'` to show all listed buffers in a line at the top.
  -- Buffers are ordered as they were created. Navigate with `[b` and `]b`.
  require('mini.tabline').setup()

  vim.schedule(function()
    -- Used for backwards compatibility with plugins that require `nvim-web-devicons` (e.g. telescope.nvim)
    MiniIcons.mock_nvim_web_devicons()
    MiniIcons.tweak_lsp_kind()

    require('mini.keymap').setup()

    -- Buffer navigation
    MiniKeymap.map_combo({ 'n', 'x' }, 'll', 'g$')
    MiniKeymap.map_combo({ 'n', 'x' }, 'hh', 'g^')
    MiniKeymap.map_combo({ 'n', 'x' }, 'jj', '}')
    MiniKeymap.map_combo({ 'n', 'x' }, 'kk', '{')

    local mode = { 'i', 'c', 'x', 's' }
    MiniKeymap.map_combo(mode, 'jk', '<BS><BS><Esc>')

    require('mini.ai').setup {
      -- NOTE: Avoid conflicts with the built-in incremental selection mappings on Neovim>=0.12 (see `:help treesitter-incremental-selection`)
      mappings = {
        around_next = 'aa',
        inside_next = 'ii',
      },
      n_lines = 500,
    }

    require('mini.surround').setup()
  end)
end
