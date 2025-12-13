local M = {}

function M.setup()
  require("tmux").setup({
    copy_sync = {
      enable = false,
    },
    navigation = {
      enable_default_keybindings = false,
    },
    resize = {
      enable_default_keybindings = false,
    },
  })

  local tmux_utils = require("dotfiles.utils.tmux")
  local mappings = require("dotfiles.utils.mappings")
  mappings.register({
    t = {
      name = "Tmux",
      g = {
        function()
          tmux_utils.popup("lazygit", { title = "lazygit" })
        end,
        "󰊢 LazyGit popup",
      },
      t = {
        function()
          local shell = vim.env.SHELL or "zsh"
          tmux_utils.popup(shell, { title = "Shell" })
        end,
        "󰞷 Shell popup",
      },
      r = {
        function()
          tmux_utils.popup("npm test", { title = "Tests" })
        end,
        "󰙨 Run tests",
      },
    },
  }, { prefix = "<leader>" })
end

return M
