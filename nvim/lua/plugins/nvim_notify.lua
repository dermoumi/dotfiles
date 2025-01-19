return {
  {
    "rcarriga/nvim-notify",
    cmd = "Notifications",
    keys = {
      {
        "<leader>uu",
        "<cmd>Notifications<cr>",
        function()
          local ok, telescope = pcall(require, "telescope")
          if ok then
            telescope.extensions.notify.notify()
          else
            vim.cmd("Notifications")
          end
        end,
        desc = "Show notifications",
      },
      {
        "<leader>un",
        function()
          require("notify").dismiss({ silent = true, pending = true })
        end,
        desc = "Delete all Notifications",
      },
    },
    opts = {
      level = vim.log.levels.INFO,
      fps = 30,
      background_colour = "Normal",
      max_height = function()
        return math.floor(vim.o.lines * 0.75)
      end,
      max_width = function()
        return math.floor(vim.o.columns * 0.75)
      end,
      render = "wrapped-compact",
    },
    init = function()
      vim.notify = function(...)
        require("lazy").load({
          plugins = { "nvim-notify" },
        })
        vim.notify = require("notify")
        return vim.notify(...)
      end
    end,
    config = function(_, opts)
      local notify = require("notify")
      notify.setup(opts)
    end,
  },
}
