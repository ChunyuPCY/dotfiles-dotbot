local P = {
  name = 'mini.nvim',
}

vim.api.nvim_create_autocmd({
  'UIEnter',
}, {
  once = true,
  callback = function()
    vim.schedule(function()
      PackUtils.load(P, function()
        require('mini.surround').setup {
          mappings = {
            add = 's', -- Add surrounding
            delete = 'sd', -- Delete surrounding
            find = 'sf', -- Find surrounding (to the right)
            find_left = 'sF', -- Find surrounding (to the left)
            highlight = 'sh', -- Highlight surrounding
            replace = 'cs', -- Replace surrounding/change sround
            update_n_lines = 'sn', -- Update `n_lines`
          },
          custom_surroundings = {
            b = {
              input = { '%*%*().-()%*%*' },
              output = { left = '**', right = '**' },
            },
            i = {
              input = { '%*().-()%*' },
              output = { left = '*', right = '*' },
            },
            d = {
              input = { '`().-()`' },
              output = { left = '`', right = '`' },
            },
          },
        }

        local ext3_blocklist = { scm = true, txt = true, yml = true }
        local ext4_blocklist = { json = true, yaml = true }
        require('mini.icons').setup {
          use_file_extension = function(ext, _) return not (ext3_blocklist[ext:sub(-3)] or ext4_blocklist[ext:sub(-4)]) end,
        }

        MiniIcons.mock_nvim_web_devicons()

        require('mini.statusline').setup()
      end)
    end)
  end,
})
