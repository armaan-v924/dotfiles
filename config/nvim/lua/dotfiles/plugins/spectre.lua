local M = {}

function M.setup()
  local spectre = require("spectre")
  spectre.setup({
    color_devicons = true,
    highlight = {
      ui = "String",
      search = "DiffChange",
      replace = "DiffDelete",
    },
    mapping = {
      ["toggle_line"] = {
        map = "dd",
        cmd = "<cmd>lua require('spectre').toggle_line()<cr>",
        desc = "Toggle line",
      },
      ["enter_file"] = {
        map = "<CR>",
        cmd = "<cmd>lua require('spectre.actions').select_entry()<cr>",
        desc = "Open file",
      },
    },
  })
end

return M
