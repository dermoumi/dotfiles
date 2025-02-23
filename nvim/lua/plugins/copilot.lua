return {
  {
    "zbirenbaum/copilot.lua",
    enabled = function()
      return vim.fn.executable("node") == 1
    end,
    cmd = "Copilot",
    event = { "InsertEnter", "CmdlineEnter" },
    opts = {
      suggestion = { auto_trigger = true },
      filetypes = { yaml = true },
    },
    config = function(_, opts)
      require("copilot").setup(opts)
    end,
  },
}
