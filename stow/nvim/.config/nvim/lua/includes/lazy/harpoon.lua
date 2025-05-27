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
            local harpoon_extensions = require("harpoon.extensions")

            harpoon:setup({})
            harpoon:extend(harpoon_extensions.builtins.highlight_current_file())

            -- Basic Telescope configuration
            local conf = require("telescope.config").values
            local function toggle_telescope(harpoon_files)
                local file_paths = {}
                for _, item in ipairs(harpoon_files.items) do
                    table.insert(file_paths, item.value)
                end

                require("telescope.pickers").new({}, {
                    prompt_title = "Harpoon",
                    finder = require("telescope.finders").new_table({
                        results = file_paths
                    }),
                    previewer = conf.file_previewer({}),
                    sorter = conf.generic_sorter({})
                }):find()
            end

            vim.keymap.set("n", "<leader>A", function() harpoon:list():prepend() end)
            vim.keymap.set("n", "<leader>a", function() harpoon:list():add() end)
            vim.keymap.set("n", "<C-s>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)
            vim.keymap.set("n", "<leader><C-s>", function() toggle_telescope(harpoon:list()) end)

            vim.keymap.set("n", "<C-h>", function() harpoon:list():select(1) end)
            vim.keymap.set("n", "<C-j>", function() harpoon:list():select(2) end)
            vim.keymap.set("n", "<C-k>", function() harpoon:list():select(3) end)
            vim.keymap.set("n", "<C-l>", function() harpoon:list():select(4) end)
            vim.keymap.set("n", "<leader><C-h>", function() harpoon:list():replace_at(1) end)
            vim.keymap.set("n", "<leader><C-j>", function() harpoon:list():replace_at(2) end)
            vim.keymap.set("n", "<leader><C-k>", function() harpoon:list():replace_at(3) end)
            vim.keymap.set("n", "<leader><C-l>", function() harpoon:list():replace_at(4) end)

            -- Toggle previous & next buffers stored within Harpoon list
            -- 1. Does not work as intended (not saving latest index and switches from internal index).
            -- 2. <C-S-Letter> is not passed correctly to terminal, instead it passes <C-Letter> (case-insensitive) thereforce it breaks Telescope git search and harpoon's select:(2) bind.
            --vim.keymap.set("n", "<C-P>", function() harpoon:list():prev() end)
            --vim.keymap.set("n", "<C-N>", function() harpoon:list():next() end)

            harpoon:extend({
                UI_CREATE = function(cx)
                    vim.keymap.set("n", "<C-v>", function()
                        harpoon.ui:select_menu_item({ vsplit = true })
                    end, { buffer = cx.bufnr })

                    vim.keymap.set("n", "<C-x>", function()
                        harpoon.ui:select_menu_item({ split = true })
                    end, { buffer = cx.bufnr })

                    vim.keymap.set("n", "<C-t>", function()
                        harpoon.ui:select_menu_item({ tabedit = true })
                    end, { buffer = cx.bufnr })
                end
            })
        end
    }
}
