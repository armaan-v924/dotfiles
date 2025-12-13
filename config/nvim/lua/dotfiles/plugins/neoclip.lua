local M = {}

function M.setup()
  local neoclip = require("neoclip")
  neoclip.setup({
    history = 200,
    enable_persistent_history = true,
    filter = function(data)
      return data.event.regcontents[1] ~= ""
    end,
    keys = {
      telescope = {
        i = {
          select = "<CR>",
          paste = "<c-p>",
          paste_behind = "<c-k>",
          replay = "<c-q>",
          delete = "<c-d>",
        },
      },
    },
  })

  pcall(require("telescope").load_extension, "neoclip")

  local map = require("dotfiles.utils.mappings")
  map.register({
    f = {
      name = "󰍉 Find",
      y = { "<cmd>Telescope neoclip<CR>", "󰅌 Clipboard history" },
    },
  }, { prefix = "<leader>" })
end

return M
