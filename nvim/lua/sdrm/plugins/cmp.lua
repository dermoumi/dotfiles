local Cmp = {}

--- when inside a snippet, seeks to the nearest luasnip field if possible, and checks if it is jumpable
--- @param dir number 1 for forward, -1 for backward; defaults to 1
--- @return boolean true if a jumpable luasnip field is found while inside a snippet
local function jumpable(dir)
  local luasnip_ok, luasnip = pcall(require, "luasnip")
  if not luasnip_ok then
    return
  end

  local win_get_cursor = vim.api.nvim_win_get_cursor
  local get_current_buf = vim.api.nvim_get_current_buf

  local function inside_snippet()
    -- for outdated versions of luasnip
    if not luasnip.session.current_nodes then
      return false
    end

    local node = luasnip.session.current_nodes[get_current_buf()]
    if not node then
      return false
    end

    local snip_begin_pos, snip_end_pos = node.parent.snippet.mark:pos_begin_end()
    local pos = win_get_cursor(0)
    pos[1] = pos[1] - 1 -- LuaSnip is 0-based not 1-based like nvim for rows
    return pos[1] >= snip_begin_pos[1] and pos[1] <= snip_end_pos[1]
  end

  --- sets the current buffer's luasnip to the one nearest the cursor
  --- @return boolean true if a node is found, false otherwise
  local function seek_luasnip_cursor_node()
    -- for outdated versions of luasnip
    if not luasnip.session.current_nodes then
      return false
    end

    local pos = win_get_cursor(0)
    pos[1] = pos[1] - 1
    local node = luasnip.session.current_nodes[get_current_buf()]
    if not node then
      return false
    end

    local snippet = node.parent.snippet
    local exit_node = snippet.insert_nodes[0]

    -- exit early if we're past the exit node
    if exit_node then
      local exit_pos_end = exit_node.mark:pos_end()
      if (pos[1] > exit_pos_end[1]) or (pos[1] == exit_pos_end[1] and pos[2] > exit_pos_end[2]) then
        snippet:remove_from_jumplist()
        luasnip.session.current_nodes[get_current_buf()] = nil

        return false
      end
    end

    node = snippet.inner_first:jump_into(1, true)
    while node ~= nil and node.next ~= nil and node ~= snippet do
      local n_next = node.next
      local next_pos = n_next and n_next.mark:pos_begin()
      local candidate = n_next ~= snippet and next_pos and (pos[1] < next_pos[1])
        or (pos[1] == next_pos[1] and pos[2] < next_pos[2])

      -- Past unmarked exit node, exit early
      if n_next == nil or n_next == snippet.next then
        snippet:remove_from_jumplist()
        luasnip.session.current_nodes[get_current_buf()] = nil

        return false
      end

      if candidate then
        luasnip.session.current_nodes[get_current_buf()] = node
        return true
      end

      local ok
      ok, node = pcall(node.jump_from, node, 1, true) -- no_move until last stop
      if not ok then
        snippet:remove_from_jumplist()
        luasnip.session.current_nodes[get_current_buf()] = nil

        return false
      end
    end

    -- No candidate, but have an exit node
    if exit_node then
      -- to jump to the exit node, seek to snippet
      luasnip.session.current_nodes[get_current_buf()] = snippet
      return true
    end

    -- No exit node, exit from snippet
    snippet:remove_from_jumplist()
    luasnip.session.current_nodes[get_current_buf()] = nil
    return false
  end

  if dir == -1 then
    return inside_snippet() and luasnip.jumpable(-1)
  else
    return inside_snippet() and seek_luasnip_cursor_node() and luasnip.jumpable()
  end
end

local function has_space_before()
  local col = vim.fn.col "." - 1
  return col == 0 or vim.fn.getline("."):sub(col, col):match "%s"
end

--- checks if emmet_ls is available and active in the buffer
--- @return boolean true if available, false otherwise
local function is_emmet_active()
  local clients = vim.lsp.buf_get_clients()

  for _, client in pairs(clients) do
    if client.name == "emmet_ls" then
      return true
    end
  end
  return false
end

function Cmp.setup()
  local cmp_ok, cmp = pcall(require, "cmp")
  if not cmp_ok then
    vim.notify("Could not load cmp")
    return
  end

  local luasnip_ok, luasnip = pcall(require, "luasnip")
  if not luasnip_ok then
    vim.notify("Could not load luasnip")
    return
  end

  vim.opt.completeopt = { "menu", "menuone", "noselect" }

  local options = {
    snippet = {
      expand = function(args)
        require("luasnip").lsp_expand(args.body)
      end,
    },
    mapping = {
      ["<Up>"] = cmp.mapping(function(fallback)
        if not cmp.select_prev_item() then
          fallback()
        end
      end),
      ["<Down>"] = cmp.mapping(function(fallback)
        if not cmp.select_next_item() then
          fallback()
        end
      end),
      ["<C-k>"] = cmp.mapping(cmp.mapping.scroll_docs(-5), { "i", "c" }),
      ["<C-j>"] = cmp.mapping(cmp.mapping.scroll_docs(5), { "i", "c" }),
      ["<C-Space>"] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }),
      ["<C-y>"] = cmp.config.disable, -- remove default config
      ["<C-e>"] = cmp.config.disable, -- remove default config
      ["<C-c>"] = cmp.mapping({
        i = cmp.mapping.abort(),
        c = cmp.mapping.close(),
      }),
      ["<Tab>"] = cmp.mapping(function(fallback)
        local entry = cmp.get_selected_entry()
        if not entry and vim.b._copilot and vim.b._copilot.suggestions ~= nil then
          -- Make sure the suggestion exists and it does not start with whitespace
          -- This is to prevent the user from accidentally selecting a suggestion
          -- when trying to indent
          local suggestion = vim.b._copilot.suggestions[1]
          if suggestion ~= nil then
            suggestion = suggestion.displayText
          end
          if suggestion == nil or (suggestion:find("^%s") ~= nil and suggestion:find("^\n") == nil) then
            fallback()
          else
            vim.fn.feedkeys(vim.fn['copilot#Accept'](), '')
          end
        elseif cmp.visible() then
          cmp.confirm({ select = true })
        elseif luasnip.expandable() then
          luasnip.expand()
        elseif jumpable(1) then
          luasnip.jump(1)
        elseif has_space_before() then
          fallback()
        elseif is_emmet_active() then
          return vim.fn["cmp#complete"]()
        else
          fallback()
        end
      end, { "i", "s" }),
    },
    sources = {
      { name = "nvim_lsp" },
      { name = "path" },
      { name = "luasnip" },
      { name = "cmp_tabnine" },
      { name = "nvim_lua" },
      { name = "buffer" },
      { name = "calc" },
      { name = "emoji" },
      { name = "treesitter" },
      { name = "crates" },
    },
  }

  local lspkind_ok, lspkind = pcall(require, "lspkind")
  if lspkind_ok then
    options.formatting = {
      format = lspkind.cmp_format({
        with_text = false,
      }),
    }
  end

  local cmp_buffer_ok, cmp_buffer = pcall(require, "cmp_buffer")
  if cmp_buffer_ok then
    options.sorting = {
      comparators = {
        function(...)
          return cmp_buffer:compare_locality(...)
        end,
      },
    }
  end

  cmp.setup(options)

  -- Autocompletion for / search
  cmp.setup.cmdline("/", {
    sources = {
      { name = "buffer" },
    },
  })

  -- Autocompletion for paths
  cmp.setup.cmdline(":", {
    sources = {
      { name = "path" },
      { name = "cmdline" },
    },
  })

  vim.cmd [[
    hi Pmenu ctermbg=233 ctermfg=244
    hi CmpItemMenu ctermbg=233
  ]]
end

return Cmp
