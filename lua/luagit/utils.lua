local M = {}

M.get_buf_table() = function()-- {{{
  local buf_table = {}
  for _, i in pairs(vim.api.nvim_list_bufs()) do
    local buf_name = vim.api.nvim_buf_get_name(i)
    buf_table[buf_name] = i
  end
  return buf_table
end-- }}}

M.get_win_table() = function()-- {{{
  local win_table = {}
  -- Nvim api uses window id's, but `close` (and presumably other vimscript cmds) use window *number* (the table keys)
  for win, id in pairs(vim.api.nvim_list_wins()) do
    local win_buf = vim.api.nvim_win_get_buf(id)
    local win_buf_name = vim.api.nvim_buf_get_name(win_buf)
    win_table[win_buf_name] = win
  end
  return win_table
end-- }}}

return M
