local function on_attach(_, bufnr)
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
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, {
    buffer = bufnr,
    desc = "List workspace folders",
  })
end

local servers = {
  sumneko_lua = {
    settings = {
      Lua = {
        runtime = {
          version = "Lua 5.1",
        },
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

return {
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = "mason.nvim",
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "sumneko_lua",
        },
      })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = "mason-lspconfig.nvim",
    event = "VeryLazy",
    config = function()
      local lspconfig = require("lspconfig")

      local default_options = {
        on_attach = on_attach,
        flags = {
          debounce_text_changes = 150,
        },
      }

      for server_name, server_config in pairs(servers) do
        local options = vim.tbl_deep_extend(
          "force",
          default_options,
          server_config
        )

        lspconfig[server_name].setup(options)
      end
    end,
  },
  {
    "ray-x/lsp_signature.nvim",
    lazy = "InsertEnter",
    opts = {
      toggle_key = "<M-x>",
      handler_opts = {
        border = "none",
      },
      extra_trigger_chars = {
        "(",
      },
      padding = " ",
      hint_enable = false,
      floating_window_above_cur_line = false,
    },
    config = function(_, opts)
      require("lsp_signature").setup(opts)
    end,
  }
}
