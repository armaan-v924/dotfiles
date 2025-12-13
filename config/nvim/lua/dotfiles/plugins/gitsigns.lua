local M = {}

function M.setup()
  require("gitsigns").setup({
    signs = {
      add = { text = "│" },
      change = { text = "│" },
      delete = { text = "_" },
      topdelete = { text = "‾" },
      changedelete = { text = "~" },
    },
    preview_config = {
      border = "rounded",
    },
    on_attach = function(bufnr)
      local map = function(lhs, rhs, desc)
        vim.keymap.set("n", lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
      end
      map("<leader>gs", require("gitsigns").stage_hunk, "󰘬 Stage hunk")
      map("<leader>gr", require("gitsigns").reset_hunk, "󰁯 Reset hunk")
      map("<leader>gp", require("gitsigns").preview_hunk, "󰈈 Preview hunk")
      map("<leader>gb", require("gitsigns").blame_line, "󰊢 Blame line")

      local ok, wk = pcall(require, "which-key")
      if ok then
        wk.add({
          { "<leader>g", group = "󰊢 Git", buffer = bufnr },
          { "<leader>gs", desc = "Stage hunk", buffer = bufnr },
          { "<leader>gr", desc = "Reset hunk", buffer = bufnr },
          { "<leader>gp", desc = "Preview hunk", buffer = bufnr },
          { "<leader>gb", desc = "Blame line", buffer = bufnr },
        }, { mode = "n" })
      end
    end,
  })
end

return M
