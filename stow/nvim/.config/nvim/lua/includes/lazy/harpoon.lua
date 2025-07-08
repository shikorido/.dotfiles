return {
    {
        "ThePrimeagen/harpoon",
        branch = "harpoon2",
        dependencies = {
            "shikorido/plenary.nvim"
            --"nvim-lua/plenary.nvim"
        },
        config = function()
            local harpoon = require("harpoon")

            harpoon:setup()

            vim.keymap.set("n", "<leader>A", function() harpoon:list():prepend() end)
            vim.keymap.set("n", "<leader>a", function() harpoon:list():add() end)
            vim.keymap.set("n", "<C-e>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)

            vim.keymap.set("n", "<C-h>", function() harpoon:list():select(1) end)
            vim.keymap.set("n", "<C-t>", function() harpoon:list():select(2) end)
            vim.keymap.set("n", "<C-n>", function() harpoon:list():select(3) end)
            vim.keymap.set("n", "<C-s>", function() harpoon:list():select(4) end)
            vim.keymap.set("n", "<leader><C-h>", function() harpoon:list():replace_at(1) end)
            vim.keymap.set("n", "<leader><C-t>", function() harpoon:list():replace_at(2) end)
            vim.keymap.set("n", "<leader><C-n>", function() harpoon:list():replace_at(3) end)
            vim.keymap.set("n", "<leader><C-s>", function() harpoon:list():replace_at(4) end)

            -- Toggle previous & next buffers stored within Harpoon list
            -- 1. Does not work as intended (not saving lastest index and switches from internal index).
            -- 2. <C-S-Letter> is not passed correctly to terminal, instead it passes <C-Letter> (case-insensitive) thereforce it breaks Telescope git search and harpoon's select:(2) bind.
            --vim.keymap.set("n", "<C-P>", function() harpoon:list():prev() end)
            --vim.keymap.set("n", "<C-N>", function() harpoon:list():next() end)
        end
    }
}
