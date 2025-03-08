# Luagit
<!-- Most of this readme is based on the one from oil.nvim because that plugin is goatware and it's readme is nice -->
Plugin for opening [Lazygit](https://github.com/jesseduffield/lazygit) as a Neovim buffer.
<!-- TODO: Demo-->
<!-- TOC -->
- [Installation](#installation)
- [Usage](#usage)
- [Options](#options)
- [API](#api)
- [Nested Sessions](#nested-sessions)
<!-- TOC -->

## Installation
### Neovim
Luagit **PROBABLY** installs exactly as expected in your favorite plugin manager, but I cannot make any guarantees, as it's untested.

### Nix wrapper
First, add Luagit as a flake input like so:
```nix
inputs.luagit = {
  url = "git+https://codeberg.org/skettisouls/luagit";
  inputs.nixpkgs.follows = "nixpkgs";
};
```
Then, bring Luagit into Neovim's environment:
```nix
# Keep in mind, this example does *not* activate luagit, as that is done in your config
{ pkgs, ... }:
let
  inherit (pkgs)
    neovim-unwrapped
    wrapNeovim
    writeShellApplication
    ;

  system = "YOUR_ARCH";

  luagit = inputs.luagit.packages.${system}.luagit;
  neovimWrapped = wrapNeovim neovim-unwrapped {
    configure = {
      customRC = "luafile /some/path/init.lua";
      packages.all.start = [ luagit ];
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

## Usage
First, setup Luagit with:
```lua
require('luagit').setup()
```
Then, either configure Luagit or simply press `<leader>g` to open Lazygit in the current window.

## Options
```lua
require('luagit').setup({
  -- Always enter insert mode when Lazygit window is focused
  insert_on_focus = true,

  -- Default mapping settings, also used to close Lazygit and return from edited files
  open_mapping = '<leader>g',
  open_method = 'replace',

  -- Disable files edited in Lazygit opening in nested sessions
  prevent_nesting = true,
})
```

## API
- [Luagit](doc/api.md#luagit)
  - [luagit.close()](doc/api.md#luagit-close)
  - [luagit.open(method)](doc/api.md#luagit-open-method)
  - [luagit.setup(opts)](doc/api.md#luagit-setup-opts)
- [Utils](doc/api.md#utils)
  - [utils.get_buf_table()](doc/api.md#utils-get_buf_table)
  - [utils.get_win_table()](doc/api.md#utils-get_win_table)
  - [utils.find_lazygit()](doc/api.md#utils-find_lazygit)


## Nested Sessions
Luagit, by default, prevents files edited in Lazygit from creating nested Neovim sessions, without requiring external dependencies or changes to your Lazygit configuration.

- Note that until Neovim reimplements the `--remote-wait` flag, it is impossible to prevent commit message files (`C`) from nesting, unless you use [neovim-remote](https://github.com/mhinz/neovim-remote), which is not only an external dependency, but also requires either rewriting the bridge or editing your Lazygit config.

This behavior is achieved via the `luagit.bridge` module, which creates a Bash script in `/tmp/luagit` that sends Neovim the edit command over the server started for the current instance (see `serverlist()`).

In addition, the Luagit bridge sets the environment for Lazygit to work around a few quirks that affect how Lazygit handles `$EDITOR` (see [this issue](https://github.com/jesseduffield/lazygit/issues/3584)). Lazygit also does not allow for `$EDITOR` to be an arbitrary executable, and will default to `vim` if an unsupported binary is used, which is why we name the Bash script `vim` (see [guessDefaultEditor()](https://github.com/jesseduffield/lazygit/blob/master/pkg/commands/git_commands/file.go#L149-L169) and [getPreset()](https://github.com/jesseduffield/lazygit/blob/master/pkg/config/editor_presets.go#L141-L155)).

Finally, Luagit tracks state for you, so running `:q` or your `open_mapping` while inside an edited file will return to Lazygit instead of closing Neovim, and closing Lazygit will return you to your original buffer instead of whatever file was last edited.

If you would like to disable these workarounds or prevent nesting yourself, the bridge can be disabled with:
```lua
require('luagit').setup({
  prevent_nesting = false,
})
```
