local M = {}

local palette = {
  bg = "#1e1e1e",
  panel = "#2a2a2a",
  border = "#333333",
  fg = "#d4d4d4",
  muted = "#858585",
  accent = "#569CD6",
  warn = "#D7BA7D",
  err = "#F48771",
  info = "#4FC1FF",
  visual = "#C586C0",
}

local function theme()
  return {
    normal = {
      a = { fg = palette.bg, bg = palette.accent, gui = "bold" },
      b = { fg = palette.fg, bg = palette.panel },
      c = { fg = palette.fg, bg = palette.bg },
    },
    insert = { a = { fg = palette.bg, bg = palette.info, gui = "bold" } },
    visual = { a = { fg = palette.bg, bg = palette.visual, gui = "bold" } },
    replace = { a = { fg = palette.bg, bg = palette.err, gui = "bold" } },
    command = { a = { fg = palette.bg, bg = palette.warn, gui = "bold" } },
    inactive = {
      a = { fg = palette.muted, bg = palette.bg },
      b = { fg = palette.muted, bg = palette.bg },
      c = { fg = palette.muted, bg = palette.bg },
    },
  }
end

function M.setup()
  require("lualine").setup({
    options = {
      theme = theme(),
      globalstatus = true,
      component_separators = { left = " ", right = " " },
      section_separators = { left = "", right = "" },
      disabled_filetypes = { statusline = {}, winbar = {} },
    },
    sections = {
      lualine_a = { { "mode", fmt = function(str) return str:sub(1, 1) end } },
      lualine_b = { { "branch", icon = "󰘬" }, "diff" },
      lualine_c = { { "filename", path = 1 } },
      lualine_x = { { "diagnostics", symbols = { error = "󰅚 ", warn = "󰀪 ", info = "󰋼 " } } },
      lualine_y = { "location" },
      lualine_z = { "progress" },
    },
  })
end

return M
