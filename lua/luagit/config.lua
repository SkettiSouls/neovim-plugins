local config = {
  -- Always enter insert mode when Lazygit window is focused
  insert_on_focus = true,

  -- Default mapping settings, also used to close Lazygit and return from edited files
  open_mapping = '<leader>g',
  open_method = 'replace',

  -- Disable files edited in Lazygit opening in nested sessions
  prevent_nesting = true,
}

---@class luagit.Config
---@field insert_on_focus? boolean Always enter insert mode when Lazygit window is focused
---@field open_mapping? string Default mapping for `luagit.open()`
---@field open_method? luagit.OpenMethod Method to use when invoking `open_mapping`
---@field prevent_nesting? boolean Disable files edited in Lazygit opening in nested sessions

---@param opts luagit.Config
---@return luagit.Config
local function setup(opts)
  opts = opts or {}
  config = vim.tbl_deep_extend("keep", opts, config)
  return config
end

return {
  opts = config,
  setup = setup,
}
