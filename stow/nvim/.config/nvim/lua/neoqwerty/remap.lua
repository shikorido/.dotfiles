local util = CFG_REQ("util")

vim.g.mapleader = " "
vim.g.maplocalleader = "\\" -- at least for Lazy.nvim UI default bindings

vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

-- Restart TreeSitter for the current buffer
vim.keymap.set("n", "<leader>tsr", "<cmd>silent TSRestart<CR>")

vim.keymap.set({ "n", "x" }, "<leader>g=", CFG_REQ("format").format_conform)
--vim.keymap.set("n", "<leader>g=", [[m":silent lockmarks keepjumps keeppatterns normal! gg=G`"<CR>]])

for _, i in ipairs({ 2, 4, 8 }) do
  vim.keymap.set("n", "<leader>st" .. i, function() util.set_tabwidth(i, true) end,
    { desc = "Tabwidth " .. i .. " bo" }
  )
  vim.keymap.set("n", "<leader>stg" .. i, function() util.set_tabwidth(i, false) end,
    { desc = "Tabwidth " .. i .. " all buffers" }
  )
end

vim.keymap.set("n", "<leader>tt", function()
  vim.wo.list = not vim.wo.list
  if vim.wo.list then
    vim.notify("Whitespace: visible", vim.log.levels.INFO)
  else
    vim.notify("Whitespace: hidden", vim.log.levels.INFO)
  end
end, { desc = "Toggle whitespace visibility" })


vim.keymap.set("n", "<leader>ett", function()
  vim.bo.expandtab = not vim.bo.expandtab
  if vim.bo.expandtab then
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


vim.keymap.set("n", "<leader>ct", function()
  local ok = util.to_tabs()
  vim.bo.expandtab = false
  if vim.bo.sw ~= 0 and vim.bo.ts ~= vim.bo.sw then
    vim.bo.ts = vim.bo.sw
  end
  if ok then
    vim.notify(
      "Every " .. vim.bo.tabstop .. " leading space(s) was/were replaced with tabs,"
      .." expandtab disabled",
      vim.log.levels.INFO
    )
  end
end, {
  desc =
  "Replace leading spaces with tabs based on shiftwidth, disable expandtab"
})

vim.keymap.set("n", "<leader>cs", function()
  local ok = util.to_spaces()
  vim.bo.expandtab = true
  if ok then
    vim.notify(
      "Leading tabs were replaced with " .. vim.bo.tabstop .. " spaces,"
      .." expandtab enabled",
      vim.log.levels.INFO
    )
  end
end, {
  desc =
  "Replace leading tabs with spaces based on tabstop, enable expandtab"
})

-- TODO: Probably implement CD stack and integrate it with harpoon+telescope.
-- key = "cwd",
-- listname = "cwd" or "__harpoon_files" default,
-- value = cwd,
-- value context can be used to store directory contents for telescope picker.
--
-- Using telescope only is not that flexible.
-- picker list = cwd,
-- values = directory contents.
--
-- It is also can be used for reverse telescope searching for filenames
-- in a stored cwd stack.
--
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
    vim.cmd("cd "..vim.fn.fnameescape(path))
  else
    if vim.fn.expand("%") ~= "" then
      path = vim.fn.expand("%:p:h")
      vim.cmd("cd "..vim.fn.fnameescape(path))
    end
  end
end)
vim.keymap.set("n", "<leader>rd", "<cmd>silent cd -<CR>")

vim.keymap.set("n", "<leader>bd", "<cmd>%bd|e#<CR>")
-- vim.keymap.set("n", "<leader>bw", "<cmd>%bw|e#<CR>")

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

vim.keymap.set("n", "J", [[m"J`"]])
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")
--vim.keymap.set("n", "<leader>zig", "<cmd>LspRestart<CR>")

--vim.keymap.set("n", "<leader>vwm", function()
--  require("vim-with-me").StartVimWithMe()
--end)
--vim.keymap.set("n", "<leader>svwm", function()
--  require("vim-with-me").StopVimWithMe()
--end)

-- Greatest remap ever.
vim.keymap.set("x", "<leader>p", [["_dP]])

-- Next greatest remap ever: asbjornHaland.
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])

vim.keymap.set({ "n", "v" }, "<leader>d", [["_d]])

-- Temporary remap from horrible capital U that will behave like lower u.
vim.keymap.set("n", "U", "u")

-- Fixes visual block inserting.
vim.keymap.set("i", "<C-c>", "<Esc>")

vim.keymap.set("n", "Q", "<Nop>")

vim.keymap.set("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>")
vim.keymap.set("n", "<leader>f", vim.lsp.buf.format)

--vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz")
--vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz")
vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz")
vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz")

vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])

vim.keymap.set("n", "<leader>x", "<cmd>silent !chmod +x %<CR>")

-- Rust.
vim.api.nvim_create_autocmd("FileType", {
  pattern = "rust",
  callback = function(event)
    local opts = { buffer = event.buf }
    vim.keymap.set(
      "n",
      "<leader>ee",
      "oif err != nil {<CR>}<Esc>Oreturn err<Esc>",
      opts
    )
    vim.keymap.set(
      "n",
      "<leader>ea",
      "oassert.NoError(err, \"\")<Esc>F\";a",
      opts
    )
    vim.keymap.set(
      "n",
      "<leader>ef",
      "oif err != nil {<CR>}<Esc>Olog.Fatalf(\"error: %s\\n\", err.Error())<Esc>jj",
      opts
    )
    vim.keymap.set(
      "n",
      "<leader>el",
      "oif err != nil {<CR>}<Esc>O.logger.Error(\"error\", \"error\", err)<Esc>F.;i",
      opts
    )
    -- Spaces after keymap to unmap are error prone (:help map-trailing-white).
    -- <buffer> is a map argument (:help map-arguments).
    vim.b[event.buf].undo_ftplugin  = (vim.b[event.buf].undo_ftplugin or "")..
      "nunmap <buffer> <leader>ee| "..
      "nunmap <buffer> <leader>ea| "..
      "nunmap <buffer> <leader>ef| "..
      "nunmap <buffer> <leader>el"
  end
})

-- Strange behavior on Windows when :Ex can't recognize ~ but :e can.
-- Spaced paths are fine.
if vim.uv.os_uname().version:find("Windows") then
  vim.keymap.set(
    "n",
    "<leader>vpp",
    "<cmd>Ex " .. CFG_REQ("vars").home .. "/.config/nvim/lua/neoqwerty<CR>")
else
  vim.keymap.set("n", "<leader>vpp", "<cmd>Ex ~/.config/nvim/lua/neoqwerty<CR>")
end

vim.keymap.set("n", "<leader>mr", "<cmd>CellularAutomaton make_it_rain<CR>")

vim.keymap.set("n", "<leader>u", "<cmd>UndotreeToggle<CR>")

vim.keymap.set("n", "<leader><leader>", function()
  vim.cmd("so")
end)
