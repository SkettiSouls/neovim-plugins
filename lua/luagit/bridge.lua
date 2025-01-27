local luagit = require('luagit')
local utils = require('luagit.utils')
local lazygit_bridge = [[
#!/usr/bin/env bash
# regular files will return two args: `--` `{{filename}}`, COMMIT_EDITMSG returns one: {{filename}}
if [ ${1##*/} == "COMMIT_EDITMSG" ]; then
  nvim $1 # neovim lacks `--remote-wait`, so we have to let this nest.
else
  nvim --server ]] .. vim.fn.serverlist()[1] .. [[ --remote-send "<c-\><c-n>:LazygitEdit $2<cr>"
fi
]]

-- Lazygit forces its' preset and template system on you unless you change your config,
-- so to avoid requiring config changes we create a bash script in /tmp/luagit/<nvim_server>
-- and disguise it as the vim binary in $PATH.
local function prevent_nesting()
  local tmpdir = '/tmp/luagit/' .. string.gsub(vim.fn.serverlist()[1], '^.*/', '')
  local tmpfile = tmpdir .. '/vim'
  os.execute('mkdir -p ' .. tmpdir)

  local file = io.open(tmpfile, 'w')
  file:write(lazygit_bridge)
  file:flush()
  file:close()
  os.execute('chmod +x ' .. tmpfile)

  vim.env.EDITOR = 'vim'
  vim.env.PATH = tmpdir .. ':' .. vim.env.PATH

  vim.api.nvim_create_user_command('LazygitEdit', function(tbl)
    vim.cmd.edit(tbl.args)

    local git_buf, _ = utils.find_lazygit()

    -- Prevent moving lazygit instance into the file it's editing. (e.g. open lazygit -> edit file -> open lazygit in file)
    vim.keymap.del('n', '<leader>g')
    vim.keymap.del('n', '<leader>G')
    -- Trigger `QuitPre` event instead of moving lazygit. Writes for convenience.
    vim.keymap.set('n', '<leader>g', function()
      vim.cmd.write()
      vim.cmd.quit()
    end)

    -- HACK: Return to lazygit when running `:q`
    vim.api.nvim_create_autocmd('QuitPre', {
      once = true,
      group = lazygit_group,
      callback = function()
        -- Undo mapping changes
        vim.keymap.del('n', '<leader>g')
        vim.keymap.set('n', '<leader>g', function() luagit.open() end)
        vim.keymap.set('n', '<leader>G', function() luagit.open('vsplit') end)

        vim.cmd('new ' .. git_buf)
        vim.cmd.startinsert()
      end
    })
  end, { nargs = 1, desc = "Handle editing a file from inside lazygit" })
end

return { prevent_nesting = prevent_nesting }
