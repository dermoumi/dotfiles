return {
  "folke/noice.nvim",
  event = "VeryLazy",
  dependencies = {
    "MunifTanjim/nui.nvim",
    "rcarriga/nvim-notify",
  },
  opts = {
    presets = {
      command_palette = true,
    },
    routes = {
      {
        -- Duplicate notifaction for when quitting without saving
        filter = { find = "E162" },
        opts = { skip = true },
      },
      {
        -- Messages when a buffer is written
        filter = { find = ".+B written" },
        opts = { skip = true },
      },
      {
        -- Message when a file is opened
        filter = { find = "^\".+\" %d+L, %d+B$" },
        opts = { skip = true },
      },
      {
        -- Message when a new file is opened
        filter = { find = "^\".+\" %[New%]$" },
        opts = { skip = true },
      },
    },
  },
}
