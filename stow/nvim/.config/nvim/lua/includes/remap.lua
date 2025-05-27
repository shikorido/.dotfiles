--local confd = os.getenv("LOCALAPPDATA")

vim.g.mapleader = " "
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

-- Rebind Ctrl-e (occupied by harpoon) to Ctrl-t.
-- UPD. Harpoon was bound to Ctrl-s.
--vim.keymap.set("n", "<C-t>", "<C-e>")

-- restart TS for the current buffer
vim.keymap.set("n", "<leader>tsr", "<cmd>silent TSRestart<CR>")

vim.keymap.set("n", "<leader>g=", "gg=G``")
vim.keymap.set("n", "<leader>st2", function() SetTabWidth(2, true) end, { desc = "Tabwidth 2 bo" })
vim.keymap.set("n", "<leader>st4", function() SetTabWidth(4, true) end, { desc = "Tabwidth 4 bo" })
vim.keymap.set("n", "<leader>st8", function() SetTabWidth(8, true) end, { desc = "Tabwidth 8 bo" })
vim.keymap.set("n", "<leader>stg2", function() SetTabWidth(2, false) end, { desc = "Tabwidth 2 all buffers" })
vim.keymap.set("n", "<leader>stg4", function() SetTabWidth(4, false) end, { desc = "Tabwidth 4 all buffers" })
vim.keymap.set("n", "<leader>stg8", function() SetTabWidth(8, false) end, { desc = "Tabwidth 8 all buffers" })
--Vim disables expandtab upon entering Makefile buffer
--vim.keymap.set("n", "<leader>tt", "<cmd>silent set list!<CR>")
--vim.keymap.set("n", "<leader>tt", "<cmd>silent setlocal list!<CR>")
--vim.keymap.set("n", "<leader>tt", "<cmd>silent setlocal list!<CR><cmd>silent setlocal expandtab!<CR>")
vim.keymap.set("n", "<leader>tt", function()
	---@diagnostic disable-next-line:undefined-field
	vim.opt_local.list = not vim.opt_local.list:get()
	---@diagnostic disable-next-line:undefined-field
	if vim.opt_local.list:get() then
		vim.notify("Whitespace: visible", vim.log.levels.INFO)
	else
		vim.notify("Whitespace: hidden", vim.log.levels.INFO)
	end
end, { desc = "Toggle whitespace visibility" })
--vim.keymap.set("n", "<leader>ett", "<cmd>silent setlocal expandtab!<CR>")
vim.keymap.set("n", "<leader>ett", function()
	---@diagnostic disable-next-line:undefined-field
	vim.opt_local.expandtab = not vim.opt_local.expandtab:get()
	---@diagnostic disable-next-line:undefined-field
	if vim.opt_local.expandtab:get() then
		vim.notify("Tabs: spaces enabled", vim.log.levels.INFO)
	else
		vim.notify("Tabs: real tabs enabled", vim.log.levels.INFO)
	end
end, { desc = "Toggle expandtab" })
vim.keymap.set("n", "<leader>fft", function()
	local current = vim.bo.fileformat
	if current == "unix" then
		vim.bo.fileformat = "dos"
		vim.notify("EOL: switched to CRLF (dos)", vim.log.levels.INFO)
	else
		vim.bo.fileformat = "unix"
		vim.notify("EOL: switched to LF (unix)", vim.log.levels.INFO)
	end
	if current ~= "dos" and current ~= "unix" then
		print("EOL: neither dos nor unix, why?")
	end
end, { desc = "Toggle fileformat LF/CRLF" })

-- Print "help filename-modifiers" to get help.
-- % does not work in netrw under certain circumstances.
--vim.keymap.set("n", "<leader>cd", "<cmd>silent cd %:p:h<CR>")
vim.keymap.set("n", "<leader>cd", function()
	local path
	if vim.bo.filetype == "netrw" then
		-- "nvim ." leaves % untouched and sets # instead (edge case).
		if vim.fn.expand("%") ~= "" then
			path = vim.fn.expand("%:p:h")
		else
			path = vim.fn.expand("#:p:h")
		end
		vim.cmd("cd " .. vim.fn.fnameescape(path))
	else
		if vim.fn.expand("%") ~= "" then
			path = vim.fn.expand("%:p:h")
			vim.cmd("cd " .. vim.fn.fnameescape(path))
		end
	end
end)
vim.keymap.set("n", "<leader>rd", "<cmd>silent cd -<CR>")

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

--vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz")
--vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz")
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
-- In that case space paths might be destroyed due to $HOME early expansion.
if vim.loop.os_uname().version:find("Windows") then
	vim.keymap.set("n", "<leader>vpp", "<cmd>Ex " .. os.getenv("HOME") .. "/.config/nvim/lua/includes<CR>")
else
	vim.keymap.set("n", "<leader>vpp", "<cmd>Ex ~/.config/nvim/lua/includes<CR>")
end

vim.keymap.set("n", "<leader>mr", "<cmd>CellularAutomaton make_it_rain<CR>")

vim.keymap.set("n", "<leader><leader>", function()
	vim.cmd("so")
end)
