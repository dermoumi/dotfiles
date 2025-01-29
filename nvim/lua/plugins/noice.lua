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
      {
        -- Message when lines are yanked
        filter = { find = "^%d+ lines yanked$" },
        opts = { skip = true },
      },
      {
        -- Message when lines are pasted
        filter = { find = "^%d+ more lines" },
        opts = { skip = true },
      },
      {
        -- Message when lines are removed
        filter = { find = "^%d+ fewer lines" },
        opts = { skip = true },
      },
      {
        -- Message when hopping chars
        filter = { find = "^Hop %d+ char:" },
        opts = { skip = true },
      },
      {
        -- Message when changing large amount of text
        filter = { find = "; before #%d+" },
        opts = { skip = true },
      },
      {
        -- Message when searching for a pattern that does not exist in the page
        filter = { find = "^[/?].+" },
        opts = { skip = true },
      },
      {
        -- Message when lines are de/indented
        filter = { find = "^%d+ lines? [<>]ed %d+ times?$" },
        opts = { skip = true },
      },
    },
  },
}
