--[[
  Config file for projects.nvim plugin
]]

local M = {}

-- Sets up default config
function M.setup()
  local map = require("sdrm.map")

  require("project_nvim").setup {
    patterns = { ".git" },
  }

  -- register it as a telescope plugin if telescope is loaded
  local ok, telescope = pcall(require, "telescope")
  if ok then
    telescope.load_extension("projects")
  end

  -- Opens a telescope view on recent projects
  if ok then
    map("n", "<leader>fp", function()
      telescope.extensions.projects.projects()
    end, {
      name = "Open project…",
    })
  end
end

return M
