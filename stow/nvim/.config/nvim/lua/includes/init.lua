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

-- For Makefile/Lua experience
function SetTabWidth(tw, bo)
	if bo == nil then
		bo = true
	end
	if tw == nil then
		tw = 4
	end
	if bo then
		vim.bo.tabstop = tw
		vim.bo.softtabstop = tw
		vim.bo.shiftwidth = tw
		vim.notify("Tabwidth: " .. tw .. " for the current buffer", vim.log.levels.INFO)
	else
		vim.opt.tabstop = tw
		vim.opt.softtabstop = tw
		vim.opt.shiftwidth = tw
		for _, buf in ipairs(vim.api.nvim_list_bufs()) do
			vim.bo[buf].tabstop     = vim.opt.tabstop:get()
			vim.bo[buf].softtabstop = vim.opt.softtabstop:get()
			vim.bo[buf].shiftwidth  = vim.opt.shiftwidth:get()
			-----@diagnostic disable-next-line:undefined-field
			--vim.bo[buf].expandtab   = vim.opt.expandtab:get()
			vim.notify("Tabwidth: " .. tw .. " for all opened buffers", vim.log.levels.INFO)
		end
	end
end

-- Convert leading spaces to tabs based on tabstop
--function ToTabs()
--	local tabstop     = vim.bo.tabstop
--	local space_pat   = string.rep(' ', tabstop)  -- make a pattern of tabstop spaces
--	local pattern     = [[^\(\t*\)]] .. space_pat
--	local replacement = [[\1\t]]
--	local count       = 0
--
--	local curpos = vim.fn.winsaveview()
--
--	-- Repeat substitution until nothing changes
--	local old_changedtick
--	repeat
--		old_changedtick = vim.b.changedtick
--		vim.cmd(string.format([[silent %s/%s/%s/e]], '%s', pattern, replacement))
--		count = count + 1
--	until vim.b.changedtick == old_changedtick or count > 1000  -- prevent infinite loop
--	vim.fn.winrestview(curpos)
--end

-----@diagnostic disable-next-line:unused-local,unused-function
local function endswith(str, suffix)
	return str:sub(- #suffix) == suffix
end

autocmd("BufEnter", {
	group = IncludesGroup,
	callback = function()
		if vim.bo.filetype == "zig" then
			vim.cmd.colorscheme("tokyonight-night")
		else
			vim.cmd.colorscheme("rose-pine-moon")
		end

		if vim.bo.filetype == "make" then
			vim.bo.expandtab = false
		end

		-- Get the current file name
		local filename = vim.fn.expand("%")

		-- Check if file ends with specific suffixes
		if endswith(filename, ".log") then
			vim.bo.filetype = "messages"
		elseif endswith(filename, ".service") then
			vim.bo.filetype = "systemd"
		elseif endswith(filename, ".source") then
			vim.bo.filetype = "sh"
		end
	end
})

--autocmd("FileType", {
--    pattern = { "make" },
--    callback = function()
--        -- I thought to make global expandtab var to propagate its value
--        -- But setting everytime expandtab to 0 in makefiles even using bind is annoying
--        -----@diagnostic disable-next-line:undefined-field
--        --vim.bo.expandtab = vim.opt.expandtab:get()
--        vim.bo.expandtab = false
--    end
--})

autocmd("FileType", {
	group = IncludesGroup,
	pattern = { "dosbatch", "ps1" },
	callback = function()
		vim.bo.fileformat = "dos"
	end
})

autocmd({ "BufNewFile", "BufRead" }, {
	group = IncludesGroup,
	pattern = "*",
	callback = function()
		if vim.bo.readonly or not vim.bo.modifiable then
			return  -- skip help/main/preview buffers
		end
		-- Neovim for Windows assumes dos file format by default if it cannot be inferred.
		if vim.bo.filetype ~= "dosbatch" and vim.bo.filetype ~= "ps1" then
			vim.bo.fileformat = "unix"
		end
	end
})

-- Restart TS
usercmd("TSRestart", function()
	local bufnr = vim.api.nvim_get_current_buf()
	local lang  = vim.treesitter.language.get_lang(vim.bo[bufnr].filetype)

	vim.treesitter.highlighter.active[bufnr] = nil
	vim.treesitter.stop(bufnr)
	vim.treesitter.start(bufnr, lang)

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

autocmd({ "BufWritePre" }, {
	group = IncludesGroup,
	pattern = "*",
	-- Moves cursor to the last trimmed trailing space position
	--command = [[%s/\s\+$//e]]
	callback = function()
		-- Save current view (cursor, scroll position, etc.)
		local curpos = vim.fn.winsaveview()
		-- Perform the substitution silently
		vim.cmd([[%s/\s\+$//e]])
		-- Restore cursor position
		vim.fn.winrestview(curpos)
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
