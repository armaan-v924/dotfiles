local M = {}

function M.setup()
  local wk = require("which-key")
  wk.setup({
    plugins = {
      spelling = { enabled = true },
    },
    win = {
      border = "rounded",
    },
  })

  local leader_groups = require("dotfiles.core.keymaps").leader_groups()
  wk.add(leader_groups)
end

return M
