-- https://lazy.folke.io/spec
return {
  {
    --"nvim-lua/plenary.nvim",
    -- Using forked version to get msys2 paths handling.
    "shikorido/plenary.nvim",
    branch = "msys2-path-support",
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

