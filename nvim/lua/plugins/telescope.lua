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
          local opts = { hidden = true }
          local tb = require("telescope.builtin")
          local ok = pcall(tb.find_files, opts)
          if not ok then
            tb.fd(opts)
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
    opts = function(_, opts)
      local actions_layout = require("telescope.actions.layout")

      local create_new_file = function(prompt_bufnr)
        local actions_state = require("telescope.actions.state")
        local picker = actions_state.get_current_picker(prompt_bufnr)
        local prompt = picker:_get_prompt()
        if prompt ~= "" then
          vim.cmd("e! " .. prompt)
        end
      end

      opts.defaults = {
        show_line = false,
        prompt_title = "",
        preview_title = false,
        sorting_strategy = "ascending",
        layout_strategy = "vertical",
        layout_config = {
          prompt_position = "top",
          scroll_speed = 5,
          height = 0.95,
          width = function(_, max_columns, _)
            return math.min(math.floor(0.8 * max_columns), 120)
          end,
          preview_height = 0.4,
          vertical = {
            mirror = true,
          }
        },
        winblend = 0,
        mappings = {
          i = {
            ["<esc>"] = "close",
            ["<C-C>"] = { "<Nop>", type = "command" },
            ["<C-u>"] = "preview_scrolling_up",
            ["<C-d>"] = "preview_scrolling_down",
            ["<M-BS>"] = { "<C-W>", type = "command" },
            ["<C-BS>"] = { "<C-W>", type = "command" },
            ["<C-H>"] = { "<C-W>", type = "command" },
            ["<Home>"] = { "<C-O><S-I>", type = "command" },
            ["<End>"] = { "<C-O><S-A>", type = "command" },
            ["<C-\\>"] = actions_layout.toggle_preview,
            ["<C-n>"] = create_new_file,
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
      }

      opts.fzf = {
        fuzzy = true,
        override_generic_sorter = true,
        override_file_sorter = true,
        case_mode = "smart_case",
      }
    end,
    config = function(_, opts)
      local telescope = require("telescope")
      telescope.setup(opts)
      telescope.load_extension("fzf")
    end,
  },
}
