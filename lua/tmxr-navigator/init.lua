--- tmxr-navigator: move between nvim splits and tmxr panes with the same
--- keys, as vim-tmux-navigator does for tmux.
---
--- `navigate("h")` tries `wincmd h`; when the window did not change (nvim's
--- edge) and nvim runs inside tmxr (`$TMXR` is set), it asks tmxr to focus
--- the pane that way. tmxr's own `C-h/j/k/l` binds hand the keys to nvim in
--- the first place: nvim matches its `navigator.pattern`.
local M = {}

local defaults = {
  -- Leave the default C-h/j/k/l/C-\ normal-mode mappings out.
  no_mappings = false,
  -- Stay in nvim at its edge while the tmxr window is zoomed.
  disable_when_zoomed = false,
  -- Before leaving nvim: 0 nothing, 1 `:update` the buffer, 2 `:wall`.
  save_on_switch = 0,
}

M.options = vim.deepcopy(defaults)

local wincmd_to_flag = { h = "-L", j = "-D", k = "-U", l = "-R", p = "-l" }

-- Whether the last move left nvim for another tmxr pane, so "previous"
-- goes back there rather than to nvim's previous window.
local tmxr_was_last = false

--- Whether nvim runs inside a tmxr pane.
function M.in_tmxr()
  local env = vim.env.TMXR
  return env ~= nil and env ~= ""
end

--- Run `tmxr <args>` and return its output, or nil if it failed.
function M.tmxr(args)
  local result = vim.system(vim.list_extend({ "tmxr" }, args), { text = true }):wait()
  if result.code ~= 0 then
    return nil
  end
  return result.stdout
end

local function zoomed()
  local out = M.tmxr({ "display-message", "-p", "#{window_zoomed_flag}" })
  return out ~= nil and vim.trim(out) == "1"
end

local function save()
  local mode = M.options.save_on_switch
  if mode == 1 then
    pcall(vim.cmd, "update")
  elseif mode == 2 then
    pcall(vim.cmd, "wall")
  end
end

--- Move one way: `dir` is `h`, `j`, `k`, `l` or `p` (previous).
function M.navigate(dir)
  local flag = wincmd_to_flag[dir]
  assert(flag, "tmxr-navigator: direction must be h, j, k, l or p")
  if dir == "p" and tmxr_was_last and M.in_tmxr() then
    save()
    M.tmxr({ "select-pane", flag })
    return
  end
  local before = vim.api.nvim_get_current_win()
  pcall(vim.cmd, "wincmd " .. dir)
  local stayed = vim.api.nvim_get_current_win() == before
  if not (stayed and M.in_tmxr()) then
    tmxr_was_last = false
    return
  end
  if M.options.disable_when_zoomed and zoomed() then
    return
  end
  save()
  if M.tmxr({ "select-pane", flag }) ~= nil then
    tmxr_was_last = true
  end
end

M.keys = { ["<C-h>"] = "h", ["<C-j>"] = "j", ["<C-k>"] = "k", ["<C-l>"] = "l", ["<C-\\>"] = "p" }

local mapped = false

--- Configure the plugin; any field of `defaults` may be given. The default
--- mappings follow `no_mappings`, also when `plugin/` already made them
--- (plugin managers load it before calling `setup`).
function M.setup(opts)
  M.options = vim.tbl_deep_extend("force", vim.deepcopy(defaults), opts or {})
  local want = not M.options.no_mappings
  if want == mapped then
    return
  end
  for lhs, dir in pairs(M.keys) do
    if want then
      vim.keymap.set("n", lhs, function()
        M.navigate(dir)
      end, { silent = true, desc = "tmxr-navigator: " .. dir })
    else
      vim.keymap.del("n", lhs)
    end
  end
  mapped = want
end

--- For tests: forget state kept between moves.
function M._reset()
  tmxr_was_last = false
  M.options = vim.deepcopy(defaults)
end

return M
