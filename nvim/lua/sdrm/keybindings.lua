local map = require("sdrm.map")

-- space as leader
vim.g.mapleader = " "

-- reload settings
map("n", "<leader>R", function()
  -- remove all files from lua's loaded packages
  for name, _ in pairs(package.loaded) do
    if string.match(name, "^sdrm") then
      package.loaded[name] = nil
    end
  end

  -- reload the main config file
  dofile(vim.env.MYVIMRC)

  -- reload packer
  local ok, packer = pcall(require, "packer")
  if ok then
    packer.compile()
  end

  print("reloaded!")
end, {
  name = "Reload config",
})

-- delete words with ctrl+backspace (habits die hard)
map("i", "<M-BS>", "<C-W>")
map("i", "<C-BS>", "<C-W>")
map("i", "<C-H>", "<C-W>")

-- deal with line wraps
map("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true })
map("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true })

-- scroll with ctrl+j and ctrl+k
map("", "<C-k>", "5<c-y>")
map("", "<C-j>", "5<c-e>")

-- better shifting
map("v", "<", "<gv")
map("v", ">", ">gv")

-- Y yanks till the end of the line
map("n", "Y", "y$")

-- remove highlight
map("n", "<leader>k", "<cmd>nohlsearch<cr>", {
  name = "Hide highlights",
})

-- go back to previous buffer
map("n", "<leader>;", "<c-^>", {
  name = "Switch to previous buffer",
})

-- escapes the given text to be used with a / search
local function make_pattern(text)
  text = text:gsub("[\\]", "\\%1")
  text = text:gsub("%s+$", "\\s\\*")
  text = text:gsub("^%s+", "\\s\\*")
  text = text:gsub("\n", "\\n")
  text = text:gsub("%s+", "\\s\\+")
  return "\\V" .. text
end

-- highlights all ocurrences of the currently selected text
local function highlight_selection_occurences()
  local original_value = vim.fn.getreg("a") -- save the original @a value

  vim.fn.feedkeys("\"ay", "x")
  local selected_text = vim.fn.getreg("a")

  vim.fn.setreg("a", original_value) -- restore the @a value

  local pattern = make_pattern(selected_text)
  vim.fn.setreg("/", pattern)
  vim.o.hls = true
end

map("v", "<leader>*", highlight_selection_occurences, {
  name = "Highlight all occurrences",
})

map("v", "*", function()
  highlight_selection_occurences()
  vim.fn.feedkeys("n", "x")
end, {
  name = "Hightlight next occurence",
})

map("v", "#", function()
  highlight_selection_occurences()
  vim.fn.feedkeys("N", "x")
end, {
  name = "Highlight previous occurence",
})

map("n", "<leader>*", function()
  local selected_word = vim.fn.expand("<cword>")
  vim.fn.setreg("/", selected_word)
  vim.o.hls = true
end, {
  name = "Highlight all occurences",
})

-- Close current window/buffer
map("n", "<leader>x", "<cmd>close<cr>", {
  name = "Close current buffer",
})

