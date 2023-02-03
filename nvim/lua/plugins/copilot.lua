return {
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = { "InsertEnter", "CmdlineEnter" },
    opts = {
      panel = { enabled = false },
      suggestion = { enabled = false },
    },
    config = function(_, opts)
      require("copilot").setup(opts)
    end,
  },
  {
    "zbirenbaum/copilot-cmp",
    event = { "InsertEnter", "CmdlineEnter" },
    dependencies = {
      "copilot.lua",
      {
        "nvim-cmp",
        opts = function(_, opts)
          local copilot_comparators = require("copilot_cmp.comparators")

          local sources = opts.sources or {}
          opts.sources = sources
          table.insert(sources, 1, { name = "copilot" })

          local sorting = opts.sorting or {}
          opts.sorting = sorting
          sorting.priority_weight = 2

          local comparators = sorting.comparators or {}
          sorting.comparators = comparators
          table.insert(comparators, 1, copilot_comparators.prioritize)
          table.insert(comparators, 1, copilot_comparators.score)
        end,
      },
    },
    config = function(_, opts)
      require("copilot_cmp").setup(opts)
    end,
  },
}
