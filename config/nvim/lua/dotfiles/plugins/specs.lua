return {
  {
    "Mofiqul/vscode.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("dotfiles.plugins.colors").setup()
    end,
  },
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = function()
      require("dotfiles.plugins.whichkey").setup()
    end,
  },
  {
    "nvim-tree/nvim-web-devicons",
    lazy = true,
  },
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    config = function()
      require("dotfiles.plugins.lualine").setup()
    end,
  },
  {
    "lewis6991/gitsigns.nvim",
    event = "BufReadPre",
    config = function()
      require("dotfiles.plugins.gitsigns").setup()
    end,
  },
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    },
    cmd = "Telescope",
    config = function()
      require("dotfiles.plugins.telescope").setup()
    end,
  },
  {
    "ibhagwan/fzf-lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("dotfiles.plugins.fzf").setup()
    end,
  },
  {
    "AckslD/nvim-neoclip.lua",
    dependencies = {
      "nvim-telescope/telescope.nvim",
      "kkharji/sqlite.lua",
    },
    event = "TextYankPost",
    init = function()
      local map = require("dotfiles.utils.mappings")
      local function load_and_run(cmd)
        return function()
          local ok, lazy = pcall(require, "lazy")
          if ok then
            lazy.load({ plugins = { "nvim-neoclip.lua" } })
          end
          vim.schedule(function()
            vim.cmd(cmd)
          end)
        end
      end

      map.register({
        f = {
          name = "󰍉 Find",
          y = { load_and_run("Telescope neoclip"), "󰅌 Clipboard history" },
        },
      }, { prefix = "<leader>" })
    end,
    config = function()
      require("dotfiles.plugins.neoclip").setup()
    end,
  },
  {
    "nvim-pack/nvim-spectre",
    cmd = "Spectre",
    dependencies = { "nvim-lua/plenary.nvim" },
    init = function()
      local map = require("dotfiles.utils.mappings")
      local function load_and_call(fn)
        return function()
          local ok, lazy = pcall(require, "lazy")
          if ok then
            lazy.load({ plugins = { "nvim-spectre" } })
          end
          vim.schedule(fn)
        end
      end

      map.register({
        s = {
          name = "󰈞 Search",
          r = { load_and_call(function()
            require("spectre").open()
          end), "󰛔 Search & replace" },
          R = { load_and_call(function()
            require("spectre").open_visual({ select_word = true })
          end), "󰛔 Replace word" },
        },
      }, { prefix = "<leader>" })
    end,
    config = function()
      require("dotfiles.plugins.spectre").setup()
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("dotfiles.plugins.treesitter").setup()
    end,
  },
  {
    "kevinhwang91/promise-async",
    lazy = true,
  },
  {
    "kevinhwang91/nvim-ufo",
    event = "BufReadPost",
    dependencies = { "kevinhwang91/promise-async" },
    config = function()
      require("dotfiles.plugins.ufo").setup()
    end,
  },
  {
    "numToStr/Comment.nvim",
    event = "BufReadPost",
    config = function()
      require("dotfiles.plugins.comment").setup()
    end,
  },
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("dotfiles.plugins.indent").setup()
    end,
  },
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      require("dotfiles.plugins.autopairs").setup()
    end,
  },
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
    config = function()
      require("dotfiles.plugins.noice").setup()
    end,
  },
  {
    "aserowy/tmux.nvim",
    event = "VeryLazy",
    config = function()
      require("dotfiles.plugins.tmux").setup()
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = {
      "williamboman/mason.nvim",
      "neovim/nvim-lspconfig",
    },
    build = ":MasonUpdate",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("dotfiles.plugins.lsp").setup()
    end,
  },
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "saadparwaiz1/cmp_luasnip",
      "L3MON4D3/LuaSnip",
      "rafamadriz/friendly-snippets",
    },
    config = function()
      require("dotfiles.plugins.cmp").setup()
    end,
  },
  {
    "stevearc/conform.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("dotfiles.plugins.conform").setup()
    end,
  },
  {
    "ThePrimeagen/refactoring.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    event = "VeryLazy",
    init = function()
      local map = require("dotfiles.utils.mappings")
      local function load_plugin()
        local ok, lazy = pcall(require, "lazy")
        if ok then
          lazy.load({ plugins = { "refactoring.nvim" } })
        end
      end

      map.register({
        c = {
          name = "󰘧 Code",
          R = { function()
            load_plugin()
            vim.schedule(function()
              require("refactoring").select_refactor()
            end)
          end, "󰡱 Refactor" },
        },
      }, { prefix = "<leader>", mode = "v" })

      map.register({
        c = {
          name = "󰘧 Code",
          R = { function()
            load_plugin()
            vim.schedule(function()
              local telescope = require("telescope")
              pcall(telescope.load_extension, "refactoring")
              telescope.extensions.refactoring.refactors()
            end)
          end, "󰡱 Refactor menu" },
        },
      }, { prefix = "<leader>", mode = "n" })
    end,
    config = function()
      require("dotfiles.plugins.refactoring").setup()
    end,
  },
  {
    "linux-cultist/venv-selector.nvim",
    dependencies = {
      "nvim-telescope/telescope.nvim",
    },
    cmd = { "VenvSelect", "VenvSelectCached" },
    init = function()
      local map = require("dotfiles.utils.mappings")

      local function load_and_run(cmd)
        return function()
          local ok, lazy = pcall(require, "lazy")
          if ok then
            lazy.load({ plugins = { "venv-selector.nvim" } })
          end
          vim.schedule(function()
            vim.cmd(cmd)
          end)
        end
      end

      map.register({
        p = {
          v = { load_and_run("VenvSelect"), "󰌠 Select Python env" },
          r = { load_and_run("VenvSelectCached"), "󰁯 Reuse last env" },
        },
      }, { prefix = "<leader>" })
    end,
    config = function()
      require("dotfiles.plugins.python").setup()
    end,
  },
}
