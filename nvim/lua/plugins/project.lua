return {
  {
    "ahmedkhalf/project.nvim",
    event = "VeryLazy",
    opts = {
      patterns = {
        ".git",
      },
    },
    config = function(_, opts)
      require("project_nvim").setup(opts)
    end,
  },
}
