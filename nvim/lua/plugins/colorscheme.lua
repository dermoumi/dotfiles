local set_dark_mode = function()
  vim.o.background = "dark"
  vim.cmd [[ colorscheme gruvbox ]]
end

local set_light_mode = function()
  vim.o.background = "light"
  require("ayu").colorscheme()
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
    "ellisonleao/gruvbox.nvim",
    lazy = false,
    dependencies = {
      "Shatur/neovim-ayu",
    },
    keys = {
      { "<leader>\\", toggle_dark_mode },
    },
    config = function()
      local color_overrides = {
        Normal = {
          bg = "none",
          ctermbg = "none",
        },
      }

      require("gruvbox").setup({
        overrides = color_overrides,
      })

      require("ayu").setup({
        overrides = color_overrides,
      })

      set_dark_mode()
    end,
  },
  {
    "f-person/auto-dark-mode.nvim",
    lazy = false,
    dependencies = {
      "gruvbox.nvim",
      "neovim-ayu",
    },
    opts = {
      update_interval = 1000,
      set_dark_mode = set_dark_mode,
      set_light_mode = set_light_mode,
    },
    enabled = function()
      return vim.loop.os_uname().sysname == "Darwin"
    end,
    config = function(_, opts)
      local auto_dark_mode = require("auto-dark-mode")
      auto_dark_mode.setup(opts)
      auto_dark_mode.init()
    end,
  }
}
