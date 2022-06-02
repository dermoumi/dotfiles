local Themes = {}

function Themes.setup()
  local map = require("sdrm.map")

  vim.o.termguicolors = true

  local catppuccin = require("catppuccin")
  catppuccin.setup({
    integrations = {
      hop = true
    },
  })

  local set_dark_theme = function()
    vim.g.catppuccin_flavour = "mocha"
    vim.cmd("colorscheme catppuccin")
    -- vim.cmd("hi Normal ctermbg=none guibg=none")
  end

  local set_light_theme = function()
    vim.g.catppuccin_flavour = "latte"
    vim.cmd("colorscheme catppuccin")
  end

  set_dark_theme()

  map("n", "<leader>\\", function()
    if vim.g.catppuccin_flavour == "mocha" then
      set_light_theme()
    else
      set_dark_theme()
    end
  end, {
    name = "Toggle Light/Dark",
  })
end

return Themes
