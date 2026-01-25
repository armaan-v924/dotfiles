local M = {}

function M.setup()
  local notify = require("notify")
  notify.setup({
    stages = "fade",
    render = "compact",
    timeout = 3000,
    background_colour = "#000000",
    max_width = 60,
    max_height = 10,
  })
  vim.notify = notify

  require("noice").setup({
    cmdline = {
      view = "cmdline_popup",
      format = {
        cmdline = { pattern = "^:", icon = "", title = "COMMAND" },
        search_down = { kind = "search", pattern = "^/", icon = "", title = "SEARCH ↓" },
        search_up = { kind = "search", pattern = "^%?", icon = "", title = "SEARCH ↑" },
        lua = { pattern = "^:%s*lua%s+", icon = "", title = "LUA" },
        help = { pattern = "^:%s*he?l?p?%s+", icon = "󰞋", title = "HELP" },
      },
    },
    popupmenu = {
      enabled = true,
      backend = "nui",
    },
    messages = {
      view = "mini",
      view_warn = "notify",
      view_error = "notify",
    },
    notify = {
      enabled = false,
    },
    lsp = {
      progress = { enabled = true },
      hover = { enabled = true },
      signature = { enabled = true },
      message = { enabled = true },
    },
    presets = {
      bottom_search = false,
      command_palette = true,
      long_message_to_split = true,
      lsp_doc_border = true,
    },
  })
end

return M
