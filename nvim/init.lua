-- Utility function to inspect stuff
function _G.put(...)
  local objects = {}
  for i = 1, select("#", ...) do
    local v = select(i, ...)
    table.insert(objects, vim.inspect(v))
  end

  print(table.concat(objects, "\n"))
  return ...
end

-- Import rest of the config from the `core/` directory
require("core.options")
require("core.autocommands")
require("core.mappings")
require("core.plugins")
require("core.remote")
