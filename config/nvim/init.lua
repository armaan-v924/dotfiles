vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("dotfiles.core").setup()
require("dotfiles.plugins").setup()

local ok, overlay = pcall(require, "dotfiles.overlay")
if ok then
  overlay.setup()
end
