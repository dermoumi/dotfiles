local M = {}

function M.setup()
  local map = require("sdrm.map")

  local ok, lsp_signature = pcall(require, "lsp_signature")
  if not ok then
    vim.notify("Cannot load plugin: lsp_signature")
    return
  end

  lsp_signature.setup({
    toggle_key = "<M-x>",
    handler_opts = {
      border = "none",
    },
    extra_trigger_chars = {
      "(",
    },
    padding = " ",
    hint_enable = false,
    floating_window_above_cur_line = false,
  })
end

return M
