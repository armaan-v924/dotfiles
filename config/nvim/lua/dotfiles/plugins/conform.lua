local M = {}

function M.setup()
  require("conform").setup({
    formatters_by_ft = {
      lua = { "stylua" },
      python = { "ruff_format" },
      javascript = { "prettier" },
      typescript = { "prettier" },
      json = { "jq" },
      sh = { "shfmt" },
    },
    format_on_save = function(bufnr)
      local disable_filetypes = { sql = true }
      if disable_filetypes[vim.bo[bufnr].filetype] then
        return
      end
      return { timeout_ms = 500, lsp_fallback = true }
    end,
  })
end

return M
