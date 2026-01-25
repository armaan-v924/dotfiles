local M = {}

function M.setup()
  local refactoring = require("refactoring")
  refactoring.setup({})

  pcall(require("telescope").load_extension, "refactoring")
end

return M
