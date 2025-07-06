return {
    "nvim-telescope/telescope.nvim",

    version = "0.1.*",

    dependencies = {
        "nvim-lua/plenary.nvim"
    },

    config = function()
        require("telescope").setup({
            --pickers = {
            --    git_files = {
            --        git_command = { "git", "ls-files" }
            --    }
            --}
        })

        local builtin = require("telescope.builtin")
        vim.keymap.set("n", "<leader>pf", builtin.find_files, {})
        -- git_files sucks ass in mingw64 with other git functions
        vim.keymap.set("n", "<C-[>", builtin.git_files, {})
        vim.keymap.set("n", "<C-p>", function()
            --function vim.find_files_from_project_git_root()
            local function is_git_repo()
                vim.fn.system("git rev-parse --is-inside-work-tree")
                return vim.v.shell_error == 0
            end
            local function get_git_root()
                local dot_git_path = vim.fn.finddir(".git", ".;")
                return vim.fn.fnamemodify(dot_git_path, ":h")
            end
            local opts = {}
            if is_git_repo() then
                opts = {
                    cwd = get_git_root(),
                }
            end
            require("telescope.builtin").find_files(opts)
            --end
        end)
        vim.keymap.set("n", "<leader>pws", function()
            local word = vim.fn.expand("<cword>")
            builtin.grep_string({ search = word })
        end)
        vim.keymap.set("n", "<leader>pWs", function()
            local word = vim.fn.expand("<cWORD>")
            builtin.grep_string({ search = word })
        end)
        vim.keymap.set("n", "<leader>ps", function()
            builtin.grep_string({ search = vim.fn.input("Grep > ") })
        end)
        vim.keymap.set("n", "<leader>vh", builtin.help_tags, {})
    end
}
