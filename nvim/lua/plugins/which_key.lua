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
    which_key.setup()

    -- Categories
    which_key.register({
      ["<leader>f"] = { name = "+Find" },
      ["<leader>W"] = { name = "+Workspace" },
      ["<leader>h"] = { name = "+Git" },
      ["<leader>u"] = { name = "+Notifications" },
      ["g"] = { name = "+Go to" },
      ["'"] = { name = "+Marks" },
      ["g'"] = { name = "+Marks" },
      ["g`"] = { name = "+Marks" },
      ['"'] = { name = "+Registers" },
    })
  end,
}
