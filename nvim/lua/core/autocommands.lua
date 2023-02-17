-- Create a group to scope autocommands in
vim.api.nvim_create_augroup("GeneralSettings", {
  clear = true,
})

-- Enable numbers even for help buffers
vim.api.nvim_create_autocmd("FileType", {
  group = "GeneralSettings",
  pattern = { "help", "man" },
  callback = function()
    vim.opt_local.number = true
  end,
})

-- Disable automattic comment insertion on new line from Normal mode
vim.api.nvim_create_autocmd({ "BufWinEnter", "BufNewFile" }, {
  group = "GeneralSettings",
  callback = function()
    vim.opt_local.formatoptions:remove("o")
  end,
})

-- Set different tab stops for some specific file types
vim.api.nvim_create_autocmd("FileType", {
  group = "GeneralSettings",
  pattern = { "python", "zsh" },
  callback = function()
    local tab_width = 4
    vim.opt_local.tabstop = tab_width
    vim.opt_local.shiftwidth = tab_width
  end,
})

-- Automatically remove all trailing whitespace on save
vim.api.nvim_create_autocmd("BufWritePre", {
  group = "GeneralSettings",
  callback = function()
    vim.fn.execute("normal m`")
    vim.fn.execute([[ %s/\s\+$//e ]])
    vim.fn.execute("normal g``")
  end,
})

-- Restore cursor position when opening a file
vim.api.nvim_create_autocmd("BufReadPost", {
  group = "GeneralSettings",
  callback = function()
    local last_line = vim.fn.line("'\"")

    if last_line > 1 and last_line <= vim.fn.line("$") then
      vim.fn.execute("normal! g'\"")
    end
  end,
})

-- Highlight trailing spaces when the cursor is not at their end
vim.api.nvim_create_autocmd("InsertEnter", {
  group = "GeneralSettings",
  command = [[ match ExtraWhitespace /\s\+\%#\@<!$/ ]],
})
vim.api.nvim_create_autocmd("InsertLeave", {
  group = "GeneralSettings",
  command = [[ match ExtraWhitespace /\s\+$/ ]],
})

-- Color changes
local color_scheme_callback = function()
  -- Highlight trailing spaces in non-Insert modes
  vim.api.nvim_set_hl(0, "ExtraWhitespace", {
    fg = "red",
    ctermbg = "red",
  })

  -- Remvoe sign column background
  vim.api.nvim_set_hl(0, "SignColumn", {
    bg = nil,
    ctermbg = nil,
  })
end

vim.api.nvim_create_autocmd("ColorScheme", {
  group = "GeneralSettings",
  callback = color_scheme_callback,
})

color_scheme_callback()
