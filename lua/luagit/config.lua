local config = {
  -- Always enter insert mode when lazygit window is focused
  insert_on_focus = true,

  -- Default mapping settings, also used to close lazygit and return from edited files
  open_mapping = '<leader>g',
  open_method = 'replace',

  -- Disable files edited in lazygit opening in nested sessions (uses the server of the current instance)
  prevent_nesting = true,
}

local function setup(opts)
  opts = opts or {}
  config = vim.tbl_deep_extend("keep", opts, config)
  return config
end

return {
  opts = config,
  setup = setup,
}
