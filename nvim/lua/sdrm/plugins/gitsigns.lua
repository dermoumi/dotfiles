local GitSigns = {}

function GitSigns.setup()
  local gitsigns = require("gitsigns")

  gitsigns.setup({
    on_attach = function(buf_nr)
      local gs = package.loaded.gitsigns
      local map = require("sdrm.map")

      register_whichkey("n", "<leader>h", "Git")

      map("n", "]c", function()
        if vim.wo.diff then return "]c" end
        vim.schedule(function() gs.next_hunk() end)
        return "<Ignore>"
      end, {
        name = "Next hunk",
        buffer_nr = buf_nr,
      })

      map("n", "[c", function()
        if vim.wo.diff then return "[c" end
        vim.schedule(function() gs.prev_hunk() end)
        return "<Ignore>"
      end, {
        name = "Prev hunk",
        buffer_nr = buf_nr,
      })

      map("n", "<leader>hp", gs.preview_hunk, {
        name = "Previw hunk",
        buffer_nr = buf_nr,
      })
      map("n", "<leader>hs", ":Gitsigns stage_hunk<CR>", {
        name = "Stage hunk",
        buffer_nr = buf_nr,
      })
      map("n", "<leader>hu", gs.undo_stage_hunk, {
        name = "Undo hunk",
        buffer_nr = buf_nr,
      })
      map("n", "<leader>hr", ":Gitsigns reset_hunk<CR>", {
        name = "Revert hunk",
        buffer_nr = buf_nr,
      })
      map("n", "<leader>hS", gs.stage_buffer, {
        name = "Stage buffer",
        buffer_nr = buf_nr,
      })
      map("n", "<leader>hU", gs.reset_buffer, {
        name = "Reset buffer",
        buffer_nr = buf_nr,
      })
      map("n", "<leader>hR", gs.reset_buffer_index, {
        name = "Revert buffer",
        buffer_nr = buf_nr,
      })
      map("n", "<leader>hb", function()
        gs.blame_line({ full = true })
      end, {
        name = "Blame line",
        buffer_nr = buf_nr,
      })
      map("n", "<leader>hB", gs.toggle_current_line_blame, {
        name = "Toggle current line blame",
        buffer_nr = buf_nr,
      })
      map("n", "<leader>hd", gs.diffthis, {
        name = "Show diff",
        buffer_nr = buf_nr,
      })
      map("n", "<leader>hD", function()
        gs.diffthis("~")
      end, {
        name = "Show diff to HEAD",
        buffer_nr = buf_nr,
      })
      map("n", "<leader>hH", gs.toggle_deleted, {
        name = "Toggle deleted",
        buffer_nr = buf_nr,
      })
    end
  })
end

return GitSigns
