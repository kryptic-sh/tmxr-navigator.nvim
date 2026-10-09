-- Headless tests: nvim --headless --clean -l tests/run.lua
-- The `tmxr` command is replaced by a recorder, so no tmxr is needed.
vim.opt.runtimepath:prepend(vim.fn.getcwd())
vim.cmd.runtime("plugin/tmxr-navigator.lua")

local nav = require("tmxr-navigator")
local calls, replies, failures = {}, {}, 0

local real_tmxr = nav.tmxr
nav.tmxr = function(args)
  table.insert(calls, table.concat(args, " "))
  return replies[args[1]] or ""
end

local function reset(in_tmxr)
  nav._reset()
  calls, replies = {}, {}
  vim.cmd("silent! only")
  vim.env.TMXR = in_tmxr and "/tmp/tmxr-1000/default,1,$0" or nil
end

local function check(name, fn)
  local ok, err = pcall(fn)
  if ok then
    print("ok   " .. name)
  else
    failures = failures + 1
    print("FAIL " .. name .. ": " .. tostring(err))
  end
end

local function eq(got, want)
  if not vim.deep_equal(got, want) then
    error(("got %s, want %s"):format(vim.inspect(got), vim.inspect(want)), 2)
  end
end

check("at nvim's edge inside tmxr, tmxr moves", function()
  reset(true)
  nav.navigate("h")
  eq(calls, { "select-pane -L" })
end)

check("a split in the way is moved to first", function()
  reset(true)
  vim.cmd("vsplit")
  vim.cmd("wincmd h")
  local left = vim.api.nvim_get_current_win()
  nav.navigate("l")
  eq(calls, {})
  assert(vim.api.nvim_get_current_win() ~= left, "moved to the right split")
  nav.navigate("l")
  eq(calls, { "select-pane -R" })
end)

check("outside tmxr nothing is asked of it", function()
  reset(false)
  nav.navigate("j")
  eq(calls, {})
end)

check("previous goes back to the tmxr pane last left for", function()
  reset(true)
  nav.navigate("k")
  nav.navigate("p")
  eq(calls, { "select-pane -U", "select-pane -l" })
end)

check("previous is nvim's own after a move inside nvim", function()
  reset(true)
  vim.cmd("split") -- the cursor is in the top window
  local top = vim.api.nvim_get_current_win()
  nav.navigate("j")
  nav.navigate("p")
  eq(calls, {})
  eq(vim.api.nvim_get_current_win(), top)
end)

check("disable_when_zoomed keeps nvim focused in a zoomed window", function()
  reset(true)
  nav.setup({ disable_when_zoomed = true })
  replies["display-message"] = "1\n"
  nav.navigate("l")
  eq(calls, { "display-message -p #{window_zoomed_flag}" })
  replies["display-message"] = "0\n"
  calls = {}
  nav.navigate("l")
  eq(calls, { "display-message -p #{window_zoomed_flag}", "select-pane -R" })
end)

check("default mappings come and go with no_mappings", function()
  reset(true)
  nav.setup({})
  assert(vim.fn.maparg("<C-h>", "n") ~= "", "C-h mapped")
  nav.setup({ no_mappings = true })
  eq(vim.fn.maparg("<C-h>", "n"), "")
  eq(vim.fn.maparg("<C-\\>", "n"), "")
  nav.setup({})
  assert(vim.fn.maparg("<C-l>", "n") ~= "", "mapped again")
end)

check("a tmxr that cannot be started is a quiet failure", function()
  reset(true)
  nav.setup({ executable = "tmxr-not-installed-anywhere" })
  eq(real_tmxr({ "select-pane", "-L" }), nil)
end)

check("commands exist", function()
  for _, name in ipairs({
    "TmxrNavigateLeft",
    "TmxrNavigateDown",
    "TmxrNavigateUp",
    "TmxrNavigateRight",
    "TmxrNavigatePrevious",
  }) do
    eq(vim.fn.exists(":" .. name), 2)
  end
end)

if failures > 0 then
  print(failures .. " failed")
  os.exit(1)
end
print("all passed")
