local default_config = {
  -- Always enter insert mode when lazygit window is focused
  insert_on_focus = true,

  -- Disable files edited in lazygit opening in nested sessions (uses the server of the current instance)
  prevent_nesting = true,
}

local function setup(opts)
  local lazygit_group = vim.api.nvim_create_augroup('lazygit', { clear = false })
  opts = opts or {}

  local cfg = vim.tbl_deep_extend("keep", opts, default_config)
  if cfg.insert_on_focus then
    vim.api.nvim_create_autocmd({"BufWinEnter", "WinEnter"}, {
      pattern = "term://*:lazygit",
      group = lazygit_group,
      command = "startinsert",
    })
  end

  if cfg.prevent_nesting then
    require('luagit.bridge').prevent_nesting()
  end
end

return { setup = setup }
