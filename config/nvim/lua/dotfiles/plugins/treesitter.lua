local M = {}

function M.setup()
  require("nvim-treesitter.configs").setup({
    ensure_installed = {
      "lua",
      "bash",
      "python",
      "json",
      "yaml",
      "markdown",
      "markdown_inline",
      "vim",
      "vimdoc",
      "regex",
      "toml",
    },
    highlight = { enable = true },
    indent = { enable = true },
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = "gnn",
        node_incremental = "grn",
        scope_incremental = "grc",
        node_decremental = "grm",
      },
    },
  })
end

return M
