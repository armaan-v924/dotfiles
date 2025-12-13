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

end

return M
