-- https://stackoverflow.com/questions/71152802/how-to-override-color-scheme-in-neovim-lua-config-file

--vim.opt.statusline = "%<%F %h%w%y%m%r%=EOL:%{&ff} | TAB:%{&et?'spaces':'tabs'} | TW:%{&ts} | %-14.(%l,%c%V%) %P"

vim.opt.mouse = ""

vim.opt.guicursor = ""

-- Neovim hides last newline on file opening while inferring value of eol.
-- If file has nl-at-eof, it will set eol, otherwise unset.
-- Option eol is responsible for newline appension
-- to the end of file on writing (saving), but due to the aforementioned
-- behavior the option is rather discouraging.
-- Option fixeol complements eol when inferred eol is false
-- (file had no nl-at-eol on opening), in this case fixeol will anyway
-- restore nl-at-eol, even if eol is false (except binary, ofc).
-- If file has 2 newlines at the end, opening the file in neovim
-- will hide last newline, previous eol value does not matter,
-- it anyway will be locally inferred for the new buffer.
-- In the same time, [ft]plugin (e.g. sleuth) autocmds (e.g. BufRead, BufEnter),
-- can remove newline at eof if eol is false.
-- And sometimes it makes everything even more discouraging.
-- :help eol-and-eof
--vim.opt.eol = true
--vim.opt.fixeol = true
--vim.api.nvim_create_autocmd("BufEnter", {
--  callback = function()
--    vim.bo.eol = true
--    vim.bo.fixeol = true
--  end
--})

vim.opt.number = true
vim.opt.relativenumber = true

-- https://vi.stackexchange.com/questions/4244/what-is-softtabstop-used-for
-- echo &ts &sw &sts &et &smarttab &autoindent &smartindent &cindent &backspace &indentexpr
-- set ts=8 sw=4 sts=1 noet nosmarttab noautoindent nosmartindent nocindent backspace=indent,eol,start indentexpr=

-- true - distinct behavior for indent and text,
-- false - behave like text.
vim.opt.smarttab = true
vim.opt.tabstop = 4
-- indent/text behavior depends on smarttab.
-- 0 - disable (follow tabstop, i.e. insert tab),
-- negative - follow shiftwidth.
vim.opt.softtabstop = -1
vim.opt.shiftwidth = 4
-- false - insert tabs if aligned with tabstop, otherwise spaces;
-- true - always spaces.
vim.opt.expandtab = false
vim.opt.listchars = {
  tab   = "» ",
  space = "·",
  trail = "·",
  --trail = "-",
  --eol   = "↴",
  nbsp  = "␣"
}

vim.opt.smartindent = true
vim.opt.ignorecase = true
-- \c for case-insensitive search,
-- \C for case-sensitive search.
-- Smartcase has point if ignorecase is true.
vim.opt.smartcase = true

vim.opt.wrap = true

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = vim.fs.normalize(CFG_REQ("vars").home .. "/.vim/undodir")
vim.opt.undofile = true
vim.opt.undolevels = 10000

vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.termguicolors = true

vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")

vim.opt.updatetime = 50

vim.opt.colorcolumn = "80,100"

vim.g.netrw_banner = 0
vim.g.netrw_browse_split = 0
vim.g.netrw_bufsettings = 'noma nomod nu rnu nobl nowrap ro'
vim.g.netrw_winsize = 25
