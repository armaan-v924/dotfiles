local M = {}

local diagnostics_virtual_text = true

local diagnostic_base_config = {
  virtual_text = {
    spacing = 2,
    prefix = "●",
  },
  severity_sort = true,
  update_in_insert = false,
  float = {
    border = "rounded",
    source = "always",
  },
}

local function apply_diagnostic_config()
  local cfg = vim.deepcopy(diagnostic_base_config)
  cfg.virtual_text = diagnostics_virtual_text and diagnostic_base_config.virtual_text or false
  vim.diagnostic.config(cfg)
end

local function toggle_virtual_text()
  diagnostics_virtual_text = not diagnostics_virtual_text
  apply_diagnostic_config()
  local msg = diagnostics_virtual_text and "Inline diagnostics enabled" or "Inline diagnostics disabled"
  if vim.notify then
    vim.notify(msg, vim.log.levels.INFO, { title = "Diagnostics" })
  end
end

local function on_attach(client, bufnr)
  local map = function(lhs, rhs, desc)
    vim.keymap.set("n", lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
  end

  map("<leader>cd", vim.lsp.buf.definition, "Go to definition")
  map("<leader>cr", vim.lsp.buf.references, "References")
  map("<leader>ci", vim.lsp.buf.implementation, "Go to implementation")
  map("<leader>ca", vim.lsp.buf.code_action, "Code action")
  map("<leader>cf", function()
    vim.lsp.buf.format({ async = true })
  end, "Format buffer")
  map("<leader>crn", vim.lsp.buf.rename, "Rename symbol")
  map("<leader>ce", function()
    vim.diagnostic.open_float(nil, { border = "rounded", focusable = false })
  end, "Line diagnostics")
  map("<leader>cl", vim.diagnostic.setloclist, "Diagnostics to loclist")
  map("<leader>ct", toggle_virtual_text, "Toggle inline diagnostics")
  map("n", "[d", vim.diagnostic.goto_prev, "Prev diagnostic")
  map("n", "]d", vim.diagnostic.goto_next, "Next diagnostic")
end

function M.setup()
  require("mason").setup({
    ui = {
      border = "rounded",
    },
  })

  apply_diagnostic_config()

  local mason_lspconfig = require("mason-lspconfig")
  local has_new_lsp = vim.fn.has("nvim-0.11") == 1 and vim.lsp and vim.lsp.config
  local lspconfig = nil
  if not has_new_lsp then
    lspconfig = require("lspconfig")
  end
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  local ok, cmp_lsp = pcall(require, "cmp_nvim_lsp")
  if ok then
    capabilities = cmp_lsp.default_capabilities(capabilities)
  end

  local function has_cmd(cmd)
    return vim.fn.executable(cmd) == 1
  end

  local servers = {
    lua_ls = {
      settings = {
        Lua = {
          workspace = { checkThirdParty = false },
          diagnostics = { globals = { "vim" } },
        },
      },
    },
    pyright = {},
    bashls = {},
    jsonls = {},
    ts_ls = {},
    marksman = {},
  }

  if has_cmd("cargo") then
    servers.rust_analyzer = {
      settings = {
        ["rust-analyzer"] = {
          cargo = { allFeatures = true },
          checkOnSave = { command = "clippy" },
        },
      },
    }
  else
    vim.schedule(function()
      if vim.notify then
        vim.notify("Skipping rust-analyzer setup (cargo not found in PATH).", vim.log.levels.WARN, { title = "LSP" })
      end
    end)
  end

  local server_names = vim.tbl_keys(servers)

  local function start_with_new_api(server, config)
    config.name = config.name or server
    local filetypes = config.filetypes or {}
    if #filetypes == 0 then
      vim.lsp.start(config)
      return
    end

    local group = vim.api.nvim_create_augroup("DotfilesLsp" .. server, { clear = true })
    vim.api.nvim_create_autocmd("FileType", {
      group = group,
      pattern = filetypes,
      callback = function(args)
        local clients = vim.lsp.get_clients({ name = config.name, bufnr = args.buf })
        if clients ~= nil and #clients > 0 then
          return
        end
        local buf_config = vim.tbl_deep_extend("force", {}, config, { bufnr = args.buf })
        vim.lsp.start(buf_config)
      end,
    })
  end

  local function setup_server(server)
    local opts = {
      capabilities = capabilities,
      on_attach = on_attach,
    }
    local server_opts = servers[server]
    if not server_opts then
      return
    end
    opts = vim.tbl_deep_extend("force", opts, server_opts)
    if has_new_lsp then
      local base = vim.deepcopy(vim.lsp.config[server] or {})
      local config = vim.tbl_deep_extend("force", base, opts)
      vim.lsp.config[server] = config
      start_with_new_api(server, config)
    else
      lspconfig[server].setup(opts)
    end
  end

  if type(mason_lspconfig.setup_handlers) == "function" then
    mason_lspconfig.setup({
      ensure_installed = server_names,
    })

    mason_lspconfig.setup_handlers({
      function(server)
        setup_server(server)
      end,
    })
  else
    mason_lspconfig.setup({
      ensure_installed = server_names,
      handlers = {
        function(server)
          setup_server(server)
        end,
      },
    })
  end
end

return M
