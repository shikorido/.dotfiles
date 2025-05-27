-- https://lazy.folke.io/spec
return {
  {
    --"nvim-lua/plenary.nvim",
    -- UPD. Plenary.nvim is now archived. I'll occasionally
    --      fix encountered issues in my fork.
    --      As for now, it fixes mixed slashes in harpoon.
    "shikorido/plenary.nvim",
    --
    -- Using forked version to get msys2 paths handling.
    -- Currently this is used for msys2 git.
    -- Git for windows is an obvious solution
    -- to not interfere with posix layer whatsoever,
    -- but I wanted to give it a try, and now
    -- I'm more inclined to the git for windows.
    -- Making msys2 paths support for plenary,
    -- telescope, gitsigns, fugitive is rather tedious
    -- and gives no benefits cause msys2
    -- layer is anyway should be avoided everywhere
    -- in native windows development.
    -- Don't know about cygwin, probably, it may
    -- have benefits there, however, some
    -- plugins already implement support for cygwin (LuaSnip).
    -- The same idea goes to bash/zsh shells
    -- from msys2 to nvim for windows.
    -- Same path issues, same tedious solutions
    -- despite how convenient unix shells
    -- and utils are.
    --
    -- !!! === IMPORTANT === !!!
    -- UPD. Figured out what was hapenning (with chatgpt, ofc).
    -- Msys layer has its own arguments processing
    -- which can be disabled with MSYS=noglob environment
    -- variable, this way, in native->msys calls arguments
    -- won't be affected by MSYS globbing behavior
    -- (solves {} disappearance in stash@{N}, for example).
    -- Nevertheless, there is one more special behavior
    -- regarding msys git. Its internal logic has one serious flaw.
    -- A windows path given to --work-tree parameter
    -- breaks some assumptions which in turn
    -- makes git think that the path is actually a windows one.
    -- Therefore, git thinks that some file under worktree is
    -- outside a worktree, while an error message prints both
    -- paths in msys-style, so they look fine.
    -- However, with `rev-parse --show-toplevel` git
    -- prints windows-style path (exactly the one that was
    -- given to --work-tree).
    -- Hence, my solution for gitsigns always converts paths from
    -- windows to unix if git comes from msys,
    -- and converts returned paths back to windows.
    -- !!! === IMPORTANT === !!!
    --
    --url = "git@github.com:shikorido/plenary.nvim",
    --branch = "msys2-path-support",
    lazy = true,
    -- Triggers hererocks build and makes copy of "lazy/plenary.nvim".
    -- Pointless unless we need to apply termux hererocks patches.
    --name = "plenary"
  },

  {
    "eandrju/cellular-automaton.nvim",
    cmd = "CellularAutomaton",
  },
}

