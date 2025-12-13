local M = {}

local function has_bat()
  return vim.fn.executable("bat") == 1
end

function M.setup()
  local fzf = require("fzf-lua")
  fzf.setup({
    fzf_opts = {
      ["--layout"] = "default",
      ["--info"] = "inline",
    },
    winopts = {
      height = 0.9,
      width = 0.85,
      border = "rounded",
      preview = {
        layout = "flex",
        flip_columns = 120,
        default = has_bat() and "bat" or "builtin",
      },
    },
    files = {
      fd_opts = "fd --type f --hidden --strip-cwd-prefix --exclude .git",
    },
    git = {
      files = {
        cmd = "git ls-files --cached --others --exclude-standard",
      },
    },
    grep = {
      rg_opts = "--column --line-number --no-heading --color=always --smart-case",
    },
    tmux = {
      enabled = true,
      config = {
        ["-p"] = "90%,80%",
      },
    },
  })

  local map = require("dotfiles.utils.mappings")
  map.register({
    f = {
      name = "󰍉 Find",
      f = {
        function()
          fzf.files()
        end,
        "Files",
      },
      g = {
        function()
          fzf.git_files()
        end,
        "Git files",
      },
      r = {
        function()
          fzf.live_grep()
        end,
        "Ripgrep project",
      },
      b = {
        function()
          fzf.buffers()
        end,
        "Buffers",
      },
      h = {
        function()
          fzf.help_tags()
        end,
        "Help tags",
      },
      c = {
        function()
          fzf.commands()
        end,
        "Commands",
      },
      k = {
        function()
          fzf.keymaps()
        end,
        "Keymaps",
      },
    },
  }, { prefix = "<leader>" })
end

return M
