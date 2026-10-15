-- ┌─────────────────────────┐
-- │ Filetype config example │
-- └─────────────────────────┘
--
-- This is an example of a configuration that will apply only to a particular
-- filetype, which is the same as file's basename ('markdown' in this example;
-- which is for '*.md' files).
--
-- It can contain any code which will be usually executed when the file is opened
-- (strictly speaking, on every 'filetype' option value change to target value).
-- Usually it needs to define buffer/window local options and variables.
-- So instead of `vim.o` to set options, use `vim.bo` for buffer-local options and
-- `vim.cmd('setlocal ...')` for window-local options (currently more robust).
--
-- This is also a good place to set buffer-local 'mini.nvim' variables.
-- See `:h mini.nvim-buffer-local-config` and `:h mini.nvim-disabling-recipes`.

-- Wrap long lines for comfortable reading. NOTE: 'spell' is deliberately
-- NOT enabled here: Neovim's spellcheck doesn't understand CJK, so any Chinese
-- text gets marked with red squiggles. If you want to spellcheck English text
-- inside markdown, run `setlocal spell` (or use `zS` mapping below).
vim.cmd('setlocal wrap')

-- Allow 'render-markdown.nvim' (and built-in conceal) to prettify headings,
-- bold/italic, lists, code blocks, links, etc. without editing the file.
vim.cmd('setlocal conceallevel=2 concealcursor=n')

-- Toggle spellchecking on/off (handy when writing English in Chinese notes)
vim.keymap.set('n', 'zS', function()
  vim.wo.spell = not vim.wo.spell
  local on = vim.wo.spell and 'ON' or 'OFF'
  vim.notify('Spellcheck: ' .. on)
end, { buffer = 0, desc = 'Toggle spellcheck' })

-- Toggle 'render-markdown.nvim' rendering for this buffer (uppercase = local
-- variant, following 'plugin/20_keymaps.lua' conventions)
vim.keymap.set('n', '<Leader>mR', '<Cmd>RenderMarkdown toggle<CR>', { buffer = 0, desc = 'Toggle markdown render' })

-- Fold with tree-sitter
vim.cmd('setlocal foldmethod=expr foldexpr=v:lua.vim.treesitter.foldexpr()')

-- Disable built-in `gO` mapping in favor of 'mini.basics'
vim.keymap.del('n', 'gO', { buffer = 0 })

-- Set markdown-specific surrounding in 'mini.surround'
vim.b.minisurround_config = {
  custom_surroundings = {
    -- Markdown link. Common usage:
    -- `saiwL` + [type/paste link] + <CR> - add link
    -- `sdL` - delete link
    -- `srLL` + [type/paste link] + <CR> - replace link
    L = {
      input = { '%[().-()%]%(.-%)' },
      output = function()
        local link = require('mini.surround').user_input('Link: ')
        return { left = '[', right = '](' .. link .. ')' }
      end,
    },
  },
}
