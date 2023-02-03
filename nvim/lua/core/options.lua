-- indentation
vim.opt.tabstop = 2
vim.opt.softtabstop = -1
vim.opt.shiftwidth = 0
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.smarttab = true
vim.opt.autoindent = true

-- line numbers
vim.opt.number = true
vim.opt.numberwidth = 5
vim.opt.relativenumber = true
vim.opt.signcolumn = "yes"

-- swap and backups
vim.opt.swapfile = false

-- system clipboard
vim.opt.clipboard = "unnamedplus"

-- do not save when switching buffers
vim.opt.hidden = true

-- enable mouse support
vim.opt.mouse = "a"

-- ignore case when searching lowercase terms
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- force splits in specific directions
vim.opt.splitbelow = true
vim.opt.splitright = true

-- enable indentation on breaks
vim.opt.breakindent = true

-- incremental live completion
vim.opt.inccommand = "nosplit"

-- save undo history
vim.opt.undofile = true

-- decrease update time
vim.opt.updatetime = 250

-- color column
vim.opt.colorcolumn = "80"

-- make command bar only visible when being used
vim.opt.cmdheight = 0
