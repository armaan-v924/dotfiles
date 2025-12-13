local M = {}

function M.setup()
  local telescope = require("telescope")
  telescope.setup({
    defaults = {
      prompt_prefix = "  ",
      selection_caret = " ",
      sorting_strategy = "ascending",
      layout_config = {
        prompt_position = "top",
      },
      mappings = {
        i = {
          ["<C-j>"] = "move_selection_next",
          ["<C-k>"] = "move_selection_previous",
        },
      },
    },
    extensions = {
      fzf = {
        fuzzy = true,
        override_generic_sorter = true,
        override_file_sorter = true,
        case_mode = "smart_case",
      },
    },
  })
  pcall(telescope.load_extension, "fzf")

  local map = require("dotfiles.utils.mappings")
  map.register({
    f = {
      name = "󰍉 Find",
      f = { "<cmd>Telescope find_files<CR>", "󰈔 Files" },
      g = { "<cmd>Telescope live_grep<CR>", "󰱽 Grep" },
      b = { "<cmd>Telescope buffers<CR>", "󰓩 Buffers" },
      r = { "<cmd>Telescope oldfiles<CR>", "󰂖 Recent" },
      s = { "<cmd>Telescope current_buffer_fuzzy_find<CR>", "󰱼 Search buffer" },
    },
    s = {
      name = "󰈞 Search",
      c = { "<cmd>Telescope commands<CR>", "󰘳 Commands" },
      h = { "<cmd>Telescope help_tags<CR>", "󰘐 Help" },
      k = { "<cmd>Telescope keymaps<CR>", "󰘳 Keymaps" },
      t = { "<cmd>Telescope treesitter<CR>", "󰺕 Symbols" },
    },
  }, { prefix = "<leader>" })
end

return M
