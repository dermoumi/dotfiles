return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  config = function()
    -- Timeout for whichkey
    vim.o.timeout = true
    vim.o.timeoutlen = 300

    -- Panel colors
    vim.api.nvim_set_hl(0, "WhichKeyFloat", {
      ctermbg = 233
    })

    -- Initialize
    local wk = require("which-key")
    wk.setup()

    -- Categories
    wk.register({
      ["<leader>f"] = { name = "+Find" },
      ["<leader>W"] = { name = "+Workspace" },
      ["<leader>h"] = { name = "+Git" },
      ["g"] = { name = "+Go to" },
      ["'"] = { name = "+Marks" },
      ["\""] = { name = "+Registers" },
    })
  end
}
