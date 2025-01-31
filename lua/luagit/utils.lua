---@return table<bufnm, bufnr> Returns a table containing all open buffers
local function get_buf_table()-- {{{
  local buf_table = {}
  for _, i in pairs(vim.api.nvim_list_bufs()) do
    local buf_name = vim.api.nvim_buf_get_name(i)
    buf_table[buf_name] = i
  end
  return buf_table
end-- }}}

---@return table<winnr, win_bufnm> Returns a table containing all windows and the names of their buffers
local function get_win_table()-- {{{
  local win_table = {}
  -- Nvim api uses window id's, but `close` (and presumably other vimscript cmds) use window *number* (the table keys)
  for win, id in pairs(vim.api.nvim_list_wins()) do
    local win_buf = vim.api.nvim_win_get_buf(id)
    local win_buf_name = vim.api.nvim_buf_get_name(win_buf)
    win_table[win_buf_name] = win
  end
  return win_table
end-- }}}

---@return nil|bufnm Name of the Lazygit buffer
---@return nil|winnr Window number containing the Lazygit buffer
local function find_lazygit()-- {{{
  local buf_table = get_buf_table()
  local win_table = get_win_table()

  for k, _ in pairs(buf_table) do
    local git_buf = string.match(k, '^term://.*lazygit')

    if buf_table[git_buf] ~= nil and win_table[git_buf] ~= nil then
      return git_buf, win_table[git_buf]
    elseif buf_table[git_buf] ~= nil then
      return git_buf, nil
    end
  end

  return nil, nil
end-- }}}

return {
  find_lazygit = find_lazygit,
  get_buf_table = get_buf_table,
  get_win_table = get_win_table,
}
