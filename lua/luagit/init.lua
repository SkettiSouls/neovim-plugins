local utils = require('luagit.utils')
local lazygit_group = vim.api.nvim_create_augroup('lazygit', { clear = true })

-- We use the name used in vim/neovim
local alternate_file = ""
local git_open_method = ""

local function close()-- {{{
  local _, git_win = utils.find_lazygit()

  if git_open_method ~= 'buf' then
    vim.cmd('close' .. tostring(git_win))
  elseif vim.fn.expand('#') == "" then
    vim.cmd.enew()
  else
    vim.cmd.edit(alternate_file)
  end
end-- }}}

local function bind_local()-- {{{
  local git_buf_name, _ = utils.find_lazygit()
  local git_buf = utils.get_buf_table()[git_buf_name]

  -- We localize the keybind to close the lazygit window in order to prevent git opening in other toggleterm.
  vim.keymap.set('t', '<leader>g', function() close() end, { buffer = git_buf })

  -- Quit without the 'process exited 0' prompt, or when lazygit is hung (i.e. ran command without `; exit` at the end)
  vim.keymap.set('t', '<C-q>', function() vim.cmd('bdelete!') end, { buffer = git_buf })
end-- }}}

local function open_git_buf()-- {{{
  local git_buf, _ = utils.find_lazygit()
  alternate_file = vim.api.nvim_buf_get_name(0)
  git_open_method = 'buf'

  if git_buf ~= nil then
    vim.cmd.edit(git_buf)
  else
    vim.cmd.edit('term://lazygit')
  end

  bind_local()
end-- }}}

local function open_git_split(open)-- {{{
  local git_buf, _ = utils.find_lazygit()
  alternate_file = vim.api.nvim_buf_get_name(0)
  git_open_method = open

  if git_buf ~= nil then
    vim.cmd(open .. " " .. git_buf)
  else
    vim.cmd(open .. " term://lazygit")
  end

  bind_local()
end-- }}}

local function setup(opts)
  local config = require('luagit.config')

  config.setup(opts)
  vim.keymap.set('n', '<leader>g', function() open_git_buf() end)
  vim.keymap.set('n', '<leader>G', function() open_git_split('vsplit') end)

  vim.api.nvim_create_autocmd("TermOpen", {
    pattern = "term://*:lazygit",
    group = lazygit_group,
    command = "setlocal nonumber norelativenumber | startinsert"
  })
end

return {
  close = close,
  open_git_buf = open_git_buf,
  open_git_split = open_git_split,
  setup = setup,
}
