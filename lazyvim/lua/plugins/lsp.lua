return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        ["*"] = {
          keys = {
            -- 覆盖原有的 K 键映射
            {
              "K",
              function()
                -- 关键：在调用 hover 时传入 border 参数
                -- vim.lsp.buf.hover({
                --   offset_x = 4,
                --   offset_y = 4,
                --   border = "rounded",
                -- })
                vim.lsp.buf.hover()
              end,
              desc = "Hover (with border)",
            },
          },
        },
        eslint = {},
      },
      setup = {
        eslint = function()
          require("snacks").util.lsp.on(function(_buf, client)
            if client.name == "eslint" then
              client.server_capabilities.documentFormattingProvider = true
            elseif client.name == "tsserver" then
              client.server_capabilities.documentFormattingProvider = false
            end
          end)
        end,
      },
    },
  },
}
