local format = require("lib.format")

return {
  {
    "jose-elias-alvarez/null-ls.nvim",
    event = "BufReadPre",
    keys = {
      {
        "<leader>=",
        format.toggle_autoformat,
        desc = "Toggle autoformat",
        silent = true,
      },
    },
    dependencies = {
      "mason.nvim",
    },
    opts = function()
      local nls = require("null-ls")
      return {
        sources = {
          nls.builtins.formatting.prettier,
          nls.builtins.formatting.stylua,
          nls.builtins.formatting.black,
          nls.builtins.code_actions.eslint,
        },
      }
    end,
  },
}
