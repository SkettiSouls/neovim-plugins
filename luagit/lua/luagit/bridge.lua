local luagit = require('luagit')
local utils = require('luagit.utils')
local augroup = vim.api.nvim_create_augroup('luagit', { clear = false })

local lazygit_bridge = [[
#!/usr/bin/env bash
# regular files will return two args: `--` `{{filename}}`, COMMIT_EDITMSG returns one: {{filename}}
if [ ${1##*/} == "COMMIT_EDITMSG" ]; then
  nvim $1 # neovim lacks `--remote-wait`, so we have to let this nest.
else
  nvim --server ]] .. vim.fn.serverlist()[1] .. [[ --remote-send "<C-\><C-n>:lua require('luagit.bridge').lazygit_edit('$2')<cr>"
fi
]]

-- Lazygit forces its' preset and template system on you unless you change your
-- config, so to avoid requiring config changes we create a bash script in
-- /tmp/luagit/<nvim_server>/script and disguise it as the vim binary in $PATH.
local function build_bridge()
  local tmpdir = '/tmp/luagit/' .. string.gsub(vim.fn.serverlist()[1], '^.*/', '')
  os.execute('mkdir -p ' .. tmpdir .. '/script')

  -- Edit script has to be in a different directory than the
  -- lazygit wrapper to prevent bash from infinitely recursing
  local tmpfile = tmpdir .. '/script/vim'
  local editor = io.open(tmpfile, 'w')
  editor:write(lazygit_bridge)
  editor:flush()
  editor:close()
  os.execute('chmod +x ' .. tmpfile)

  local tmpfile2 = tmpdir .. '/lazygit'
  local lazygit = io.open(tmpfile2, 'w')
  lazygit:write([[
#!/usr/bin/env bash
EDITOR=vim PATH=]] .. tmpdir .. [[/script:"$PATH" lazygit]])
  lazygit:flush()
  lazygit:close()
  os.execute('chmod +x ' .. tmpfile2)

  vim.g.lazygit_command = 'term://' .. tmpfile2

  -- HACK: Return to lazygit when running `:q`
  vim.api.nvim_create_autocmd('QuitPre', {
    -- once = true,
    group = augroup,
    callback = function()
      if vim.w.lazygit_file then
        vim.cmd('new')
        luagit.open()
        vim.cmd.startinsert()
      end
      -- vim.w.lazygit_file = false
    end
  })
end

local function lazygit_edit(file)
  local git_buf, _ = utils.find_lazygit()

  vim.cmd.edit(file)
  vim.w.lazygit_file = true

  -- Clear cmdline and remove self from history
  vim.cmd('echon " "')
  vim.fn.histdel(':', -1)
end

return {
  build_bridge = build_bridge,
  lazygit_edit = lazygit_edit,
}
