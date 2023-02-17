return {
  {
    "L3MON4D3/LuaSnip",
    dependencies = {
      "rafamadriz/friendly-snippets",
    },
    opts = {
      history = true,
      delete_check_events = "TextChanged",
    },
    config = function(_, opts)
      require("luasnip.loaders.from_vscode").lazy_load()
      require("luasnip").setup(opts)
    end,
    keys = {
      {
        "<tab>",
        function()
          return require("luasnip").jumpable(1) and "<Plug>luasnip-jump-next"
            or "<tab>"
        end,
        expr = true,
        silent = true,
        mode = "i",
      },
      {
        "<tab>",
        function()
          require("luasnip").jump(1)
        end,
        mode = "s",
      },
      {
        "<s-tab>",
        function()
          require("luasnip").jump(-1)
        end,
        mode = { "i", "s" },
      },
    },
  },
  {
    "hrsh7th/nvim-cmp",
    event = { "InsertEnter", "CmdlineEnter" },
    dependencies = {
      "onsails/lspkind-nvim",
      "L3MON4D3/LuaSnip",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-emoji",
      "hrsh7th/cmp-calc",
    },
    opts = function(_, opts)
      local cmp = require("cmp")

      local has_words_before = function()
        if vim.api.nvim_buf_get_option(0, "buftype") == "prompt" then
          return false
        end

        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        if col == 0 then
          return false
        end

        local text =
          vim.api.nvim_buf_get_text(0, line - 1, 0, line - 1, col, {})
        return text[1]:match("^%s*$") == nil
      end

      opts.snippet = {
        expand = function(args)
          require("luasnip").lsp_expand(args.body)
        end,
      }

      opts.formatting = {
        format = require("lspkind").cmp_format({
          mode = "symbol",
          symbol_map = { Copilot = "" },
        }),
      }

      opts.mapping = {
        ["<C-Space>"] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }),
        ["<Up>"] = cmp.mapping(function(fallback)
          if not cmp.select_prev_item() then
            fallback()
          end
        end),
        ["<Down>"] = cmp.mapping(function(fallback)
          if not cmp.select_next_item() then
            fallback()
          end
        end),
        ["<C-k>"] = cmp.mapping(cmp.mapping.scroll_docs(-5), { "i", "c" }),
        ["<C-j>"] = cmp.mapping(cmp.mapping.scroll_docs(5), { "i", "c" }),
        ["<Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() and has_words_before() then
            cmp.confirm({
              behavior = cmp.ConfirmBehavior.Replace,
              select = false,
            })
          else
            fallback()
          end
        end, { "i", "s" }),
      }

      opts.sorting = {
        comparators = {
          function(...)
            require("cmp_buffer"):compare_locality(...)
          end,
        },
      }

      opts.sources = {
        { name = "nvim_lsp" },
        { name = "buffer" },
        { name = "path" },
        { name = "calc" },
        { name = "emoji" },
        { name = "nvim_lua" },
        { name = "treesitter" },
        { name = "crates" },
      }
    end,
    config = function(_, opts)
      vim.opt.completeopt = { "menu", "menuone", "noselect" }

      local cmp = require("cmp")
      cmp.setup(opts)

      -- Autocompletion for / search
      cmp.setup.cmdline("/", {
        sources = {
          { name = "buffer" },
        },
      })

      -- Visual aspect
      vim.api.nvim_set_hl(0, "Pmenu", {
        ctermfg = 233,
        ctermbg = 244,
      })

      vim.api.nvim_set_hl(0, "CmpItemMenu", {
        ctermbg = 233,
      })
    end,
  },
}
