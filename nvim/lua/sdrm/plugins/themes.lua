local Themes = {}

function Themes.setup()
  local map = require("sdrm.map")

  vim.o.termguicolors = true

  local LIGHT_THEME = "github_light"
  local DARK_THEME = "github_dark"

  local set_dark_theme = function()
    vim.o.background = "dark"
    vim.cmd("color " .. DARK_THEME)
    -- vim.cmd("hi Normal ctermbg=none guibg=none")
  end

  local set_light_theme = function()
    vim.o.background = "light"
    vim.cmd("color " .. LIGHT_THEME)
  end

  set_dark_theme()

  map("n", "<leader>\\", function()
    local theme = vim.api.nvim_exec("color", true)

    if theme ~= LIGHT_THEME then
      set_light_theme()
    else
      set_dark_theme()
    end
  end, {
    name = "Toggle Light/Dark",
  })
end

return Themes
