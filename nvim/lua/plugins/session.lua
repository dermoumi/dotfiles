return {
  {
    "Shatur/neovim-session-manager",
    lazy = false,
    opts = {
      max_path_length = 0,
    },
    config = function(_, opts)
      require("session_manager").setup(opts)
    end,
  },
}
