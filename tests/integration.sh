#!/usr/bin/env bash
# A real nvim with the plugin in a real tmxr pane: C-h first moves between
# nvim's splits, then, at nvim's edge, to the tmxr pane on the left.
# Needs `tmxr` and `nvim` on PATH.
set -euo pipefail

repo=$(pwd)
tmp=$(mktemp -d)
if command -v cygpath >/dev/null; then
  repo=$(cygpath -m "$repo")
  tmp=$(cygpath -m "$tmp")
fi
# An isolated server: its own socket, config and data, nothing restored.
export TMXR_TMPDIR="$tmp/sock" XDG_DATA_HOME="$tmp/data" XDG_STATE_HOME="$tmp/state"
printf '[resurrect]\nrestore-on-start = false\nauto-save-minutes = 0\n' >"$tmp/tmxr.toml"
t() { tmxr -L navigator-ci -f "$tmp/tmxr.toml" "$@"; }
trap 't kill-server >/dev/null 2>&1 || true' EXIT

# Wait up to 20 s for `#{format}` in the session to print `want`.
wait_for() {
  local format=$1 want=$2 got=""
  for _ in $(seq 1 100); do
    got=$(t display-message -p -t n "$format" | tr -d '\r')
    [ "$got" = "$want" ] && return 0
    sleep 0.2
  done
  echo "timed out: $format is '$got', want '$want'" >&2
  t capture-pane -p -t n >&2 || true
  exit 1
}

t new-session -d -s n -x 160 -y 40
t split-window -h -t n -- nvim --clean --cmd "set rtp^=$repo" \
  -c "runtime plugin/tmxr-navigator.lua" -c vsplit -c "wincmd l"
wait_for '#{pane_index} #{pane_current_command}' '1 nvim'
sleep 2 # nvim has started; let it finish loading the plugin

t send-keys -t n C-h
sleep 2
wait_for '#{pane_index}' '1' # moved inside nvim, still in its pane
t send-keys -t n C-h
wait_for '#{pane_index}' '0' # at nvim's edge: tmxr moved
echo "integration: ok"
