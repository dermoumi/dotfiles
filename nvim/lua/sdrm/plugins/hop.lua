--[[
  Config file for hop.nvim plugin
]]

local M = {}

function M.setup()
  local map = require("sdrm.map")

  require("hop").setup({
    keys = "asdfghjklweruioxcvm"
  })

  -- colors
  vim.cmd [[
    hi HopNextKey ctermfg=220 guifg=#E1AF4B
    hi HopNextKey1 ctermfg=220 guifg=#E1AF4B
    hi HopNextKey2 ctermfg=220 guifg=#E1AF4B
  ]]

  map("nov", "<leader>/", "<cmd>HopPattern<cr>", { name = "Hop pattern" })
  map("nov", "<leader>s", "<cmd>HopChar1AC<cr>", { name = "Hop next char" })
  map("nov", "<leader>S", "<cmd>HopChar1BC<cr>", { name = "Hop previous char" })
  map("nov", "<leader>w", "<cmd>HopWordAC<cr>", { name = "Hop next word" })
  map("nov", "<leader>b", "<cmd>HopWordBC<cr>", { name = "Hop previous word" })
  map("nov", "<leader>t", "<cmd>HopWordCurrentLineAC<cr>", { name = "Hop next word in line" })
  map("nov", "<leader>T", "<cmd>HopWordCurrentLineBC<cr>", { name = "Hop previous word in line" })
end

return M
