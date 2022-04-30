_G._SdrmWhichKeys = {}
_G._SdrmBoundFuncs = {}

--- Adds silent and noremap to given options,
--- but only if they're not defined
--- @param options table?: Options to add silent and noremap to
--- @return table: Options with silent and noremap added
local function set_silent_noremap(options)
  local opts = options ~= nil and vim.deepcopy(options) or {}

  if opts["silent"] == nil then
    opts["silent"] = true
  end

  if opts["noremap"] == nil then
    opts["noremap"] = true
  end

  return opts
end

local function register_whichkey(mode, key, name)
  local ok, which_key = pcall(require, "which-key")

  if ok then
    which_key.register({ [key] = name }, { mode = mode })
  else
    _SdrmWhichKeys[mode] = vim.tbl_deep_extend("force", _SdrmWhichKeys[mode] or {}, { [key] = name })
  end
end
_G.register_whichkey = register_whichkey

--- Maps a key on one or many modes.
--- options default to silent and noremap.
--- @param modes string: Modes to apply the mapping to
--- @param lhs string: Key(s) to trigger the mapping
--- @param cmd string|function: Command or function to run when the keys are pressed
--- @param options table?: Extra options
return function(modes, lhs, cmd, options)
  local rhs = cmd
  if type(cmd) == "function" then
    table.insert(_SdrmBoundFuncs, cmd)
    local key = #_SdrmBoundFuncs
    rhs = "<cmd>lua _SdrmBoundFuncs[" .. key .. "]()<cr>"
  end

  -- Add default options if they're not set
  local opts = set_silent_noremap(options)

  -- Extract buffer_nr if there's any
  local buffer_nr = opts["buffer_nr"]
  opts["buffer_nr"] = nil

  -- Use a different keymap func depending on whether buffer_nr is set or not
  local map_func = buffer_nr == nil
    and vim.api.nvim_set_keymap
    or function(...)
      vim.api.nvim_buf_set_keymap(buffer_nr, ...)
    end

  -- Extract the which key name if any
  local name = opts["name"]
  opts["name"] = nil

  -- Register the key for each mode in the modes string
  if #modes <= 1 then
    map_func(modes, lhs, rhs, opts)
    if name ~= nil then
      register_whichkey(modes, lhs, name)
    end
  else
    for i = 1, #modes do
      local mode = modes:sub(i,i)
      map_func(mode, lhs, rhs, opts)
      if name ~= nil then
        register_whichkey(mode, lhs, name)
      end
    end
  end
end
