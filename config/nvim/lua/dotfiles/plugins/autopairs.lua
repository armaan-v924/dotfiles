local M = {}

function M.setup()
  local autopairs = require("nvim-autopairs")
  autopairs.setup({
    fast_wrap = {
      map = "<M-e>",
    },
  })

  local ok, cmp_autopairs = pcall(require, "nvim-autopairs.completion.cmp")
  if ok then
    local cmp_ok, cmp = pcall(require, "cmp")
    if cmp_ok then
      cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
    end
  end
end

return M
