local M = {}

function M.setup()
  require("sdrm.map")

  local wk = require("which-key")
  wk.setup({})

  -- timeout for whichkey
  vim.opt.timeoutlen = 250

  wk.register({
    ["<leader>f"] = { name = "+Find" },
    ["<leader>W"] = { name = "+Workspace" },
    ["g"] = { name = "+Go to" },
    ["'"] = { name = "+Marks" },
    ["\""] = { name = "+Registers" },
  })

  -- Check for vim-prettier
  local vim_prettier = packer_plugins["vim-prettier"]
  if vim_prettier and vim_prettier.loaded then
    wk.register({
      ["<leader>p"] = "Format with prettier",
    })
  end

  -- Commentary keys
  local kommentary = packer_plugins["kommentary"]
  if kommentary and kommentary.loaded then
    wk.register({
      ["gc"] = { name = "Comment" },
      ["gcc"] = "Entire line",
    })
  end

  -- Text objects
  local ts_textobjects = packer_plugins["nvim-treesitter-textobjects"]
  if ts_textobjects and ts_textobjects.loaded then
    wk.register({
      ["af"] = "function",
      ["if"] = "function",
      ["ac"] = "class",
      ["ic"] = "class",
    }, { mode = "o" })

    wk.register({
      ["]["] = { "Next class start" },
      ["]]"] = { "Next class end" },
      ["[["] = { "Previous class start" },
      ["[]"] = { "Previous class end" },
    })
  end

  -- Surround
  local surround = packer_plugins["vim-surround"]
  if surround and surround.loaded then
    wk.register({
      ["ys"] = "Surround at the same line",
      ["yS"] = "Surround in new lines",
      ["yss"] = "Wrap entire line",
      ["ySS"] = "Wrap entire line",
      ["ySs"] = "which_key_ignore",
    })
  end

  -- Register deferred which keys
  for mode, keys in pairs(_SdrmWhichKeys) do
    wk.register(keys, { mode = mode })
  end

  -- Colors
  vim.cmd [[
    hi WhichKeyFloat ctermbg=233
  ]]
end

return M
