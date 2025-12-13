local M = {}

function M.setup()
  vim.opt.foldlevel = 99
  vim.opt.foldlevelstart = 99
  vim.opt.foldenable = true
  vim.opt.foldcolumn = "0"
  vim.opt.foldmethod = "expr"
  vim.opt.foldexpr = "nvim_treesitter#foldexpr()"

  require("ufo").setup({
    provider_selector = function(_, _, _)
      return { "treesitter", "indent" }
    end,
    open_fold_hl_timeout = 120,
  })

  local map = function(lhs, rhs, desc)
    vim.keymap.set("n", lhs, rhs, { desc = desc, silent = true })
  end

  map("zR", require("ufo").openAllFolds, "Open all folds")
  map("zM", require("ufo").closeAllFolds, "Close all folds")
  map("zr", require("ufo").openFoldsExceptKinds, "Open folds except certain kinds")
  map("zm", require("ufo").closeFoldsWith, "Close folds with level")
end

return M
