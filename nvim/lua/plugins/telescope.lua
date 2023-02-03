return {
  {
    "nvim-telescope/telescope-fzf-native.nvim",
    build = "make",
  },
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "telescope-fzf-native.nvim",
    },
    keys = {
      {
        "<leader>ff",
        function()
          local tb = require("telescope.builtin")
          local ok = pcall(tb.find_files)

          if not ok then
            tb.fd({ hidden = true })
          end
        end,
        desc = "Find file…",
      },
      {
        "<leader>fb",
        function()
          require("telescope.builtin").buffers({
            ignore_current_buffer = true,
            sort_lastused = true,
          })
        end,
        desc = "Switch to buffer…",
      },
      {
        "<leader>fr",
        function()
          require("telescope.builtin").oldfiles()
        end,
        desc = "Find recent file…",
      },
      {
        "<leader>fh",
        function()
          require("telescope.builtin").help_tags()
        end,
        desc = "Find help…",
      },
      {
        "<leader>fz",
        function()
          require("telescope.builtin").current_buffer_fuzzy_find()
        end,
        desc = "Fuzzy find…",
      },
      {
        "<leader>ft",
        function()
          require("telescope.builtin").tags()
        end,
        desc = "Fuzzy tags…",
      },
      {
        "<leader>fg",
        function()
          require("telescope.builtin").live_grep()
        end,
        desc = "Live grep…",
      },
      {
        "<leader>fo",
        function()
          require("telescope.builtin").grep_string()
        end,
        desc = "Grep current string…",
      },
      {
        "<leader>f<space>",
        function()
          require("telescope.builtin").resume()
        end,
        desc = "Resume find…",
      },
    },
    opts = {
      fzf = {
        fuzzy = true,
        override_generic_sorter = true,
        override_file_sorter = true,
        case_mode = "smart_case",
      },
      defaults = {
        show_line = false,
        prompt_title = "",
        preview_title = false,
        sorting_strategy = "ascending",
        layout_config = {
          prompt_position = "top",
          preview_width = 0.5,
          scroll_speed = 5,
        },
        winblend = 0,
        mappings = {
          i = {
            ["<esc>"] = "close",
            ["<C-C>"] = { "<Nop>", type = "command" },
            ["<C-K>"] = "preview_scrolling_up",
            ["<C-J>"] = "preview_scrolling_down",
            ["<M-BS>"] = { "<C-W>", type = "command" },
            ["<C-BS>"] = { "<C-W>", type = "command" },
            ["<C-H>"] = { "<C-W>", type = "command" },
          },
        },
        vimgrep_arguments = {
          "rg",
          "--color=never",
          "--no-heading",
          "--with-filename",
          "--line-number",
          "--column",
          "--smart-case",
          "--hidden",
        },
      },
    },
    config = function(_, opts)
      local telescope = require("telescope")
      telescope.setup(opts)
      telescope.load_extension("fzf")
    end,
  },
  {
    "nvim-telescope/telescope-file-browser.nvim",
    dependencies = {
      "telescope.nvim",
    },
    keys = {
      {
        "<leader>fe",
        function()
          require("telescope").extensions.file_browser.file_browser({
            path = "%:p:h",
          })
        end,
        desc = "Open explorer…",
      },
    },
    config = function()
      require("telescope").load_extension("file_browser")
    end,
  },
  {
    "nvim-telescope/telescope-ui-select.nvim",
    dependencies = {
      "telescope.nvim",
    },
    keys = {
      {
        "gr",
        function()
          require("telescope.builtin").lsp_references()
        end,
        desc = "Find references…",
      },
      {
        "gs",
        function()
          require("telescope.builtin").lsp_document_symbols()
        end,
        desc = "Find symbols…",
      },
      {
        "gj",
        function()
          require("telescope.builtin").lsp_dynamic_workspace_symbols({
            ignore_symbols = { "variable" },
          })
        end,
        desc = "Find workspace symbols…",
      },
      {
        "gJ",
        function()
          require("telescope.builtin").lsp_dynamic_workspace_symbols()
        end,
        desc = "which_key_ignore",
      },
      {
        "gd",
        function()
          require("telescope.builtin").lsp_definitions()
        end,
        desc = "Go to definition…",
      },
      {
        "gI",
        function()
          require("telescope.builtin").lsp_implementations()
        end,
        desc = "Go to implementation…",
      },
      {
        "gT",
        function()
          require("telescope.builtin").lsp_type_definitions()
        end,
        desc = "Go to type definition…",
      },
      {
        "ga",
        ":'<,'>lua vim.lsp.buf.range_code_action()<CR>",
        mode = "v",
        desc = "Code actions…",
      },
    },
    config = function()
      require("telescope").load_extension("ui-select")
    end,
  },
}
