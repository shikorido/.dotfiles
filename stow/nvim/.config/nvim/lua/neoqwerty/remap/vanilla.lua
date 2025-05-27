local util = CFG_REQ("util")
local vars = CFG_REQ("vars")
local cfgs = vars.home .. "/.config/nvim/lua/" .. vars.base

vim.keymap.set({ "n", "x" }, "<leader>d", [["_d]])
-- Greatest remap (and fix) ever. No virtualedit=onemore needed.
vim.keymap.set("x", "<leader>p", util.greatest_remap_fix) --"_dP
-- Next greatest remap ever: asbjornHaland
vim.keymap.set({ "n", "x" }, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])

vim.keymap.set("x", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("x", "K", ":m '<-2<CR>gv=gv")

vim.keymap.set("n", "J", [[m"J`"]])
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz")
vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz")
vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz")
vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz")

vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])

vim.keymap.set("n", "<leader>x", "<cmd>silent !chmod +x %<CR>")

-- Remap from horrible capital U that will behave like lower u.
vim.keymap.set("n", "U", "u")
vim.keymap.set("n", "Q", "<Nop>")

-- Fixes visual block inserting.
vim.keymap.set("i", "<C-c>", "<Esc>")

vim.keymap.set("n", "<leader>bd", "<cmd>%bd|e#|bd#<CR>")
--vim.keymap.set("n", "<leader>bw", "<cmd>%bw|e#|bw#<CR>")

for _, i in ipairs({ 2, 4, 8 }) do
  vim.keymap.set("n", "<leader>st" .. i, function() util.set_shiftwidth(i, true) end)
  vim.keymap.set("n", "<leader>stg" .. i, function() util.set_shiftwidth(i, false) end)
end

vim.keymap.set("n", "<leader>tt", util.toggle_whitespace)
vim.keymap.set("n", "<leader>ett", util.toggle_expandtab)
vim.keymap.set("n", "<leader>fft", util.toggle_fileformat)

vim.keymap.set("n", "<leader>ct", util.to_tabs)
vim.keymap.set("n", "<leader>cs", util.to_spaces)

vim.keymap.set("n", "<leader>cd", util.cd_current)
vim.keymap.set("n", "<leader>rd", "<cmd>cd -<CR>")

vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)
-- On Windows, :Ex can't recognize ~, but :e can. Spaced paths are fine.
vim.keymap.set("n", "<leader>vpp", "<cmd>Ex " .. cfgs .. "<CR>")

vim.keymap.set("n", "<leader><leader>", vim.cmd.so)



--vim.keymap.set("n", "<leader>vwm", function()
--  require("vim-with-me").StartVimWithMe()
--end)
--vim.keymap.set("n", "<leader>svwm", function()
--  require("vim-with-me").StopVimWithMe()
--end)
