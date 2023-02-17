local set_dark_mode = function()
  vim.o.background = "dark"
end

local set_light_mode = function()
  vim.o.background = "light"
end

local toggle_dark_mode = function()
  if vim.o.background == "dark" then
    set_light_mode()
  else
    set_dark_mode()
  end
end

return {
  {
    "Shatur/neovim-ayu",
    lazy = false,
    keys = {
      {
        "<leader>\\",
        toggle_dark_mode,
        desc = "Toggle dark mode",
      },
    },
    config = function(_, opts)
      require("ayu").setup(opts)
      vim.cmd("colorscheme ayu")
    end,
  },
  {
    "f-person/auto-dark-mode.nvim",
    lazy = false,
    dependencies = {
      "neovim-ayu",
    },
    opts = {
      update_interval = 1000,
      set_dark_mode = set_dark_mode,
      set_light_mode = set_light_mode,
    },
    enabled = vim.loop.os_uname().sysname == "Darwin",
    config = function(_, opts)
      local auto_dark_mode = require("auto-dark-mode")
      auto_dark_mode.setup(opts)
      auto_dark_mode.init()
    end,
  },
}
