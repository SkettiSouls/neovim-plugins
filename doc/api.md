# API
<!-- TOC -->
- [Luagit](#luagit)
  - [luagit.close()](#luagit-close)
  - [luagit.open(method)](#luagit-open-method)
  - [luagit.setup(opts)](#luagit-setup-opts)
- [Utils](#utils)
  - [utils.get_buf_table()](#utils-get_buf_table)
  - [utils.get_win_table()](#utils-get_win_table)
  - [utils.find_lazygit()](#utils-find_lazygit)
<!-- TOC -->

## Luagit
### luagit.close()
`require('luagit').close()` \
Close the Lazygit window (buffer is hidden, not deleted) \
[source](../lua/luagit/init.lua#L14-L47)

### luagit.open(method)
`require('luagit').open(method)` \
Create Lazygit buffer or open existing buffer in window of type `method` \
[source](../lua/luagit/init.lua#L71-L173)

| Param    | Type                     | Desc                                                              |
| -------- | ------------------------ | ----------------------------------------------------------------- |
| method   | `nil\|luagit.OpenMethod` | Method to use when opening Lazygit, or direction of split         |
| >replace | `string`                 | Open buffer in the current window                                 |
| >tab     | `string`                 | Open buffer as a new tab                                          |
| >split   | `string`                 | Open buffer as a horizontal split                                 |
| >vsplit  | `string`                 | Open buffer as a vertical split                                   |
| >top     | `string`                 | Open buffer as the topmost horizontal split (ignores :splitbelow) |
| >bottom  | `string`                 | Open buffer as the bottommost horizontal split                    |
| >left    | `string`                 | Open buffer as the leftmost vertical split (ignores :splitright)  |
| >right   | `string`                 | Open buffer as the rightmost vertical split                       |

### luagit.setup(opts)
`require('luagit').setup(opts): luagit.Config` \
Initialize Luagit \
[source](../lua/luagit/init.lua#L175-L214)

| Param            | Type                 | Desc                                                       |
| ---------------- | -------------------- | ---------------------------------------------------------- |
| opts             | `nil\|luagit.Config` |                                                            |
| >insert_on_focus | `boolean`            | Always enter insert mode when Lazygit window is focused    |
| >open_mapping    | `string`             | Default mapping for `luagit.open()`                        |
| >open_method     | `luagit.OpenMethod`  | Method to use when invoking `open_mapping`                 |
| >prevent_nesting | `boolean`            | Disable files edited in Lazygit opening in nested sessions |

## Utils
### utils.get_buf_table()
`require('luagit.utils').get_buf_table: table<bufnm, bufnr>` \
Return a table containing all open buffers \
[source](../lua/luagit/utils.lua#L2-L9)

### utils.get_win_table()
`require('luagit.utils').get_win_table: table<winnr, win_bufnm>` \
Return a table containing all windows and the names of their buffers \
[source](../lua/luagit/utils.lua#L12-L21)

### utils.find_lazygit()
`require('luagit.utils).find_lazygit(): nil|bufnm, nil|winnr` \
Return the name of the Lazygit buffer, and the window it's in if Lazygit exists \
[source](../lua/luagit/utils.lua#L25-L40)
