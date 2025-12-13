local M = {}

local sep = package.config:sub(1, 1)

local function join(...)
  return table.concat({ ... }, sep)
end

local function readable(path)
  local stat = vim.loop.fs_stat(path)
  return stat and stat.type == "file"
end

function M.setup()
  local overlay_dir = vim.env.DOTFILES_OVERLAY_DIR
  if not overlay_dir then
    return
  end

  local overlay_nvim = join(overlay_dir, "config", "nvim")
  local overlay_init = join(overlay_nvim, "init.lua")
  if readable(overlay_init) then
    vim.notify("Loading overlay Neovim config", vim.log.levels.INFO, { title = "dotfiles" })
    dofile(overlay_init)
    return
  end

  local overlay_module = join(overlay_nvim, "overlay.lua")
  if readable(overlay_module) then
    dofile(overlay_module)
  end
end

return M
