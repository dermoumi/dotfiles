--[[
  Initializes packer and installs plugins
]]

-- Install packer
local packer_bootstrap = false
local install_path = vim.fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"

if vim.fn.executable("git") and vim.fn.empty(vim.fn.glob(install_path)) > 0 then
  packer_bootstrap = vim.fn.system({
    "git",
    "clone",
    "--depth=1",
    "https://github.com/wbthomason/packer.nvim",
    install_path,
  })
end

-- Setup packer
local packer = require("packer")
packer.init({
  -- This file might be different depending on which computer i'm using
  -- So best keep out of the dotfiles repo
  compile_path = vim.fn.stdpath("data") .. "/site/plugin/packer_compiled.lua"
})

packer.startup(function(use)
  -- Check if ffi is available
  local has_ffi, _ = pcall(require, "ffi")

  -- Packer can manage itself
  use("wbthomason/packer.nvim")

  -- hop
  use({
    "phaazon/hop.nvim",
    branch = "v1",
    config = function()
      require("sdrm.plugins.hop").setup()
    end
  })

  -- telescope-fzf
  use({
    "nvim-telescope/telescope-fzf-native.nvim",
    run = "make",
    disable = not has_ffi,
  })

  -- telescope
  use({
    "nvim-telescope/telescope.nvim",
    requires = "nvim-lua/plenary.nvim",
    after = "telescope-fzf-native.nvim",
    config = function()
      require("sdrm.plugins.telescope").setup()
    end,
  })

  -- projects
  use({
    "ahmedkhalf/project.nvim",
    after = "telescope.nvim",
    config = function()
      require("sdrm.plugins.projects").setup()
    end,
  })

  -- comments
  use("b3nj5m1n/kommentary")

  -- surround
  use("tpope/vim-surround")

  -- vim-repeat
  use("tpope/vim-repeat")

  -- Lsp Kind (little icons for each symbol type)
  use("onsails/lspkind-nvim")

  -- Cmp
  use({
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-path",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-cmdline",
    "hrsh7th/nvim-cmp",
    "L3MON4D3/LuaSnip",
    "saadparwaiz1/cmp_luasnip",
  })
  require("sdrm.plugins.cmp").setup()

  -- Emoji autocomplete
  use({
    "hrsh7th/cmp-emoji",
    require = "nvim-cmp",
    event = "InsertEnter",
  })

  -- Calculator autocomplete
  use({
    "hrsh7th/cmp-calc",
    require = "nvim-cmp",
    event = "InsertEnter",
  })

  -- lsp-config
  use({
    "neovim/nvim-lspconfig",
    "williamboman/nvim-lsp-installer",
    after = "cmp-nvim-lsp",
  })
  require("sdrm.plugins.lspconfig").setup()

  -- function signature help
  use("ray-x/lsp_signature.nvim")
  require("sdrm.plugins.lsp_signature").setup()

  -- Highlight, edit, and navigate code using a fast incremental parsing library
  use({
    "nvim-treesitter/nvim-treesitter",
    branch = "0.5-compat",
    run = function()
      vim.cmd("TSUpdate")
    end,
  })

  -- Additional textobjects for treesitter
  use({
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "0.5-compat",
  })

  require("sdrm.plugins.treesitter").setup()

  -- Which key
  use({
    "folke/which-key.nvim",
    config = function()
      require("sdrm.plugins.which_key").setup()
    end,
  })

  -- Prettier
  use({
    "prettier/vim-prettier",
    run = "npm install",
  })

  -- sync packer config
  if packer_bootstrap then
    packer.sync()
  end
end)

