# tmxr-navigator.nvim

Move between nvim splits and [tmxr](https://github.com/kryptic-sh/tmxr) panes
with the same keys: `C-h` / `C-j` / `C-k` / `C-l`, and `C-\` for the previous
one. It does for tmxr what
[vim-tmux-navigator](https://github.com/christoomey/vim-tmux-navigator) does for
tmux.

## How it works

tmxr's default `C-h/j/k/l` binds focus the neighbouring pane, unless the program
in front matches its `navigator.pattern` (nvim does): then the key goes to nvim.
This plugin maps those keys in nvim to `:wincmd h/j/k/l`, and when nvim is
already at its edge that way (the window did not change) and nvim runs inside
tmxr (`$TMXR` is set), it runs `tmxr select-pane -L/-D/-U/-R` instead. Outside
tmxr the keys just move between splits.

`C-\` goes back to the tmxr pane you last left nvim for, or else to nvim's
previous window (`:wincmd p`).

Needs nvim 0.10 or newer (`vim.system`) and `tmxr` on your `PATH` (or the
`executable` option). Without it nvim just stays where it is. On Windows, tmxr
before the release after v0.2.0 gives panes the registry's `PATH` rather than
the one tmxr was started with.

## Install

With [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{ "kryptic-sh/tmxr-navigator.nvim" }
```

or with options:

```lua
{
  "kryptic-sh/tmxr-navigator.nvim",
  opts = {
    disable_when_zoomed = true,
  },
}
```

Any plugin manager works: the plugin maps its keys when it loads.

## Options

| Option                | Default  | What                                                         |
| --------------------- | -------- | ------------------------------------------------------------ |
| `no_mappings`         | `false`  | Leave `C-h/j/k/l` and `C-\` unmapped; use the commands below |
| `disable_when_zoomed` | `false`  | At nvim's edge, stay in nvim while the tmxr window is zoomed |
| `save_on_switch`      | `0`      | Before leaving nvim: `1` `:update` the buffer, `2` `:wall`   |
| `executable`          | `"tmxr"` | The tmxr to run, when it is not `tmxr` on `PATH`             |

`vim.g.tmxr_navigator_no_mappings = true` before the plugin loads also leaves
the mappings out.

## Commands

`:TmxrNavigateLeft`, `:TmxrNavigateDown`, `:TmxrNavigateUp`,
`:TmxrNavigateRight`, `:TmxrNavigatePrevious`, for your own mappings:

```lua
vim.keymap.set("n", "<M-h>", "<Cmd>TmxrNavigateLeft<CR>")
```

## Development

```sh
nvim --headless --clean -l tests/run.lua   # tests; tmxr is stubbed out
bash tests/integration.sh                  # a real nvim in a real tmxr pane
stylua --check .
```

## License

MIT
