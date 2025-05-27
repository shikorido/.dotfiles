-- TODO: Figure out how to make fugitive understand worktrees,
-- because it always shows branch for the main git worktree.
--
-- UPD. As can be seen in issues history,
-- tpope did a great work to support worktrees.
-- Edge cases still exist, refer to issues.
-- The TODO was written when I used git from msys,
-- which obviosly almost no one supports.
return {
  "tpope/vim-fugitive",
  config = function()
    local _ = CFG_REQ("remap").fugitive
  end,
}
