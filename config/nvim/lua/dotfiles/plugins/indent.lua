local M = {}

function M.setup()
  local ibl = require("ibl")
  ibl.setup({
    indent = {
      char = "│",
      highlight = { "IblIndent" },
    },
    scope = {
      enabled = true,
      char = "│",
      highlight = "IblScope",
    },
    whitespace = {
      remove_blankline_trail = true,
    },
  })
end

return M
