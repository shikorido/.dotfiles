return {

    {
        -- Using forked version to get msys2 paths handling.
        "shikorido/plenary.nvim",
        branch = "msys2-bruteforce-path-support"
        --"nvim-lua/plenary.nvim",
        -- Triggers hererocks build and makes copy of "lazy/plenary.nvim".
        -- Pointless unless we need to apply termux hererocks patches.
        --name = "plenary"
    },

    "eandrju/cellular-automaton.nvim"
}
