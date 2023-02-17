local util = require("lazy.core.util")

local autoformat = true

local function toggle_autoformat()
  autoformat = not autoformat

  if autoformat then
    util.info("Enabled format on save", { title = "Format" })
  else
    util.warn("Disabled format on save", { title = "Format" })
  end
end

local function format(bufnr)
  if not autoformat then
    return
  end

  local ft = vim.bo[bufnr].filetype
  local sources = require("null-ls.sources")
  local have_nls = #sources.get_available(ft, "NULL_LS_FORMATTING") > 0

  local format_opts = vim.tbl_deep_extend("force", {
    bufnr = bufnr,
    filter = function(client)
      if have_nls then
        return client.name == "null-ls"
      end

      return client.name ~= "null-ls"
    end,
  }, {})

  vim.lsp.buf.format(format_opts)
end

local function on_attach(client, bufnr)
  -- Setup auto formatting
  if client.supports_method("textDocument/formatting") then
    vim.api.nvim_create_autocmd("BufWritePre", {
      group = vim.api.nvim_create_augroup("LspFormat." .. bufnr, {}),
      buffer = bufnr,
      callback = function()
        format(bufnr)
      end,
    })
  end

  -- Setup key maps
  vim.keymap.set("n", "gD", vim.lsp.buf.declaration, {
    buffer = bufnr,
    desc = "Go to declaration",
  })
  vim.keymap.set("n", "<F2>", vim.lsp.buf.rename, {
    buffer = bufnr,
    desc = "Rename symbol",
  })
  vim.keymap.set("n", "K", vim.lsp.buf.hover, {
    buffer = bufnr,
    desc = "Show symbol help",
  })
  vim.keymap.set("n", "<C-i>", vim.lsp.buf.signature_help, {
    buffer = bufnr,
    desc = "Show signature help",
  })
  vim.keymap.set("n", "<leader>Wa", vim.lsp.buf.add_workspace_folder, {
    buffer = bufnr,
    desc = "Add workspace folder",
  })
  vim.keymap.set("n", "<leader>Wr", vim.lsp.buf.remove_workspace_folder, {
    buffer = bufnr,
    desc = "Remove workspace folder",
  })
  vim.keymap.set("n", "<leader>Wl", function()
    vim.notify(table.concat(vim.lsp.buf.list_workspace_folders(), "\n"))
  end, {
    buffer = bufnr,
    desc = "List workspace folders",
  })
end

return {
  {
    "williamboman/mason.nvim",
    config = function(_, opts)
      require("mason").setup(opts)
    end,
  },

  -- Formatting
  {
    "jose-elias-alvarez/null-ls.nvim",
    event = "BufReadPre",
    keys = {
      {
        "<leader>=",
        toggle_autoformat,
        desc = "Toggle autoformat",
        silent = true,
      },
    },
    dependencies = {
      "mason.nvim",
    },
    opts = function()
      local nls = require("null-ls")
      return {
        sources = {
          -- nls.builtins.formatting.prettierd,
          nls.builtins.formatting.stylua,
          nls.builtins.formatting.black,
          nls.builtins.code_actions.eslint,
          -- nls.builtins.diagnostics.flake8,
        },
      }
    end,
  },

  -- Mason-LSPConfig bridge
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = "mason.nvim",
    config = function()
      require("mason-lspconfig").setup({
        automatic_installation = true,
      })
    end,
  },

  -- LSP
  {
    "neovim/nvim-lspconfig",
    dependencies = "mason-lspconfig.nvim",
    event = "BufReadPre",
    opts = {
      -- Options for vim.diagnostic.config()
      diagnostics = {
        underline = true,
        update_in_insert = false,
        virtual_text = { spacing = 4, prefix = "●" },
        severity_sort = true,
      },
      -- Server to load and their config
      servers = {
        lua_ls = {
          settings = {
            Lua = {
              runtime = {
                version = "Lua 5.1",
              },
              diagnostics = {
                globals = {
                  "vim",
                },
              },
              workspace = {
                checkThirdParty = false,
              },
              completion = {
                callSnippet = "Replace",
              },
            },
          },
        },
        pyright = {},
        rust_analyzer = {},
        tsserver = {},
        eslint = {},
        jsonls = {},
      },
      -- Default server options
      server_opts = {
        on_attach = on_attach,
        flags = {
          debounce_text_changes = 150,
        },
      },
    },
    config = function(_, opts)
      local lspconfig = require("lspconfig")

      for server_name, server_config in pairs(opts.servers) do
        local options =
          vim.tbl_deep_extend("force", opts.server_opts, server_config)

        lspconfig[server_name].setup(options)
      end
    end,
  },

  -- Auto-document function signatures
  {
    "ray-x/lsp_signature.nvim",
    lazy = "InsertEnter",
    opts = {
      toggle_key = "<M-x>",
      handler_opts = {
        border = "none",
      },
      extra_trigger_chars = { "(" },
      padding = " ",
      hint_enable = false,
      floating_window_above_cur_line = false,
    },
    config = function(_, opts)
      require("lsp_signature").setup(opts)
    end,
  },
}
