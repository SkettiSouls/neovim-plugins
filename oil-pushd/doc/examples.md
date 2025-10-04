# Examples
Below are some examples of additional functions you can make using pushd/popd.

## Bounce
This function is useful for quickly jumping to `$HOME` and then returning to whatever you were working on. (I personally bind this to `cd`).
```lua
local oil = require('oil')
local nav = require('oil.navigate')

local function bounce()
  -- Jump to/from `$HOME`.
  if nav.stack[1] ~= vim.env.HOME then
    nav.pushd(vim.env.HOME)
  else
    nav.popd()
  end
end

oil.setup({
  keymaps = {
    ["cd"] = { bounce, desc = "Jump back and forth between $HOME and $PWD" },
  },
})
```
