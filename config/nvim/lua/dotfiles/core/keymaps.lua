local M = {}

local map = vim.keymap.set
local default_opts = { silent = true, noremap = true }

local icons = {
  find = "󰍉",
  git = "󰊢",
  code = "󰘧",
  search = "󰈞",
  tmux = "󰓡",
  buffers = "󰓩",
  windows = "󱂬",
  session = "󰗼",
  save = "󰆓",
  close = "󰅖",
  quit = "󰗼",
  next = "󰒭",
  prev = "󰒮",
  python = "󰌠",
}

local leader_groups = {
  { "<leader>f", group = string.format("%s Find", icons.find) },
  { "<leader>g", group = string.format("%s Git", icons.git) },
  { "<leader>c", group = string.format("%s Code", icons.code) },
  { "<leader>s", group = string.format("%s Search", icons.search) },
  { "<leader>t", group = string.format("%s Tmux", icons.tmux) },
  { "<leader>b", group = string.format("%s Buffers", icons.buffers) },
  { "<leader>w", group = string.format("%s Windows", icons.windows) },
  { "<leader>q", group = string.format("%s Session", icons.session) },
  { "<leader>p", group = string.format("%s Python", icons.python) },
}

function M.setup()
  map({ "n", "v" }, "<Space>", "<Nop>", { silent = true })

  map("n", "<C-h>", "<C-w>h", default_opts)
  map("n", "<C-j>", "<C-w>j", default_opts)
  map("n", "<C-k>", "<C-w>k", default_opts)
  map("n", "<C-l>", "<C-w>l", default_opts)

  map("n", "<C-Up>", ":resize -2<CR>", default_opts)
  map("n", "<C-Down>", ":resize +2<CR>", default_opts)
  map("n", "<C-Left>", ":vertical resize -2<CR>", default_opts)
  map("n", "<C-Right>", ":vertical resize +2<CR>", default_opts)

  map("n", "<leader>ww", "<cmd>w<CR>", { desc = string.format("%s Save", icons.save) })
  map("n", "<leader>wa", "<cmd>wa<CR>", { desc = string.format("%s Save all", icons.save) })
  map("n", "<leader>wc", "<cmd>close<CR>", { desc = string.format("%s Close window", icons.close) })
  map("n", "<leader>bd", "<cmd>bdelete<CR>", { desc = string.format("%s Delete buffer", icons.close) })
  map("n", "<leader>bn", "<cmd>bnext<CR>", { desc = string.format("%s Next buffer", icons.next) })
  map("n", "<leader>bp", "<cmd>bprevious<CR>", { desc = string.format("%s Previous buffer", icons.prev) })
  map("n", "<leader>qq", function()
    local modified = vim.fn.getbufinfo({ bufmodified = 1 })
    if #modified > 0 then
      local choice = vim.fn.confirm("There are unsaved buffers. Save before quitting?", "&Save all\n&Quit anyway\n&Cancel", 3)
      if choice == 1 then
        vim.cmd("wall")
      elseif choice == 2 then
        vim.cmd("qa!")
        return
      else
        return
      end
    end
    vim.cmd("qa")
  end, { desc = string.format("%s Quit all", icons.quit) })
end

function M.leader_groups()
  return leader_groups
end

return M
