local oil = require('oil')
local actions = require('oil.actions')
local dir_stack = {}

local function pushd(dir)-- {{{
  -- Prompt for `dir` if not passed as a parameter
  if dir == nil then
    -- TODO: Make optional floating window prompt
    vim.ui.input({ prompt = 'Enter directory to add to stack: ' }, function(input)
      dir = input
      vim.cmd('echon " "') -- Clear cmd line (prevents errors in the same line)
    end)
  end

  if dir_stack[1] == nil then
    dir_stack[1] = oil.get_current_dir(0)
  end

  -- Show current stack when escape is pressed
  if dir == nil then
    vim.print(dir_stack)
    return
  end

  -- Jump to last directory when enter is pressed
  if dir == "" then
    if dir_stack[2] == nil then
      vim.notify('pushd: no other directory')
    else
      -- Jump to last directory and swap stack position
      local current = dir_stack[1]
      local last = dir_stack[2]
      vim.cmd.lcd(last)
      oil.open(last)
      dir_stack[1] = last
      dir_stack[2] = current
    end
    return
  end

  -- Handle relative paths and special characters
  dir = vim.fn.expand(dir) -- Expand special paths (e.g `~` or $HOME)
  if string.match(dir, '^/') == nil then
    dir = oil.get_current_dir(0) .. dir
  end

  if vim.fn.isdirectory(dir) == 1 then
    dir_stack[1] = oil.get_current_dir(0)
    table.insert(dir_stack, 1, dir)
    vim.cmd.lcd(dir)
    oil.open(dir)
  else
    vim.notify('Error: Directory \'' .. dir .. '\' not found.', vim.log.levels.ERROR)
  end

  vim.print(dir_stack)
end-- }}}

local function popd()-- {{{
  local len = vim.tbl_count(dir_stack)
  if len <= 1 then
    vim.notify('Error: Directory stack empty.', vim.log.levels.ERROR)
    return
  end

  vim.cmd.lcd(dir_stack[2])
  actions.open_cwd.callback()
  table.remove(dir_stack, 1)

  vim.print(dir_stack)

  -- Remove last directory from the stack.
  if vim.tbl_count(dir_stack) == 1 then
    dir_stack[1] = nil
    return
  end
end-- }}}

return {
  pushd = pushd,
  popd = popd,
  stack = dir_stack
}
