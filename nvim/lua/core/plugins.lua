-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Setup lazy.nvim
require("lazy").setup("plugins", {
  defaults = {
    -- Have all plugins lazy loaded by default
    lazy = true,
  },
  change_detection = {
    -- Disable change detection
    enabled = false,
  },
  install = {
    -- Enable color scheme on startup
    colorscheme = { "ayu" },
  },
  checker = {
    -- Disable check for plugin updates on startup
    -- TODO: Enable this?
    enabled = false,
  },
})

-- <leader>L to open lazy.nvim
vim.keymap.set("n", "<leader>L", "<cmd>Lazy<CR>", {
  desc = "Lazy",
})
