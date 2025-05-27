require('includes.set')
require('includes.remap')
require('includes.lazy_init')
--require('includes.clipboardYDisable')

-- DO.not
-- DO NOT INCLUDE THIS

-- If I want to keep doing lsp debugging
--function restart_htmx_lsp()
--    require("lsp-debug-tools").restart({ expected = {}, name = "htmx-lsp", cmd = { "htmx-lsp", "--level", "DEBUG" }, root_dir = vim.loop.cwd() })
--end

-- DO NOT INCLUDE THIS
-- DO.not

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd
local usercmd = vim.api.nvim_create_user_command

local IncludesGroup = augroup("Includes", {})
local yank_group = augroup("HighlightYank", {})


function R(name)
    require("plenary.reload").reload_module(name)
end


-----@diagnostic disable-next-line:unused-local,unused-function
local function endswith(str, suffix)
	return str:sub(-#suffix) == suffix
end

autocmd("BufEnter", {
    group = IncludesGroup,
    callback = function()
        -- Get the current file name
        local filename = vim.fn.expand("%")

        -- Check if file ends with specific suffixes
        if endswith(filename, ".log") then
            vim.bo.filetype = "messages"
        elseif endswith(filename, ".service") then
            vim.bo.filetype = "systemd"
        end
    end
})

autocmd("FileType", {
    pattern = { "make" },
    callback = function()
        -- I thought to make global expandtab var to propagate its value
        -- But setting everytime expandtab to 0 in makefiles even using bind is annoying
        -----@diagnostic disable-next-line:undefined-field
        --vim.bo.expandtab = vim.opt.expandtab:get()
        vim.bo.expandtab = false
    end
})

-- Restart TS
usercmd("TSRestart", function()
    local bufnr = vim.api.nvim_get_current_buf()
    local lang  = vim.treesitter.language.get_lang(vim.bo[bufnr].filetype)

    vim.treesitter.highlighter.active[bufnr] = nil
    vim.treesitter.stop(bufnr)
    vim.treesitter.start(bufnr, lang)
    --or
    --vim.cmd(":e")

    --detach not found
    --local ts_utils = require("nvim-treesitter.ts_utils")
    --ts_utils.detach(bufnr)
    --ts_utils.attach(bufnr)

    print("Tree-sitter restarted for buffer " .. bufnr)
end, {})


vim.filetype.add({
    extension = {
        templ = "templ"
    }
})

autocmd("TextYankPost", {
    group = yank_group,
    pattern = "*",
    callback = function()
        vim.highlight.on_yank({
            higroup = "IncSearch",
            timeout = 40
        })
    end
})

autocmd({"BufWritePre"}, {
    group = IncludesGroup,
    pattern = "*",
    command = [[%s/\s\+$//e]]
})

autocmd("BufEnter", {
    group = IncludesGroup,
    callback = function()
        if vim.bo.filetype == "zig" then
            vim.cmd.colorscheme("tokyonight-night")
        else
            vim.cmd.colorscheme("rose-pine-moon")
        end
    end
})

autocmd("LspAttach", {
    group = IncludesGroup,
    callback = function(e)
        local opts = { buffer = e.buf }
        vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
        vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
        vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)
        vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts)
        vim.keymap.set("n", "<leader>vca", function() vim.lsp.buf.code_action() end, opts)
        vim.keymap.set("n", "<leader>vrr", function() vim.lsp.buf.references() end, opts)
        vim.keymap.set("n", "<leader>vrn", function() vim.lsp.buf.rename() end, opts)
        vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)
        vim.keymap.set("n", "[d", function() vim.diagnostic.goto_next() end, opts)
        vim.keymap.set("n", "]d", function() vim.diagnostic.goto_prev() end, opts)
    end
})

