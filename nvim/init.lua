-- utility function to inspect stuff
function _G.put(...)
  local objects = {}
  for i = 1, select("#", ...) do
    local v = select(i, ...)
    table.insert(objects, vim.inspect(v))
  end

  print(table.concat(objects, "\n"))
  return ...
end


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
-- Color column
vim.opt.colorcolumn = "80"

-- highlight on yank
vim.cmd [[
  augroup YankHighlight
    autocmd!
    autocmd TextYankPost * silent! lua vim.highlight.on_yank()
  augroup end
]]

-- general auto commands
vim.cmd [[
augroup general_settings
  autocmd!

  " enable numbers even for help buffers
  autocmd BufWinEnter * setlocal number

  " disable automatic comment insertion
  autocmd BufWinEnter,BufNewFile * setlocal formatoptions-=o

  " Some file types have different tabstops
  autocmd FileType python,zsh setlocal tabstop=4

  " automatically remove all trailing whitespace on save
  autocmd BufWritePre *
    \ execute "normal m`"
    \ | %s/\s\+$//e
    \ | normal g``

  " restore cursor position
  autocmd BufReadPost *
    \ if line("'\"") > 1 && line("'\"") <= line("$")
    \ |    execute "normal! g'\""
    \ | endif
augroup END
]]

-- colors
vim.cmd [[
  " highlight trailing spaces (as long as not in insert mode)
  hi ExtraWhitespace ctermbg=1
  match ExtraWhitespace /\s\+\%#\@<!$/

  " Remove signcolumn background
  hi SignColumn ctermbg=none

  " Floating menus
  hi Pmenu ctermbg=233 ctermfg=244
]]

require("sdrm.keybindings")
require("sdrm.plugins")
require("sdrm.remote")
