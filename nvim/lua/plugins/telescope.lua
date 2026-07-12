-- Preview scroll position as a percentage: 0% at top, 100% at bottom (or when
-- the whole buffer fits). Trailing space nudges it one cell off the corner.
local function preview_scroll_label(win)
  local buf = vim.api.nvim_win_get_buf(win)
  local total = vim.api.nvim_buf_line_count(buf)
  local top = vim.fn.line("w0", win)
  local height = vim.api.nvim_win_get_height(win)
  local pct = total <= height and 100 or math.floor((top - 1) / (total - height) * 100 + 0.5)
  return string.format("%d%%", pct)
end

-- Render that label on the bottom-right of the preview's border.
local function update_preview_scroll(picker, attempt)
  local preview = picker and picker.layout and picker.layout.preview
  if not preview or not preview.winid or not preview.border then
    return
  end
  if not vim.api.nvim_win_is_valid(preview.winid) then
    return
  end
  -- The preview buffer loads asynchronously, so on a fresh selection its line
  -- count is still 1 when we're first called; wait until it's populated.
  attempt = attempt or 1
  if vim.api.nvim_buf_line_count(vim.api.nvim_win_get_buf(preview.winid)) <= 1 and attempt < 8 then
    vim.defer_fn(function()
      update_preview_scroll(picker, attempt + 1)
    end, 20)
    return
  end
  preview.border:change_title(preview_scroll_label(preview.winid), "SE")
end

return {
  {
    "nvim-telescope/telescope-fzf-native.nvim",
    build = "make",
  },
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "telescope-fzf-native.nvim",
    },
    keys = {
      {
        "<leader>ff",
        function()
          local opts = { hidden = true }
          local tb = require("telescope.builtin")
          local ok = pcall(tb.find_files, opts)
          if not ok then
            tb.fd(opts)
          end
        end,
        desc = "Find file…",
      },
      {
        "<leader>fb",
        function()
          require("telescope.builtin").buffers({
            ignore_current_buffer = true,
            sort_lastused = true,
          })
        end,
        desc = "Switch to buffer…",
      },
      {
        "<leader>fr",
        function()
          require("telescope.builtin").oldfiles()
        end,
        desc = "Find recent file…",
      },
      {
        "<leader>fh",
        function()
          require("telescope.builtin").help_tags()
        end,
        desc = "Find help…",
      },
      {
        "<leader>fz",
        function()
          require("telescope.builtin").current_buffer_fuzzy_find()
        end,
        desc = "Fuzzy find…",
      },
      {
        "<leader>ft",
        function()
          require("telescope.builtin").tags()
        end,
        desc = "Fuzzy tags…",
      },
      {
        "<leader>fg",
        function()
          require("telescope.builtin").live_grep()
        end,
        desc = "Live grep…",
      },
      {
        "<leader>fo",
        function()
          require("telescope.builtin").grep_string()
        end,
        desc = "Grep current string…",
      },
      {
        "<leader>f<space>",
        function()
          require("telescope.builtin").resume()
        end,
        desc = "Resume find…",
      },
    },
    opts = function(_, opts)
      local actions_layout = require("telescope.actions.layout")
      local actions = require("telescope.actions")
      local action_state = require("telescope.actions.state")

      -- Run a preview scroll action, then refresh the border scroll indicator.
      local scroll_preview = function(fn)
        return function(prompt_bufnr)
          fn(prompt_bufnr)
          update_preview_scroll(action_state.get_current_picker(prompt_bufnr))
        end
      end

      local create_new_file = function(prompt_bufnr)
        local actions_state = require("telescope.actions.state")
        local picker = actions_state.get_current_picker(prompt_bufnr)
        local prompt = picker:_get_prompt()
        if prompt ~= "" then
          vim.cmd("e! " .. prompt)
        end
      end

      opts.defaults = {
        show_line = false,
        prompt_title = "",
        results_title = false,
        preview_title = false,
        sorting_strategy = "ascending",
        -- Join prompt + results into one connected box (preview stays a
        -- separate window below). Shared edge uses tee junctions.
        -- borderchars order: { top, right, bottom, left, tl, tr, br, bl }
        borderchars = {
          prompt = { "─", "│", " ", "│", "╭", "╮", "│", "│" },
          results = { "─", "│", "─", "│", "├", "┤", "╯", "╰" },
          preview = { "╌", "╎", "╌", "╎", "╭", "╮", "╯", "╰" },
        },
        layout_strategy = "adaptive",
        layout_config = {
          scroll_speed = 5,
          -- fill the screen height minus a 2-cell padding, top and bottom
          height = function(_, _, max_lines)
            return max_lines - 4
          end,
          -- preview_cutoff = 1 keeps the side/below preview at any size
          vertical = {
            prompt_position = "top",
            preview_height = 0.4,
            mirror = true,
            preview_cutoff = 1,
            -- narrower cap when stacked (no side preview filling the width)
            width = function(_, max_columns, _)
              return math.min(math.floor(0.8 * max_columns), 120)
            end,
          },
          horizontal = {
            prompt_position = "top",
            preview_width = 0.5,
            preview_cutoff = 1,
            -- full width minus 2-cell padding so the side preview has room
            width = function(_, max_columns, _)
              return math.min(max_columns - 4, 200)
            end,
          },
        },
        winblend = 0,
        mappings = {
          i = {
            ["<esc>"] = "close",
            ["<C-C>"] = { "<Nop>", type = "command" },
            ["<C-u>"] = scroll_preview(actions.preview_scrolling_up),
            ["<C-d>"] = scroll_preview(actions.preview_scrolling_down),
            ["<M-BS>"] = { "<C-W>", type = "command" },
            ["<C-BS>"] = { "<C-W>", type = "command" },
            ["<C-H>"] = { "<C-W>", type = "command" },
            ["<Home>"] = { "<C-O><S-I>", type = "command" },
            ["<End>"] = { "<C-O><S-A>", type = "command" },
            ["<C-z>"] = actions_layout.toggle_preview,
            ["<C-n>"] = create_new_file,
          },
        },
        vimgrep_arguments = {
          "rg",
          "--color=never",
          "--no-heading",
          "--with-filename",
          "--line-number",
          "--column",
          "--smart-case",
          "--hidden",
        },
      }

      opts.fzf = {
        fuzzy = true,
        override_generic_sorter = true,
        override_file_sorter = true,
        case_mode = "smart_case",
      }
    end,
    config = function(_, opts)
      -- "adaptive" puts the preview on the side while the editor is wider than
      -- a ~132:60 columns:rows ratio, below it once narrower/taller. Both
      -- orientations overlap prompt+results into one box (they stack vertically
      -- either way); the preview stays separate. connect() removes the blank
      -- row telescope leaves between the two border frames.
      local ls = require("telescope.pickers.layout_strategies")
      if not ls.adaptive then
        local function connect(base)
          return function(self, max_columns, max_lines, override)
            local layout = base(self, max_columns, max_lines, override)
            local prompt, results = layout.prompt, layout.results
            if prompt and results then
              local lower = prompt.line > results.line and prompt or results
              lower.line = lower.line - 1
              lower.height = lower.height + 1
            end
            return layout
          end
        end
        local v_conn = connect(ls.vertical)
        local h_conn = connect(ls.horizontal)
        ls.adaptive = function(self, max_columns, max_lines)
          local lc = self.layout_config or {}
          if max_columns * 60 > max_lines * 130 then
            return h_conn(self, max_columns, max_lines, lc.horizontal or {})
          end
          return v_conn(self, max_columns, max_lines, lc.vertical or {})
        end
      end

      -- Give the prompt (search bar) the same border color as the other
      -- windows; re-linked on ColorScheme since theme/background switches reset
      -- it back to ayu's accent.
      local function match_prompt_border()
        vim.api.nvim_set_hl(0, "TelescopePromptBorder", { link = "TelescopeResultsBorder" })
      end
      match_prompt_border()
      vim.api.nvim_create_autocmd("ColorScheme", { callback = match_prompt_border })

      -- Dim the editor behind the picker: a full-screen float below telescope
      -- (lower zindex), torn down when the first telescope window closes.
      vim.api.nvim_set_hl(0, "TelescopeBackdrop", { bg = "#000000", default = true })
      vim.api.nvim_create_autocmd("User", {
        pattern = "TelescopeFindPre",
        callback = function()
          local buf = vim.api.nvim_create_buf(false, true)
          local win = vim.api.nvim_open_win(buf, false, {
            relative = "editor",
            row = 0,
            col = 0,
            width = vim.o.columns,
            height = vim.o.lines,
            style = "minimal",
            focusable = false,
            zindex = 40,
          })
          vim.wo[win].winhighlight = "Normal:TelescopeBackdrop"
          vim.wo[win].winblend = 50
          -- Keep the backdrop covering the editor when the window resizes.
          local resize = vim.api.nvim_create_autocmd("VimResized", {
            callback = function()
              if vim.api.nvim_win_is_valid(win) then
                vim.api.nvim_win_set_config(win, {
                  relative = "editor",
                  row = 0,
                  col = 0,
                  width = vim.o.columns,
                  height = vim.o.lines,
                })
              end
            end,
          })
          -- Tear down when the picker closes (its prompt buffer is wiped).
          -- Keyed to the prompt buffer, not WinClosed, so a resize — which
          -- recreates telescope's windows — doesn't kill the backdrop early.
          vim.schedule(function()
            local prompts = require("telescope.state").get_existing_prompt_bufnrs()
            local prompt = prompts[#prompts]
            local function teardown()
              pcall(vim.api.nvim_del_autocmd, resize)
              pcall(vim.api.nvim_win_close, win, true)
              pcall(vim.api.nvim_buf_delete, buf, { force = true })
            end
            if not prompt then
              teardown()
              return
            end
            vim.api.nvim_create_autocmd({ "BufWipeout", "BufDelete" }, {
              buffer = prompt,
              once = true,
              callback = function()
                vim.schedule(teardown)
              end,
            })
          end)
        end,
      })

      -- Set/reset the preview scroll indicator whenever a preview loads
      -- (opening a picker or moving the selection).
      vim.api.nvim_create_autocmd("User", {
        pattern = "TelescopePreviewerLoaded",
        callback = function()
          vim.schedule(function()
            local bufnrs = require("telescope.state").get_existing_prompt_bufnrs()
            if #bufnrs == 0 then
              return
            end
            local action_state = require("telescope.actions.state")
            update_preview_scroll(action_state.get_current_picker(bufnrs[#bufnrs]))
          end)
        end,
      })

      local telescope = require("telescope")
      telescope.setup(opts)
      telescope.load_extension("fzf")
    end,
  },
}
