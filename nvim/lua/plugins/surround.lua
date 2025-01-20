return {
  "kylechui/nvim-surround",
  version = "*",
  event = "VeryLazy",
  keys = {
    { "ys", mode = { "n" } },
    { "ds", mode = { "n" } },
    { "cs", mode = { "n" } },
    { "S", mode = { "v" } },
    { "<C-g>s", mode = { "i" } },
    { "<C-g>S", mode = { "i" } },
  },
  config = function(_, opts)
    require("nvim-surround").setup(opts)
  end,
}
