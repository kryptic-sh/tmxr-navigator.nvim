# Backlog

## Not yet verified

- `tests/integration.sh` (a real nvim in a real tmxr pane) runs in CI on Linux
  and macOS against tmxr v0.2.0. Windows was run by hand against a tmxr build
  with the PATH fix; add it to CI once a tmxr release has that fix (bump
  `TMXR_VERSION` in `ci.yml`).
- `save_on_switch` has no test.

## Not done

- vim-tmux-navigator's `preserve_zoom` (keep a zoomed tmux window zoomed when
  moving) has no counterpart.
- No release yet; plugin managers install from `main`.
