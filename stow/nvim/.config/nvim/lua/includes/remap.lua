--local confd = os.getenv("LOCALAPPDATA")

vim.g.mapleader = " "
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

-- restart TS for the current buffer
vim.keymap.set("n", "<leader>tsr", "<cmd>silent TSRestart<CR>")

-- for Makefile experience
local function SetTabWidth(tw, bo)
    if bo == nil then
        bo = true
    end
    if bo then
        vim.bo.tabstop = tw or 4
        vim.bo.softtabstop = tw or 4
        vim.bo.shiftwidth = tw or 4
    else
        vim.opt.tabstop = tw or 4
        vim.opt.softtabstop = tw or 4
        vim.opt.shiftwidth = tw or 4
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            vim.bo[buf].tabstop     = vim.opt.tabstop:get()
            vim.bo[buf].softtabstop = vim.opt.softtabstop:get()
            vim.bo[buf].shiftwidth  = vim.opt.shiftwidth:get()
            -----@diagnostic disable-next-line:undefined-field
            --vim.bo[buf].expandtab   = vim.opt.expandtab:get()
        end
    end
end
vim.keymap.set("n", "<leader>st2", function() SetTabWidth(2, true) end)
vim.keymap.set("n", "<leader>st4", function() SetTabWidth(4, true) end)
vim.keymap.set("n", "<leader>st8", function() SetTabWidth(8, true) end)
vim.keymap.set("n", "<leader>stg2", function() SetTabWidth(2, false) end)
vim.keymap.set("n", "<leader>stg4", function() SetTabWidth(4, false) end)
vim.keymap.set("n", "<leader>stg8", function() SetTabWidth(8, false) end)
vim.keymap.set("n", "<leader>tt", "<cmd>silent setlocal list!<CR>")
--Vim disables expandtab upon entering Makefile buffer
--vim.keymap.set("n", "<leader>tt", "<cmd>silent setlocal list!<CR><cmd>silent setlocal expandtab!<CR>")

vim.keymap.set("n", "<leader>cd", "<cmd>silent cd %:h<CR>")

vim.keymap.set("n", "<leader>bd", "<cmd>%bd|e#<CR>")
-- vim.keymap.set("n", "<leader>bw", "<cmd>%bw|e#<CR>")
-- vim.keymap.set("n", "<leader>bd", "<cmd>%bd|e#|bd#<CR>")
-- vim.keymap.set("n", "<leader>bw", "<cmd>%bw|e#|bw#<CR>")

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

--vim.keymap.set("n", "Y", "yg$")
vim.keymap.set("n", "J", "mzJ`z")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")
vim.keymap.set("n", "<leader>zig", "<cmd>LspRestart<CR>")

--vim.keymap.set("n", "<leader>vwm", function()
--    require("vim-with-me").StartVimWithMe()
--end)
--vim.keymap.set("n", "<leader>svwm", function()
--    require("vim-with-me").ShopVimWithMe()
--end)

-- greatest remap ever
vim.keymap.set("x", "<leader>p", [["_dP]])

-- next greatest remap ever : asbjornHaland
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]])
-- It has really strange behavior by yanking all the lines
-- So it can be remaped recursive or just [["+yg$]] or [["+yg_]]
-- https://neovim.io/doc/user/lua-guide.html
vim.keymap.set("n", "<leader>Y", [["+Y]])
--vim.keymap.set("n", "<leader>Y", [["+Y]], { remap = true })
--vim.keymap.set("n", "<leader>Y", [["+yg$]])

vim.keymap.set({ "n", "v" }, "<leader>d", [["_d]])

-- Temporary remap from horrible capital U that will behave like lower u
vim.keymap.set("n", "U", "u")

-- Affects on visual block inserting (mb neovim fixes it, but vim not)
vim.keymap.set("i", "<C-c>", "<Esc>")

vim.keymap.set("n", "Q", "<Nop>")
-- For linux?
vim.keymap.set("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>")
vim.keymap.set("n", "<leader>f", vim.lsp.buf.format)

vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz")
vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz")
vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz")
vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz")

vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])
-- For linux to add executing flag to the current file.
vim.keymap.set("n", "<leader>x", "<cmd>silent !chmod +x %<CR>")
--vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR><silent>", { silent = true })
-- <silent> will work for <cmd> mode but { silent = true } not
--vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR><silent>", { silent = true })

-- Rust
-- vim.keymap.set(
--     "n",
--     "<leader>ee",
--     "oif err != nil {<CR>}<Esc>Oreturn err<Esc>"
-- )
-- vim.keymap.set(
--     "n",
--     "<leader>ea",
--     "oassert.NoError(err, \"\")<Esc>F\";a"
-- )
-- vim.keymap.set(
--     "n",
--     "<leader>ef",
--     "oif err != nil {<CR>}<Esc>Olog.Fatalf(\"error: %s\\n\", err.Error())<Esc>jj"
-- )
-- vim.keymap.set(
--     "n",
--     "<leader>el",
--     "oif err != nil {<CR>}<Esc>O.logger.Error(\"error\", \"error\", err)<Esc>F.;i"
-- )

-- Strange behavior on Windows when :Ex can't recognize ~ but :e can
-- In that case space paths might be destroyed due to $HOME early expansion
if vim.loop.os_uname().version:match("Windows") then
    vim.keymap.set("n", "<leader>vpp", "<cmd>Ex " .. os.getenv("HOME") .. "/.config/nvim/lua/includes<CR>")
else
    vim.keymap.set("n", "<leader>vpp", "<cmd>Ex ~/.config/nvim/lua/includes<CR>")
end

vim.keymap.set("n", "<leader>mr", "<cmd>CellularAutomaton make_it_rain<CR>")

vim.keymap.set("n", "<leader><leader>", function()
    vim.cmd("so")
end)
