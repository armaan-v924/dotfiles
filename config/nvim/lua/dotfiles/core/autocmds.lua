local M = {}

function M.setup()
  local augroup = vim.api.nvim_create_augroup
  local autocmd = vim.api.nvim_create_autocmd

  augroup("DotfilesGeneral", { clear = true })

  autocmd("TextYankPost", {
    group = "DotfilesGeneral",
    callback = function()
      vim.highlight.on_yank({ higroup = "IncSearch", timeout = 120 })
    end,
  })

  autocmd("FileType", {
    pattern = { "gitcommit", "markdown" },
    group = "DotfilesGeneral",
    callback = function()
      vim.opt_local.spell = true
      vim.opt_local.wrap = true
    end,
  })
end

return M
