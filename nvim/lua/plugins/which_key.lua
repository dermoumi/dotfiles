return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  config = function()
    -- Timeout for whichkey
    vim.o.timeout = true
    vim.o.timeoutlen = 300

    -- Panel colors
    vim.api.nvim_set_hl(0, "WhichKeyFloat", {
      ctermbg = 233,
    })

    -- Initialize
    local which_key = require("which-key")
    which_key.setup({
      win = {
        wo = {
          winblend = 10,
        },
      },
      spec = {
        { "<leader>f", group = "Find" },
        { "<leader>W", group = "Workspace" },
        { "<leader>h", group = "Git" },
        { "<leader>u", group = "Notifications" },
        { "g", group = "Go to", mode = { "n", "v" } },
        { "'", group = "Marks", mode = { "n", "v" } },
        { "`", group = "Marks", hidden = true, mode = { "n", "v" } },
        { "g'", group = "Marks", mode = { "n", "v" } },
        { "g`", group = "Marks", hidden = true, mode = { "n", "v" } },
        { "[", group = "Prev", mode = { "n", "v" } },
        { "]", group = "Next", mode = { "n", "v" } },
        { '"', group = "Registers", mode = { "n", "v" } },
        { "<C-w>", group = "Window", mode = { "n", "v" } },
        { "z", group = "Fold", mode = { "n", "v" } },
        { "<leader>", group = "More", mode = { "n", "v" } },
        { "h", hidden = true, mode = { "n", "v" } },
        { "j", hidden = true, mode = { "n", "v" } },
        { "k", hidden = true, mode = { "n", "v" } },
        { "l", hidden = true, mode = { "n", "v" } },
        { "<C-k>", hidden = true, mode = { "n", "v" } },
        { "<C-j>", hidden = true, mode = { "n", "v" } },
        { "b", hidden = true, mode = { "n", "v" } },
        { "B", hidden = true, mode = { "n", "v" } },
        { "e", hidden = true, mode = { "n", "v" } },
        { "E", hidden = true, mode = { "n", "v" } },
        { "w", hidden = true, mode = { "n", "v" } },
        { "W", hidden = true, mode = { "n", "v" } },
        { "{", hidden = true, mode = { "n", "v" } },
        { "}", hidden = true, mode = { "n", "v" } },
        { "v", hidden = true, mode = { "n", "v" } },
        { "V", hidden = true, mode = { "n", "v" } },
        { "^", hidden = true, mode = { "n", "v" } },
        { "0", hidden = true, mode = { "n", "v" } },
        { "G", hidden = true, mode = { "n", "v" } },
        { "c", hidden = true, mode = { "n", "v" } },
        { "d", hidden = true, mode = { "n", "v" } },
        { "f", hidden = true, mode = { "n", "v" } },
        { "F", hidden = true, mode = { "n", "v" } },
        { "H", hidden = true, mode = { "n", "v" } },
        { "L", hidden = true, mode = { "n", "v" } },
        { "M", hidden = true, mode = { "n", "v" } },
        { "r", hidden = true, mode = { "n", "v" } },
        { "t", hidden = true, mode = { "n", "v" } },
        { "T", hidden = true, mode = { "n", "v" } },
        { "%", hidden = true, mode = { "n", "v" } },
        { "/", hidden = true, mode = { "n", "v" } },
        { "?", hidden = true, mode = { "n", "v" } },
        { "gg", hidden = true, mode = { "n", "v" } },
        { "y", hidden = true, mode = { "n" } },
        { "Y", hidden = true, mode = { "n", "v" } },
        { ",", hidden = true, mode = { "n", "v" } },
        { ";", hidden = true, mode = { "n", "v" } },
        { ">", hidden = true, mode = { "n" } },
        { "<", hidden = true, mode = { "n" } },
        { "$", hidden = true, mode = { "n", "v" } },
        { "Q", hidden = true, mode = { "v" } },
        { "@", hidden = true, mode = { "v" } },
        { "&", hidden = true, mode = { "n" } },
        { "<C-l>", hidden = true, mode = { "n" } },
        { "~", hidden = true, mode = { "n" } },
        { "a", group = "Around", mode = { "v" } },
        { "i", group = "Inside", mode = { "v" } },
        { "<C-s>", name = "Save" },
    },
    })
  end,
}
