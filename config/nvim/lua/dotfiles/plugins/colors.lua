local M = {}

local palette = {
  bg = "#1e1e1e",
  panel = "#252526",
  border = "#333333",
  fg = "#d4d4d4",
  muted = "#858585",
  accent = "#569CD6",
  hint = "#4FC1FF",
  warn = "#D7BA7D",
  err = "#F48771",
}

function M.setup()
  local vscode = require("vscode")
  vscode.setup({
    style = "dark",
    italic_comments = true,
    transparent = true,
    disable_nvimtree_bg = true,
    color_overrides = {
      vscBack = palette.bg,
      vscLineNumber = palette.muted,
      vscCursorDarkDark = palette.panel,
    },
  })
  vscode.load()

  local hl = vim.api.nvim_set_hl
  hl(0, "IblIndent", { fg = palette.border, nocombine = true })
  hl(0, "IblScope", { fg = palette.accent, nocombine = true })

  local transparent_groups = {
    "Normal",
    "NormalNC",
    "NormalFloat",
    "FloatBorder",
    "SignColumn",
    "EndOfBuffer",
    "NeoTreeNormal",
    "NeoTreeNormalNC",
  }

  for _, group in ipairs(transparent_groups) do
    hl(0, group, { bg = "none" })
  end
end

return M
