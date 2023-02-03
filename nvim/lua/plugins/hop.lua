return {
  "phaazon/hop.nvim",
  branch = "v2",
  keys = {
    {
      "<leader>/",
      function()
        require("hop").hint_patterns()
      end,
      mode = { "n", "o", "v" },
      desc = "Hop pattern",
    },
    {
      "<leader>s",
      function()
        require("hop").hint_char1()
      end,
      mode = { "n", "o", "v" },
      desc = "Hop to char",
    },
    {
      "<leader>w",
      function()
        local dir = require("hop.hint").HintDirection
        require("hop").hint_words({ direction = dir.AFTER_CURSOR })
      end,
      mode = { "n", "o", "v" },
      desc = "Hop to next word",
    },
    {
      "<leader>b",
      function()
        local dir = require("hop.hint").HintDirection
        require("hop").hint_words({ direction = dir.BEFORE_CURSOR })
      end,
      mode = { "n", "o", "v" },
      desc = "Hop to previous word",
    },
    {
      "<leader>t",
      function()
        local dir = require("hop.hint").HintDirection
        require("hop").hint_char1({
          direction = dir.AFTER_CURSOR,
          current_line_only = true,
          hint_offset = -1,
        })
      end,
      mode = { "n", "o", "v" },
      desc = "Hop forward in line",
    },
    {
      "<leader>T",
      function()
        local dir = require("hop.hint").HintDirection
        require("hop").hint_char1({
          direction = dir.BEFORE_CURSOR,
          current_line_only = true,
          hint_offset = 1,
        })
      end,
      mode = { "n", "o", "v" },
      desc = "Hop backward in line",
    },
  },
  config = function()
    require("hop").setup({ keys = "asdfghjklweruioxcvm;" })

    -- Colors
    vim.api.nvim_set_hl(0, "HopNextKey", {
      fg = "#E1AF4B",
      ctermfg = 220,
    })
    vim.api.nvim_set_hl(0, "HopNextKey1", {
      fg = "#E1AF4B",
      ctermfg = 220,
    })
    vim.api.nvim_set_hl(0, "HopNextKey2", {
      fg = "#E1AF4B",
      ctermfg = 220,
    })
  end
}
