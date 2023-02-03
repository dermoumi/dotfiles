return {
  {
    "echasnovski/mini.nvim",
    config = function()
      -- Nothing to do
    end
  },
  {
    "echasnovski/mini.comment",
    dependencies = "mini.nvim",
    version = false,
    keys = {
      { "gc", mode = { "n", "v", "o" } },
    },
    config = function()
      require("mini.comment").setup()
    end,
  },
  {
    "kylechui/nvim-surround",
    version = "*",
    keys = {
      { "ys", mode = { "n" } },
      { "ds", mode = { "n" } },
      { "cs", mode = { "n" } },
      { "S", mode = { "v" } },
      { "<C-g>s", mode = { "i" } },
      { "<C-g>S", mode = { "i" } },
    },
    config = function()
      require("nvim-surround").setup()
    end,
  },
  {
    "lewis6991/gitsigns.nvim",
    event = "BufRead",
    tag = "release",
    opts = {
      on_attach = function(buf_nr)
        local gs = require("gitsigns")

        vim.keymap.set("n", "]c", function()
          if vim.wo.diff then return "]c" end
          vim.schedule(function() gs.next_hunk() end)
          return "<Ignore>"
        end, {
            desc = "Next hunk",
            buffer = buf_nr,
          })

        vim.keymap.set("n", "[c", function()
          if vim.wo.diff then return "[c" end
          vim.schedule(function() gs.prev_hunk() end)
          return "<Ignore>"
        end, {
            desc = "Prev hunk",
            buffer = buf_nr,
          })

        vim.keymap.set("n", "<leader>hp", gs.preview_hunk, {
          desc = "Previw hunk",
          buffer = buf_nr,
        })
        vim.keymap.set("n", "<leader>hs", ":Gitsigns stage_hunk<CR>", {
          desc = "Stage hunk",
          buffer = buf_nr,
        })
        vim.keymap.set("n", "<leader>hu", gs.undo_stage_hunk, {
          desc = "Undo hunk",
          buffer = buf_nr,
        })
        vim.keymap.set("n", "<leader>hr", ":Gitsigns reset_hunk<CR>", {
          desc = "Revert hunk",
          buffer = buf_nr,
        })
        vim.keymap.set("n", "<leader>hS", gs.stage_buffer, {
          desc = "Stage buffer",
          buffer = buf_nr,
        })
        vim.keymap.set("n", "<leader>hU", gs.reset_buffer, {
          desc = "Reset buffer",
          buffer = buf_nr,
        })
        vim.keymap.set("n", "<leader>hR", gs.reset_buffer_index, {
          desc = "Revert buffer",
          buffer = buf_nr,
        })
        vim.keymap.set("n", "<leader>hb", function()
          gs.blame_line({ full = true })
        end, {
            desc = "Blame line",
            buffer = buf_nr,
          })
        vim.keymap.set("n", "<leader>hB", gs.toggle_current_line_blame, {
          desc = "Toggle current line blame",
          buffer = buf_nr,
        })
        vim.keymap.set("n", "<leader>hd", gs.diffthis, {
          desc = "Show diff",
          buffer = buf_nr,
        })
        vim.keymap.set("n", "<leader>hD", function()
          gs.diffthis("~")
        end, {
            desc = "Show diff to HEAD",
            buffer = buf_nr,
          })
        vim.keymap.set("n", "<leader>hH", gs.toggle_deleted, {
          desc = "Toggle deleted",
          buffer = buf_nr,
        })
      end,
    },
    config = function(_, opts)
      require("gitsigns").setup(opts)
    end,
  }
}
