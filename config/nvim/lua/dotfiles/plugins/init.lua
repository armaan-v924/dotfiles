local M = {}

local function bootstrap_lazy()
  local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
  if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
      "git",
      "clone",
      "--filter=blob:none",
      "https://github.com/folke/lazy.nvim.git",
      "--branch=stable",
      lazypath,
    })
  end
  vim.opt.rtp:prepend(lazypath)
end

function M.setup()
  bootstrap_lazy()
  require("lazy").setup("dotfiles.plugins.specs", {
    defaults = { lazy = true },
    ui = {
      border = "rounded",
    },
    change_detection = {
      notify = false,
    },
  })
end

return M
