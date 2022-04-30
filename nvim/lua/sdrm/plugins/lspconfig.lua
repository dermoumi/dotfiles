local LspConfig = {}

local function on_attach(_, bufnr)
  local map = require("sdrm.map")

  map("n", "gD", vim.lsp.buf.declaration, {
    buffer_nr = bufnr,
    name = "Go to declaration",
  })
  map("n", "<F2>", vim.lsp.buf.rename, {
    buffer_nr = bufnr,
    name = "Rename symbol",
  })
  map("n", "K", vim.lsp.buf.hover, {
    buffer_nr = bufnr,
    name = "Show symbol help",
  })
  map("n", "<C-i>", vim.lsp.buf.signature_help, {
    buffer_nr = bufnr,
    name = "Show signature help",
  })
  map("n", "<leader>Wa", vim.lsp.buf.add_workspace_folder, {
    buffer_nr = bufnr,
    name = "Add workspace folder",
  })
  map("n", "<leader>Wr", vim.lsp.buf.remove_workspace_folder, {
    buffer_nr = bufnr,
    name = "Remove workspace folder",
  })
  map("n", "<leader>Wl", function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, {
    buffer_nr = bufnr,
    name = "List workspace folders",
  })

  local telescope_loaded = vim.fn.exists(":Telescope")
  if not telescope_loaded then
    map("n", "gd", vim.lsp.buf.definition, {
      buffer_nr = bufnr,
      name = "Go to definition…",
    })
    map("n", "gr", vim.lsp.buf.references, {
      buffer_nr = bufnr,
      name = "Go to references…",
    })
    map("n", "gI", vim.lsp.buf.implementation, {
      buffer_nr = bufnr,
      name = "Go to implementation…",
    })
    map("n", "gT", vim.lsp.buf.type_definition, {
      buffer_nr = bufnr,
      name = "Go to type definition…",
    })
  end
end

local servers = {
  sumneko_lua = {
    settings = {
      Lua = {
        diagnostics = {
          globals = {
            "vim",
            "lvim",
            "packer_plugins",
          },
        },
      },
    },
  },
  pyright = {},
  rust_analyzer = {},
  tsserver = {},
  eslint = {},
}

function LspConfig.setup()
  local ok, lsp_installer_servers = pcall(require, "nvim-lsp-installer.servers")
  if not ok then
    return
  end

  local cmp_ok, cmp_lsp = pcall(require, "cmp_nvim_lsp")
  local cmp_capabilities = cmp_ok and {
    capabilities = cmp_lsp.update_capabilities(vim.lsp.protocol.make_client_capabilities())
  } or {}

  local default_options = {
    on_attach = on_attach,
    flags = {
      debounce_text_changes = 150,
    },
  }

  for server_name, server_config in pairs(servers) do
    local is_available, server = lsp_installer_servers.get_server(server_name)

    if is_available then
      server:on_ready(function ()
        local options = vim.tbl_deep_extend("force", default_options, server_config, cmp_capabilities)
        server:setup(options)
      end)

      if not server:is_installed() then
        -- Queue the server to be installed
        server:install()
      end
    end
  end
end

return LspConfig
