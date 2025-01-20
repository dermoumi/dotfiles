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
