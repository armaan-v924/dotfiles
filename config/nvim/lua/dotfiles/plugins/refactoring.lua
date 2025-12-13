local M = {}

function M.setup()
  local refactoring = require("refactoring")
  refactoring.setup({})

  local map = require("dotfiles.utils.mappings")
  map.register({
    c = {
      name = "󰘧 Code",
      R = {
        function()
          refactoring.select_refactor()
        end,
        "󰡱 Refactor",
      },
    },
  }, { prefix = "<leader>", mode = "v" })

  map.register({
    c = {
      name = "󰘧 Code",
      R = {
        function()
          require("telescope").extensions.refactoring.refactors()
        end,
        "󰡱 Refactor menu",
      },
    },
  }, { prefix = "<leader>", mode = "n" })

  pcall(require("telescope").load_extension, "refactoring")
end

return M
