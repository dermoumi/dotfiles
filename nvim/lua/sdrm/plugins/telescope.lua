local Telescope = {}

function Telescope.setup()
  local telescope = require("telescope")
  local telescope_builtin = require("telescope.builtin")
  local map = require("sdrm.map")

  pcall(telescope.load_extension, "fzf")

  telescope.setup({
    extensions = {
      fzf = {
        fuzzy = true,
        override_generic_sorter = true,
        override_file_sorter = true,
        case_mode = "smart_case",
      },
    },
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

  -- Load extensions
  local extensions = {
    "fzf",
    "ui-select",
    "file_browser",
  }

  for _, extension in ipairs(extensions) do
    local loaded, _ = pcall(telescope.load_extension, extension)

    if not loaded then
      vim.notify("Failed to load telescope extension: " .. extension)
    end
  end

  -- map keys
  map("n", "<leader>ff", function()
    local ok = pcall(telescope_builtin.git_files)

    if not ok then
      telescope_builtin.fd({
        hidden = true,
      })
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
  map("n", "gj", function()
    telescope_builtin.lsp_dynamic_workspace_symbols({
      ignore_symbols = { "variable" },
    })
  end, {
    name = "Find workspace symbols…",
  })
  map("n", "gJ", telescope_builtin.lsp_dynamic_workspace_symbols, {
    name = "which_key_ignore",

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

  if telescope.extensions.file_browser then
    map("n", "<leader>fe", function()
      telescope.extensions.file_browser.file_browser({
        path = "%:p:h",
      })
    end, {
      name = "File explorer…",
    })
  end
end

return Telescope
