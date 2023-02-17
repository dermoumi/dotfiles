local util = require("lazy.core.util")
local autoformat = true
local M = {}

function M.toggle_autoformat()
  autoformat = not autoformat

  if autoformat then
    util.info("Enabled format on save", { title = "Format" })
  else
    util.warn("Disabled format on save", { title = "Format" })
  end
end

function M.format(bufnr)
  if not autoformat then
    return
  end

  local ft = vim.bo[bufnr].filetype
  local sources = require("null-ls.sources")
  local have_nls = #sources.get_available(ft, "NULL_LS_FORMATTING") > 0

  local format_opts = vim.tbl_deep_extend("force", {
    bufnr = bufnr,
    filter = function(client)
      if have_nls then
        return client.name == "null-ls"
      end

      return client.name ~= "null-ls"
    end,
  }, {})

  vim.lsp.buf.format(format_opts)
end

return M
