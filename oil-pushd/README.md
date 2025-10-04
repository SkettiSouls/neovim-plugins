# oil-pushd.nvim
Pushd and popd functionality for [oil.nvim].

## Installation
### Neovim

> :memo: <font color="#0969da">**NOTE:**</font><br>
> **If required by your plugin manager, make sure to mark [oil.nvim] as a dependency.**

Oil-pushd **PROBABLY** installs exactly as expected in your favorite plugin manager, but I cannot make any guarantees, as it's untested.

### Nix wrapper
First, add [my plugin repo](https://codeberg.org/SkettiSouls/neovim-plugins) as a flake input like so:
```nix
inputs.extra-plugins = {
  url = "git+https://codeberg.org/skettisouls/neovim-plugins";
  inputs.nixpkgs.follows = "nixpkgs";
};
```
Then, bring oil-pushd-nvim into Neovim's environment:
```nix
{ pkgs, ... }:
let
  inherit (pkgs)
    neovim-unwrapped
    wrapNeovim
    writeShellApplication
    ;

  system = "YOUR_ARCH";
  inherit (inputs.extra-plugins.packages.${system}) oil-pushd-nvim;

  neovimWrapped = wrapNeovim neovim-unwrapped {
    configure = {
      customRC = "luafile /some/path/init.lua";
      packages.all.start = [ oil-pushd-nvim ];
    };
  }
in
{
  packages.${system}.myNvim = writeShellApplication {
    name = "nvim";
    runtimeInputs = [ pkgs.lazygit ];
    text = ''
      ${neovimWrapped}/bin/nvim "$@"
    '';
  };
}
```

## Configuration
Oil-pushd itself requires no configuration to use, but it is recommended that you add a `pushd` and `popd` keybind to oil like so:
```lua
local oil = require('oil')
local navigate = require('oil.navigate')

oil.setup({
  keymaps = {
    ["gd"] = { navigate.pushd, desc = "Push directory to stack and jump to it" },
    ["gD"] = { navigate.popd, desc = "Pop current directory off stack and return to last directory" },
  },
})
```

## API
- [pushd](doc/api.md#pushd)
- [popd](doc/api.md#popd)
- [stack](doc/api.md#stack)

## Requirements
- Neovim >= 0.8
- [oil.nvim]

<!----->
[oil.nvim]: https://github.com/stevearc/oil.nvim
