-- Leader
vim.g.mapleader = " "
vim.g.maplocalleader = " "

local opt = vim.opt

opt.laststatus = 0
opt.scrolloff = 4
opt.pumblend = 10
opt.pumheight = 10
opt.clipboard = "unnamedplus"
opt.hidden = true
opt.mouse = "a"
opt.inccommand = "nosplit"
opt.updatetime = 200
opt.cmdheight = 0
opt.termguicolors = true
opt.colorcolumn = "80"
opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize" }
opt.spelllang = { "en" }
opt.wildmode = "longest:full,full" -- Command-line completion mode
opt.formatoptions = "jcroqlnt" -- tcqj
opt.grepformat = "%f:%l:%c:%m"
opt.grepprg = "rg --vimgrep"
opt.autowrite = true -- Enable auto write
opt.wrap = false

if vim.fn.has("nvim-0.9.0") == 1 then
  opt.splitkeep = "screen"
  opt.shortmess:append({ C = true })
end

-- Indentation
opt.tabstop = 2
opt.softtabstop = -1
opt.shiftwidth = 2
opt.shiftround = true
opt.expandtab = true
opt.smartindent = true
opt.smarttab = true
opt.autoindent = true
opt.breakindent = true

-- Line numbers
opt.number = true
opt.numberwidth = 5
opt.relativenumber = true
opt.signcolumn = "yes"

-- Ignore case when searching lowercase terms
opt.ignorecase = true
opt.smartcase = true

-- Force splits in specific directions
opt.splitbelow = true
opt.splitright = true

-- Save undo history
opt.undofile = true
opt.undolevels = 10000
opt.swapfile = false

-- Fix markdown indentation settings
vim.g.markdown_recommended_style = 0

-- Setup python if exists
local pyenv_path
if vim.fn.executable("pyenv") == 1 then
  local output = vim.system({"pyenv", "prefix", "nvim"}, { text = true }):wait()
  if output.code == 0 then
    pyenv_path = vim.trim(output.stdout) .. "/bin/python"
  end
end

if pyenv_path then
  vim.g.python3_host_prog = pyenv_path
end

-- Setup clipboard on WSL2
vim.opt.clipboard = "unnamedplus"

if vim.fn.has('wsl') == 1 then
  vim.api.nvim_create_autocmd('TextYankPost', {
    group = vim.api.nvim_create_augroup('Yank', { clear = true }),
    callback = function()
      vim.fn.system('clip.exe', vim.fn.getreg('"'))
    end,
  })
end

