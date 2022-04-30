local GitGutter = {}

function GitGutter.setup()
  local map = require("sdrm.map")

  register_whichkey("n", "<leader>h", "Git")
  register_whichkey("n", "<leader>hp", "Preview hunk")
  register_whichkey("n", "<leader>hs", "Stage hunk")
  register_whichkey("n", "<leader>hu", "Undo hunk")
  register_whichkey("n", "]c", "Next hunk")
  register_whichkey("n", "[c", "Previous hunk")

  map("n", "<leader>hR", "<cmd>!git checkout -- %<cr>", {
    name = "Revert file",
  })
  map("n", "<leader>hS", "<cmd>!git add %<cr>", {
    name = "Stage file",
  })
  map("n", "<leader>hU", "<cmd>!git reset HEAD %<cr>", {
    name = "Undo file",
  })
end

return GitGutter
