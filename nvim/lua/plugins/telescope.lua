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
        layout_strategy = "vertical_connected",
        layout_config = {
          prompt_position = "top",
          scroll_speed = 5,
          height = 0.95,
          width = function(_, max_columns, _)
            return math.min(math.floor(0.8 * max_columns), 120)
          end,
          preview_height = 0.4,
          vertical = {
            mirror = true,
          }
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
      -- "vertical" leaves a blank row between windows (each keeps its own
      -- border frame). This variant overlaps the results' border onto the
      -- prompt so the two read as one box, like center/dropdown but keeping
      -- vertical's proportions. The preview stays a separate window below.
      local ls = require("telescope.pickers.layout_strategies")
      if not ls.vertical_connected then
        local base = ls.vertical
        ls.vertical_connected = function(self, max_columns, max_lines, override)
          local layout = base(self, max_columns, max_lines, override)
          local prompt, results = layout.prompt, layout.results
          if prompt and results then
            -- Shift the lower of the two up one row (grow to keep its bottom
            -- edge) so its top border shares the other's border row.
            local lower = prompt.line > results.line and prompt or results
            lower.line = lower.line - 1
            lower.height = lower.height + 1
          end
          return layout
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
          vim.api.nvim_create_autocmd("WinClosed", {
            once = true,
            callback = function()
              vim.schedule(function()
                pcall(vim.api.nvim_win_close, win, true)
                pcall(vim.api.nvim_buf_delete, buf, { force = true })
              end)
            end,
          })
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
