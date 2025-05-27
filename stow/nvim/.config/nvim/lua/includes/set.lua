-- https://stackoverflow.com/questions/71152802/how-to-override-color-scheme-in-neovim-lua-config-file

if vim.loop.os_uname().version:match("Windows") then
    vim.opt.shell = "C:\\msys64\\usr\\bin\\bash.exe"
    vim.opt.shellcmdflag = "-c"
    vim.opt.shellquote = ""
    vim.opt.shellxquote = ""
    -- Changes backslashes slashes to forward slashes in shell invocations.
    vim.opt.shellslash = true
end

vim.opt.statusline = "%<%f %h%w%y%m%r%=EOL:%{&ff} | TAB:%{&et?'spaces':'tabs'} | TW:%{&ts} | %-14.(%l,%c%V%) %P"

vim.opt.mouse = ""

vim.opt.guicursor = ""

vim.opt.nu = true
vim.opt.relativenumber = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = false  --true
vim.opt.listchars = {
    tab   = "» ",
    space = "·",
    trail = "·",
    --trail = "-",
    --eol   = "↴",
    nbsp  = "␣"
}

vim.opt.smartindent = true
-- Can be used with \c for case-insensitive search
-- or with \C for case-sensitive search
-- So smartcase is not actually applicable if you want to search case-sensitive sometime
-- UDP. Smartcase has point only when ignorecase is setted
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- filetype (can be better to automate that when entering to hex view)...
-- vim.opt.ft = "xxd"

vim.opt.wrap = true

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true
vim.opt.undolevels = 10000

vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.termguicolors = true

vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")

vim.opt.updatetime = 50

vim.opt.colorcolumn = "100"

vim.g.netrw_banner = 0
vim.g.netrw_browse_split = 0
vim.g.netrw_bufsettings = 'noma nomod nu rnu nobl nowrap ro'
vim.g.netrw_winsize = 25

