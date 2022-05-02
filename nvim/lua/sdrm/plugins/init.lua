--[[
  Initializes packer and installs plugins
]]

vim.o.runtimepath = vim.fn.stdpath("data") .. "/site/path/*/start/*," .. vim.o.runtimepath

-- Install packer
local packer_bootstrap = false
local install_path = vim.fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"

if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
  if vim.fn.executable("git") == 0 then
    vim.notify("Git is not installed, please install git to install and setup plugins.")
    return
  end

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
  compile_path = vim.fn.stdpath("data") .. "/site/plugin/packer_compiled.lua",
  display = {
    open_fn = require("packer.util").float,
  },
})

packer.startup(function(use)
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
  -- Check if ffi is available
  local has_ffi, _ = pcall(require, "ffi")
  use({
    "nvim-telescope/telescope-fzf-native.nvim",
    run = "make",
    disable = not has_ffi,
  })

  use("nvim-telescope/telescope-ui-select.nvim")
  use("nvim-telescope/telescope-file-browser.nvim")

  -- telescope
  use({
    "nvim-telescope/telescope.nvim",
    requires = "nvim-lua/plenary.nvim",
    after = {
      "telescope-ui-select.nvim",
      "telescope-file-browser.nvim",
      "telescope-fzf-native.nvim",
    },
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
  use({
    "onsails/lspkind-nvim",
    event = "InsertEnter",
  })

  -- Copilot
  vim.g.copilot_no_tab_map = true
  vim.g.copilot_assume_mapped = true
  vim.g.copilot_tab_fallback = ""
  use({
    "github/copilot.vim",
    event = "InsertEnter",
    setup = function()
    end,
  })

  -- Cmp, autocompletion plugin
  use({
    "hrsh7th/nvim-cmp",
    event = { "InsertEnter", "CmdlineEnter" },
    requires = "L3MON4D3/LuaSnip",
    config = function()
      require("sdrm.plugins.cmp").setup()
    end,
  })
  use({
    "hrsh7th/cmp-path",
    after = "nvim-cmp",
  })
  use({
    "hrsh7th/cmp-buffer",
    after = "nvim-cmp",
  })
  use({
    "hrsh7th/cmp-nvim-lsp",
    after = "nvim-cmp",
  })
  use({
    "saadparwaiz1/cmp_luasnip",
    after = "nvim-cmp",
  })
  use({
    "hrsh7th/cmp-cmdline",
    after = "nvim-cmp",
  })
  use({
    "hrsh7th/cmp-emoji",
    after = "nvim-cmp",
  })
  use({
    "hrsh7th/cmp-calc",
    after = "nvim-cmp",
  })

  -- lsp-config
  use({
    "neovim/nvim-lspconfig",
  })
  use({
    "williamboman/nvim-lsp-installer",
    requires = "nvim-lspconfig",
    config = function()
      require("sdrm.plugins.lspconfig").setup()
    end,
  })

  -- function signature help
  use({
    "ray-x/lsp_signature.nvim",
    config = function()
      require("sdrm.plugins.lsp_signature").setup()
    end,
  })

  -- Highlight, edit, and navigate code using a fast incremental parsing library
  use({
    "nvim-treesitter/nvim-treesitter",
    run = function()
      vim.cmd("TSUpdate")
    end,
  })

  -- Additional textobjects for treesitter
  use({
    "nvim-treesitter/nvim-treesitter-textobjects",
    after = "nvim-treesitter",
    config = function()
      require("sdrm.plugins.treesitter").setup()
    end,
  })

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

  -- Gitgutter
  use({
    "airblade/vim-gitgutter",
    config = function()
      require("sdrm.plugins.gitgutter").setup()
    end,
  })

  -- JS Sort imports
  use({
    "ruanyl/vim-sort-imports",
    run = function()
      os.execute("npm install --global import-sort-cli import-sort-parser-babylon import-sort-parser-typescript import-sort-style-eslint")
    end,
  })

  -- sync packer config
  if packer_bootstrap then
    packer.sync()
  end
end)

