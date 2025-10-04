# API
<!-- TOC -->
- [pushd](#pushd)
- [popd](#popd)
- [stack](#stack)

## pushd()
`require('oil.navigate').pushd(dir)` \
Push `dir` to the front of the stack, and then switch to that directory \
[source](../lua/oil/navigate.lua#L5-L57)

| Param  | Type          | Desc                                                     |
| ------ | ------------- | -------------------------------------------------------- |
| method | `nil\|string` | Target directory (spawns a prompt in cmdline when `nil`) |

## popd()
`require('oil.navigate').popd()` \
Pop the current directory of the stack and return to the previous directory \
[source](../lua/oil/navigate.lua#L59-L77)

## stack
`require('oil.navigate').stack` \
The current state of the directory stack. Used for making your own functions \
[source](../lua/oil/navigate.lua#L3)
