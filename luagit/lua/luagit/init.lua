local utils = require('luagit.utils')
local config = require('luagit.config')
local augroup = vim.api.nvim_create_augroup('luagit', { clear = true })

local function check_alt_file()
  local alt = vim.g.lazygit_alternate_file
  if alt ~= "" then
    vim.cmd.edit(alt)
  else
    vim.cmd.enew()
  end
end

local function close()-- {{{
  local git_buf, git_win = utils.find_lazygit()
  local method = vim.g.lazygit_open_method

  -- Don't run on non-lazygit buffers
  if vim.api.nvim_buf_get_name(0) ~= git_buf then
    return
  end

  -- If we are in the only tab, switch to replace logic (prevent closing neovim)
  if method == 'tab' and vim.fn.tabpagenr('$') == 1 then
    method = 'replace'
  end

  local method_switch = {-- {{{
    -- TODO: Support floating windows
    ['replace'] = check_alt_file,
    ['tab'] = function()
      -- Close lazygit window if other windows have been opened in the tab
      if vim.fn.tabpagewinnr(vim.fn.tabpagenr(), '$') ~= 1 then
        vim.cmd('close ' .. tostring(git_win))
      else
        vim.cmd.quit()
      end
    end,
  }-- }}}

  if method_switch[method] then
    method_switch[method]()
  else
    -- All split types can be closed the same way
    vim.cmd('close ' .. tostring(git_win))
  end
end-- }}}

local function bind_local()-- {{{
  local git_buf_name, _ = utils.find_lazygit()
  local git_buf = utils.get_buf_table()[git_buf_name]

  -- We localize the keybind to close the lazygit window in order to prevent git opening in other terminals.
  vim.keymap.set('t', config.opts.open_mapping, function() close() end, { buffer = git_buf })

  -- Quit without the 'process exited 0' prompt, or when lazygit is hung (i.e. ran command without `; exit` at the end)
  vim.keymap.set('t', '<C-q>', function() vim.cmd('bdelete!') end, { buffer = git_buf })
end-- }}}

---@class luagit.OpenMethod
---@field replace? string Open buffer in the current window
---@field tab? string Open buffer in a new tab
---@field split? string Open buffer as a horizontal split
---@field vsplit? string Open buffer as a vertical split
---@field top? string Open buffer as the topmost horizontal split (ignores :splitbelow)
---@field bottom? string Open buffer as the bottommost horizontal split
---@field left? string Open buffer as the leftmost vertical split (ignores :splitright)
---@field right? string Open buffer as the rightmost vertical split

---@param method? luagit.OpenMethod Method to use when opening Lazygit, or direction of Lazygit split
local function open(method)-- {{{
  local git_buf, _ = utils.find_lazygit()
  method = method or 'replace'

  -- Prevent lazygit instance moving into the file it's editing
  -- (e.g. open lazygit -> edit file -> open lazygit in file)
  if vim.api.nvim_buf_get_name(0) == git_buf then
    -- Run `close()` when triggered inside lazygit
    close()
    return
  elseif vim.w.lazygit_file then
    -- Trigger luagit.bridge QuitPre autocmd when triggered in a file opened by lazygit
    vim.cmd.write()
    vim.cmd.quit()
    return
  end

  vim.g.lazygit_open_method = method
  vim.g.lazygit_alternate_file = vim.api.nvim_buf_get_name(0)

  -- Switch for all open methods
  local method_switch = {-- {{{
    -- TODO: Support floating windows
    ['replace'] = function()
      if git_buf ~= nil then
        vim.cmd.edit(git_buf)
      else
        vim.cmd.edit(vim.g.lazygit_command)
      end
    end,
    ['tab'] = function()
      if git_buf ~= nil then
        vim.cmd.tabedit(git_buf)
      else
        vim.cmd.tabedit(vim.g.lazygit_command)
      end
    end,
    -- Use these to get split direction from your config (i.e. `:set splitright`)
    ['split'] = function()
      if git_buf ~= nil then
        vim.cmd('split ' .. git_buf)
      else
        vim.cmd('split ' .. vim.g.lazygit_command)
      end
    end,
    ['vsplit'] = function()
      if git_buf ~= nil then
        vim.cmd('vsplit ' .. git_buf)
      else
        vim.cmd('vsplit ' .. vim.g.lazygit_command)
      end
    end,
    -- Use these to specify the direction of the split
    ['top'] = function()
      if git_buf ~= nil then
        vim.cmd('aboveleft split ' .. git_buf)
      else
        vim.cmd('aboveleft split ' .. vim.g.lazygit_command)
      end
    end,
    ['bottom'] = function()
      if git_buf ~= nil then
        vim.cmd('belowright split ' .. git_buf)
      else
        vim.cmd('belowright split ' .. vim.g.lazygit_command)
      end
    end,
    ['left'] = function()
      if git_buf ~= nil then
        vim.cmd('aboveleft vsplit ' .. git_buf)
      else
        vim.cmd('aboveleft vsplit ' .. vim.g.lazygit_command)
      end
    end,
    ['right'] = function()
      if git_buf ~= nil then
        vim.cmd('belowright vsplit ' .. git_buf)
      else
        vim.cmd('belowright vsplit ' .. vim.g.lazygit_command)
      end
    end,
  }-- }}}

  if method_switch[method] then
    method_switch[method]()
  else
    vim.notify("Error: Invalid open method '" .. method  .. "'", vim.log.levels.ERROR)
    return
  end

  -- Reformat buffer name
  if not git_buf and vim.g.lazygit_command ~= 'term://lazygit' then
    local git_bufnm, _ = utils.find_lazygit()
    local buf = utils.get_buf_table()[git_bufnm]
    local bufnm = string.gsub(git_bufnm, vim.b.terminal_job_pid .. ':.*', vim.b.terminal_job_pid .. ':lazygit')
    vim.api.nvim_buf_set_name(buf, bufnm)
    -- Neovim stores the old buffer name in a new buffer for the builtin alternate-file
    -- NOTE: This causes new buffers to have higher numbers due to buf + 1 being reserved
    vim.api.nvim_buf_delete(buf + 1, { force = true })
  end

  bind_local()
end-- }}}

local function setup(opts)
  local cfg = config.setup(opts)
  vim.keymap.set('n', cfg.open_mapping, function() open(cfg.open_method) end)

  vim.api.nvim_create_autocmd("TermOpen", {
    pattern = "term://*lazygit",
    group = augroup,
    command = "setlocal nonumber norelativenumber | startinsert"
  })

  if cfg.prevent_nesting then
    require('luagit.bridge').build_bridge()
  else
    vim.g.lazygit_command = 'term://lazygit'
  end

  if cfg.insert_on_focus then
    vim.api.nvim_create_autocmd({"BufWinEnter", "WinEnter"}, {
      pattern = "term://*lazygit",
      group = augroup,
      command = "startinsert",
    })
  end

  -- Return to lazygit's alternate file when closing the process with `q`
  vim.api.nvim_create_autocmd("TermClose", {
    pattern = "term://*lazygit",
    group = augroup,
    callback = function()
      local method = vim.g.lazygit_open_method
      if method == 'replace' or method == 'tab' and vim.fn.tabpagenr() == 1 then
        check_alt_file()
      end

      local git_buf, _ = utils.find_lazygit()
      -- Close the buffer after pressing 'q' (skips having to press enter)
      vim.cmd('bdelete! ' .. git_buf)
    end
  })
end

return {
  close = close,
  open = open,
  setup = setup,
}
