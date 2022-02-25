--[[
  Config file for the telescope.nvim plugin
]]

local telescope = require("telescope")
local telescope_builtin = require("telescope.builtin")

local M = {}

function M.setup()
  local map = require("sdrm.map")

  local extensions = {}

  local has_fzf, _ = pcall(telescope.load_extension, "fzf")
  if has_fzf then
    extensions["fzf"] = {
      fuzzy = true,
      override_generic_sorter = true,
      override_file_sorter = true,
      case_mode = "smart_case",
    }
  end

  telescope.setup({
    extensions = extensions,
    defaults = {
      show_line = false,
      prompt_title = "",
      preview_title = false,
      sorting_strategy = "ascending",
      layout_config = {
        prompt_position = "top",
        preview_width = 0.5,
        scroll_speed = 5,
      },
      mappings = {
        i = {
          ["<esc>"] = "close",
          ["<C-C>"] = { "<Nop>", type = "command" },
          ["<C-K>"] = "preview_scrolling_up",
          ["<C-J>"] = "preview_scrolling_down",
          ["<M-BS>"] = { "<C-W>", type = "command" },
          ["<C-BS>"] = { "<C-W>", type = "command" },
          ["<C-H>"] = { "<C-W>", type = "command" },
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
    },
  })

  -- map keys
  map("n", "<leader>ff", function()
    local ok = pcall(telescope_builtin.git_files)

    if not ok then
      telescope_builtin.fd()
    end
  end, {
    name = "Find file…",
  })

  map("n", "<leader>fb", function()
    telescope_builtin.buffers({
      ignore_current_buffer = true,
      sort_lastused = true,
    })
  end, {
    name = "Switch to buffer…",
  })

  map("n", "<leader>fr", telescope_builtin.oldfiles, {
    name = "Find recent file…",
  })
  map("n", "<leader>fe", telescope_builtin.file_browser, {
    name = "File explorer…",
  })
  map("n", "<leader>fh", telescope_builtin.help_tags, {
    name = "Find help…",
  })
  map("n", "<leader>fz", telescope_builtin.current_buffer_fuzzy_find, {
    name = "Fuzzy find…",
  })
  map("n", "<leader>ft", telescope_builtin.tags, {
    name = "Find tags…",
  })
  map("n", "<leader>fg", telescope_builtin.live_grep, {
    name = "Live grep…",
  })
  map("n", "<leader>fo", telescope_builtin.grep_string, {
    name = "Grep current string…",
  })
  map("n", "<leader>f<space>", telescope_builtin.resume, {
    name = "Resume find…",
  })

  map("n", "gr", telescope_builtin.lsp_references, {
    name = "Find references…",
  })
  map("n", "gs", telescope_builtin.lsp_document_symbols, {
    name = "Find symbols…",
  })
  map("n", "gS", telescope_builtin.lsp_dynamic_workspace_symbols, {
    name = "Find workspace symbols…",
  })
  map("n", "ga", telescope_builtin.lsp_code_actions, {
    name = "Code actions…",
  })
  map("n", "gd", telescope_builtin.lsp_definitions, {
    name = "Go to definition…",
  })
  map("n", "gI", telescope_builtin.lsp_implementations, {
    name = "Go to implementation…",
  })
  map("n", "gT", telescope_builtin.lsp_type_definitions, {
    name = "Go to type definition…",
  })
  map("v", "ga", ":'<,'>lua vim.lsp.buf.range_code_action()<CR>", {
    name = "Code actions…",
  })
end

return M
