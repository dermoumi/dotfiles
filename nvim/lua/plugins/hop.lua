return {
  "smoka7/hop.nvim",
  version = "*",
  opts = {
    keys = "etovxqpdygfblzhckisuran",
  },
  keys = {
    {
      "<leader>s",
      function()
        require("hop").hint_char1()
      end,
      mode = { "n", "o", "v" },
      desc = "Hop to char",
    },
    {
      "<leader>f",
      function()
        local dir = require("hop.hint").HintDirection
        require("hop").hint_char1({
          direction = dir.AFTER_CURSOR,
          current_line_only = true,
          dim_unmatched = true,
        })
      end,
      mode = { "n", "o", "v" },
      desc = "Hop forward in line",
    },
    {
      "<leader>F",
      function()
        local dir = require("hop.hint").HintDirection
        require("hop").hint_char1({
          direction = dir.BEFORE_CURSOR,
          current_line_only = true,
        })
      end,
      mode = { "n", "o", "v" },
      desc = "Hop backward in line",
    },
    {
      "<leader>/",
      function()
        require("hop").hint_patterns()
      end,
      mode = { "n", "o", "v" },
      desc = "Hop pattern",
    },
  },
  config = function(_, opts)
    require("hop").setup(opts)

    -- Colors
    vim.api.nvim_set_hl(0, "HopNextKey", {
      fg = "#333333",
      bg = "#E1AF4B",
      ctermfg = 220,
    })

    vim.api.nvim_set_hl(0, "HopNextKey1", {
      fg = "#333333",
      bg = "#E1AF4B",
      ctermfg = 220,
    })

    vim.api.nvim_set_hl(0, "HopNextKey2", {
      fg = "#333333",
      bg = "#E1AF4B",
      ctermfg = 220,
    })
  end,
}
