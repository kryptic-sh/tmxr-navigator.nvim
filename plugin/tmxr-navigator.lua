if vim.g.loaded_tmxr_navigator then
  return
end
vim.g.loaded_tmxr_navigator = true

local commands = {
  TmxrNavigateLeft = "h",
  TmxrNavigateDown = "j",
  TmxrNavigateUp = "k",
  TmxrNavigateRight = "l",
  TmxrNavigatePrevious = "p",
}
for name, dir in pairs(commands) do
  vim.api.nvim_create_user_command(name, function()
    require("tmxr-navigator").navigate(dir)
  end, { desc = "tmxr-navigator: move " .. dir })
end

-- The mappings come with the plugin, as vim-tmux-navigator's do;
-- `vim.g.tmxr_navigator_no_mappings = true` or `setup({ no_mappings = true })`
-- leaves them out.
require("tmxr-navigator").setup({ no_mappings = vim.g.tmxr_navigator_no_mappings == true })
