local M = {}

function M.setup()
  local venv = require("venv-selector")
  venv.setup({
    auto_refresh = true,
    search = {
      venv_managers = { "poetry", "pipenv", "uv" },
      pipenv_path = ".",
      poetry_path = ".",
      anaconda_envs_path = "~/.conda/envs",
      cwd = vim.fn.getcwd(),
    },
    dap_enabled = false,
  })

  local map = require("dotfiles.utils.mappings")
  map.register({
    p = {
      name = "󰌠 Python",
      v = { "<cmd>VenvSelect<CR>", "󰌠 Select Python env" },
      r = { "<cmd>VenvSelectCached<CR>", "󰁯 Reuse last env" },
    },
  }, { prefix = "<leader>" })
end

return M
