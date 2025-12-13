local M = {}

function M.setup()
  require("dotfiles.core.options").setup()
  require("dotfiles.core.autocmds").setup()
  require("dotfiles.core.keymaps").setup()
end

return M
