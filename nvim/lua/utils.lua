local M = {}

---Because most plugins are hosted on GitHub, you can use the helper
---function to have less repetition in the following sections.
---@param repo string
---@return string
function M.gh(repo) return 'https://github.com/' .. repo end

function M.map_key(mode, lhs, rhs)
  vim.keymap.set(mode, lhs, rhs, { silent = true })
end

function M.map_cmd(key, cmd)
  vim.keymap.set("n", key, "<Cmd>" .. cmd .. "<CR>", { silent = true })
end

function M.map_lua(key, txt_or_func)
  if type(txt_or_func) == "string" then
    vim.keymap.set("n", key, "<cmd>lua " .. txt_or_func .. "<cr>", { silent = true })
  else
    vim.keymap.set("n", key, txt_or_func, { silent = true })
  end
end

return M

