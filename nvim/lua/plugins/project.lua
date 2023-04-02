return {
  {
    "ahmedkhalf/project.nvim",
    event = "VeryLazy",
    opts = {
      patterns = {
        ".git",
        "!package.json",
        "!node_modules",
      },
      exclude_dirs = {
        "~/.dotfiles/*",
      },
    },
    config = function(_, opts)
      require("project_nvim").setup(opts)
    end,
  },
}
