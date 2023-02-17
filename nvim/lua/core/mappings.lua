-- Save with ctrl+s (habits, you know)
vim.keymap.set({ "i", "n" }, "<C-s>", "<cmd>w<cr>")

-- Easily navigate through wrapped lines
vim.keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true })
vim.keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true })

-- Scroll with ctrl+j and ctrl+k
vim.keymap.set("", "<C-k>", "5<c-y>")
vim.keymap.set("", "<C-j>", "5<c-e>")

-- Better shifting
vim.keymap.set("v", "<", "<gv")
vim.keymap.set("v", ">", ">gv")

-- Y yanks till the end of the line
vim.keymap.set("n", "Y", "y$")

-- Remove highlight
vim.keymap.set("n", "<leader>k", "<cmd>nohlsearch<cr>", {
  desc = "Hide highlights",
})

-- Go back to previous buffer
vim.keymap.set("n", "<leader>;", "<c-^>", {
  desc = "Switch to previous buffer",
})

-- Escapes the given text to be used with a / search
local function make_pattern(text)
  text = text:gsub("[\\]", "\\%1")
  text = text:gsub("%s+$", "\\s\\*")
  text = text:gsub("^%s+", "\\s\\*")
  text = text:gsub("\n", "\\n")
  text = text:gsub("%s+", "\\s\\+")
  return "\\V" .. text
end

-- Highlights all ocurrences of the currently selected text
local function highlight_selection_occurences()
  local original_value = vim.fn.getreg("a") -- save the original @a value

  vim.fn.feedkeys('"ay', "x")
  local selected_text = vim.fn.getreg("a")

  vim.fn.setreg("a", original_value) -- restore the @a value

  local pattern = make_pattern(selected_text)
  vim.fn.setreg("/", pattern)
  vim.o.hls = true
end

vim.keymap.set("v", "<leader>*", highlight_selection_occurences, {
  desc = "Highlight all occurrences",
})

vim.keymap.set("v", "*", function()
  highlight_selection_occurences()
  vim.fn.feedkeys("n", "x")
end, {
  desc = "Hightlight next occurence",
})

vim.keymap.set("v", "#", function()
  highlight_selection_occurences()
  vim.fn.feedkeys("N", "x")
end, {
  desc = "Highlight previous occurence",
})

vim.keymap.set("n", "<leader>*", function()
  local selected_word = vim.fn.expand("<cword>")
  vim.fn.setreg("/", selected_word)
  vim.o.hls = true
end, {
  desc = "Highlight all occurences",
})

-- Close current window/buffer
vim.keymap.set("n", "<leader>d", "<cmd>close<cr>", {
  desc = "Close current window",
})
vim.keymap.set("n", "<leader>x", "<cmd>bd<cr>", {
  desc = "Close current buffer",
})

-- Show code actions window
vim.keymap.set("n", "ga", vim.lsp.buf.code_action, {
  desc = "Code actions",
})
vim.keymap.set("n", "", vim.lsp.buf.code_action, {
  desc = "Code actions",
})

-- Navigate through diagnostics
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, {
  desc = "Previous diagnostic",
})
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, {
  desc = "Next diagnostic",
})

-- Toggle text wrap
vim.keymap.set("n", "<leader>w", "<cmd>set wrap!<cr>", {
  desc = "Toggle text wrap",
})
