local M = {}

local function has_which_key()
  local ok, wk = pcall(require, "which-key")
  if ok then
    return wk
  end
end

local function is_mapping(entry)
  return type(entry) == "table" and entry[1] ~= nil
end

local function gather_spec(node, prefix, spec, mode)
  if node.name and prefix ~= "" then
    table.insert(spec, { prefix, group = node.name, mode = mode })
  end

  for key, value in pairs(node) do
    if key ~= "name" then
      if is_mapping(value) then
        local lhs = prefix .. key
        local rhs = value[1]
        local desc = value[2]
        table.insert(spec, { lhs, rhs, desc = desc, mode = mode })
      elseif type(value) == "table" then
        gather_spec(value, prefix .. key, spec, mode)
      end
    end
  end
end

local function apply(tbl, opts, prefix)
  prefix = prefix or ""
  local mode = opts.mode or "n"
  for key, value in pairs(tbl) do
    if key == "name" then
      goto continue
    end
    if is_mapping(value) then
      local lhs = prefix .. key
      local rhs = value[1]
      local desc = value[2]
      local map_opts = { silent = opts.silent ~= false, desc = desc, noremap = true }
      map_opts = vim.tbl_extend("force", map_opts, opts.map_opts or {})
      vim.keymap.set(mode, lhs, rhs, map_opts)
    elseif type(value) == "table" then
      apply(value, opts, prefix .. key)
    end
    ::continue::
  end
end

function M.register(mappings, opts)
  opts = opts or {}
  apply(mappings, opts, opts.prefix or "")

  local wk = has_which_key()
  if wk then
    local spec = {}
    gather_spec(mappings, opts.prefix or "", spec, opts.mode or "n")
    if #spec > 0 then
      wk.add(spec)
    end
  end
end

return M
