local M = {}

local function executable(cmd)
  return vim.fn.executable(cmd) == 1
end

function M.is_available()
  return vim.env.TMUX ~= nil and executable("tmux")
end

function M.popup(command, opts)
  opts = opts or {}
  if not M.is_available() then
    vim.notify("Tmux popup requested but tmux is not available.", vim.log.levels.WARN)
    return
  end

  local width = opts.width or "90%"
  local height = opts.height or "80%"
  local title = opts.title and string.format("-T %q", opts.title) or ""
  local full_cmd = string.format('tmux display-popup %s -w %s -h %s -E "%s"', title, width, height, command)
  vim.fn.jobstart({ "sh", "-c", full_cmd }, { detach = true })
end

return M
