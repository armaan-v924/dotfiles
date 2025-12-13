local M = {}

function M.setup()
  local o = vim.opt
  o.number = true
  o.relativenumber = false
  o.cursorline = true
  o.termguicolors = true
  o.signcolumn = "yes"
  o.expandtab = true
  o.shiftwidth = 2
  o.tabstop = 2
  o.smartindent = true
  o.wrap = false
  o.splitbelow = true
  o.splitright = true
  o.scrolloff = 5
  o.sidescrolloff = 5
  o.ignorecase = true
  o.smartcase = true
  o.incsearch = true
  o.hlsearch = true
  o.clipboard = "unnamedplus"
  o.updatetime = 200
  o.timeout = true
  o.timeoutlen = 400
  o.completeopt = "menuone,noselect"
  o.list = true
  o.listchars = "tab:» ,trail:·,extends:…,precedes:…,nbsp:+"
  o.foldmethod = "expr"
  o.foldexpr = "nvim_treesitter#foldexpr()"
  o.foldlevel = 99
  o.foldlevelstart = 99
  o.foldenable = true

  vim.g.loaded_netrw = 1
  vim.g.loaded_netrwPlugin = 1
end

return M
