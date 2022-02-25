_G._SdrmWhichKeys = {}
_G._SdrmBoundFuncs = {}

-- Adds silent and noremap to given options,
-- but only if they're not defined
local function set_silent_noremap(options)
  options = options and vim.deepcopy(options) or {}

  if options["silent"] == nil then
    options["silent"] = true
  end

  if options["noremap"] == nil then
    options["noremap"] = true
  end

  return options
end

local function register_whichkey(mode, key, name)
  local ok, which_key = pcall(require, "which-key")

  if ok then
    which_key.register({ [key] = name }, { mode = mode })
  else
    _SdrmWhichKeys[mode] = vim.tbl_deep_extend("force", _SdrmWhichKeys[mode] or {}, { [key] = name })
  end
end

---Maps a key on one or many modes.
---options default to silent and noremap.
---@param modes string: Modes to apply the mapping to
---@param lhs string: Key(s) to trigger the mapping
---@param cmd string|function: Command or function to run when the keys are pressed
---@param options table: Extra options
return function(modes, lhs, cmd, options)
  local rhs = cmd
  if type(cmd) == "function" then
    table.insert(_SdrmBoundFuncs, cmd)
    local key = #_SdrmBoundFuncs
    rhs = "<cmd>lua _SdrmBoundFuncs[" .. key .. "]()<cr>"
  end

  -- Add default options if they're not set
  options = set_silent_noremap(options)

  -- Extract buffer_nr if there's any
  local buffer_nr = options["buffer_nr"]
  options["buffer_nr"] = nil

  -- Use a different keymap func depending on whether buffer_nr is set or not
  local map_func = buffer_nr == nil
    and vim.api.nvim_set_keymap
    or function(...)
      vim.api.nvim_buf_set_keymap(buffer_nr, ...)
    end

  -- Extract the which key name if any
  local name = options["name"]
  options["name"] = nil

  -- Register the key for each mode in the modes string
  if #modes <= 1 then
    map_func(modes, lhs, rhs, options)
    if name ~= nil then
      register_whichkey(modes, lhs, name)
    end
  else
    for i = 1, #modes do
      local mode = modes:sub(i,i)
      map_func(mode, lhs, rhs, options)
      if name ~= nil then
        register_whichkey(mode, lhs, name)
      end
    end
  end
end
