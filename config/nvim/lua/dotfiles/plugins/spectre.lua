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

  local map = require("dotfiles.utils.mappings")
  map.register({
    s = {
      name = "󰈞 Search",
      r = {
        function()
          spectre.open()
        end,
        "󰛔 Search & replace",
      },
      R = {
        function()
          spectre.open_visual({ select_word = true })
        end,
        "󰛔 Replace word",
      },
    },
  }, { prefix = "<leader>" })
end

return M
