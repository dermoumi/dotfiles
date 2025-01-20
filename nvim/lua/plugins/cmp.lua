return {
  "hrsh7th/nvim-cmp",
  event = { "InsertEnter", "CmdlineEnter" },
  dependencies = {
    "onsails/lspkind-nvim",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-path",
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-cmdline",
  },
  opts = function(_, opts)
    local cmp = require("cmp")

    local close_completion = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.close()
      end

      fallback()
    end, { "i", "c" })

    opts.mapping = {
      ["<C-Space>"] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }),
      ["<Up>"] = cmp.mapping(function(fallback)
        if not cmp.select_prev_item() then
          fallback()
        end
      end, { "i", "c" }),
      ["<Down>"] = cmp.mapping(function(fallback)
        if not cmp.select_next_item() then
          fallback()
        end
      end, { "i", "c" }),
      ["<Left>"] = close_completion,
      ["<Right>"] = close_completion,
      ["<C-u>"] = cmp.mapping(cmp.mapping.scroll_docs(-5), { "i", "c" }),
      ["<C-d>"] = cmp.mapping(cmp.mapping.scroll_docs(5), { "i", "c" }),
      ["<Tab>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.confirm({ select = true })
        else
          fallback()
        end
      end, { "i", "s" }),
    }

    opts.formatting = {
      fields = { "kind", "abbr" },
      format = require("lspkind").cmp_format({
        mode = "symbol",
        symbol_map = {
          Copilot = "",
        },
      })
    }

    opts.sources = {
      { name = "buffer" },
      { name = "nvim_lsp" },
    }

    opts.completion = {
      keyword_length = 2,
    }
  end,
  config = function(_, opts)
    vim.opt.completeopt = { "menu", "menuone", "noselect" }

    local cmp = require("cmp")
    cmp.setup(opts)

    -- Autocomplete for cmdline
    cmp.setup.cmdline(":", {
      mapping = cmp.mapping.preset.cmdline(),
      sources = cmp.config.sources(
        { { name = "path" } },
        { { name = "cmdline" } }
      ),
      matching = { disallow_symbol_nonprefix_matching = false },
    })

    -- Autocompletion for / search
    cmp.setup.cmdline({ "/", "?" }, {
      mapping = cmp.mapping.preset.cmdline(),
      sources = {
        { name = "buffer" },
      },
    })
  end,
}
