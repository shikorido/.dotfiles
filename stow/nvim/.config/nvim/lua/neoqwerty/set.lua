local vars = CFG_REQ("vars")

--vim.opt.mouse = ""
--vim.opt.guicursor = ""

vim.opt.termguicolors = true
vim.opt.wildignorecase = true
vim.opt.fileformats = "unix,dos,mac"
vim.opt.showtabline = 2
vim.opt.tabclose = "uselast"
vim.opt.updatetime = 50
vim.opt.isfname:append("@-@")

vim.opt.colorcolumn = vars.ftDefaultOpts.colorcolumn
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.wrap = true
vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"

vim.opt.smartindent = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.backup = false
vim.opt.swapfile = false
vim.opt.undodir = vim.fs.normalize(vars.home .. "/.vim/undodir")
vim.opt.undofile = true
vim.opt.undolevels = 10000

-- 30.5 25.3 ins-smarttab ins-expandtab ins-softtabstop
vim.opt.smarttab = true
vim.opt.expandtab = false
vim.opt.tabstop = 8
vim.opt.softtabstop = -1
vim.opt.shiftwidth = 0
vim.opt.listchars = {
  tab   = "» ",
  space = "·",
  trail = "·",
  --trail = "-",
  --eol   = "↴",
  nbsp  = "␣"
}

-- https://vi.stackexchange.com/questions/4244/what-is-softtabstop-used-for
-- echo &ts &sw &sts &et &smarttab &autoindent &smartindent &cindent &backspace &indentexpr
-- set ts=8 sw=4 sts=4 noet nosmarttab noautoindent nosmartindent nocindent backspace=indent,eol,start indentexpr=

vim.g.netrw_banner = 0
vim.g.netrw_browse_split = 0
vim.g.netrw_bufsettings = 'noma nomod nu rnu nobl nowrap ro'
vim.g.netrw_winsize = 25

if vars.is_msys2 and not os.getenv("NVIM_NO_MSYS_SHELL") then
  vars.home = vars.home:gsub("\\", "/")
  local shell = vars.msys2_root .. "/usr/bin/zsh.exe"
  if not vim.o.shell:find("[/\\][a-z]*sh.exe") then
    vim.opt.shell = shell
  end
  if vim.fn.executable(vim.o.shell) == 0 then
    error("MSYS2 detected but not SHELL or zsh.exe")
  end
  -- Always call the login shell for a correct state (native->msys boundary).
  -- It is scuffed, but otherwise there is no way to tell nvim
  -- to open the fucking interactive terminal with additional arguments,
  -- doing it manually via jobstart(vim.o.shell.." -l -i",{term=true})
  -- and creating a new buffer to avoid RO warnings seems awkward.
  -- But I think I'll do that once I need some more customizations.
  vim.opt.shell = vim.o.shell:gsub("\\", "/") .. " -l"
  vim.opt.shellcmdflag = "-c"
  vim.opt.shellquote = ""
  vim.opt.shellxquote = ""
  -- Changes backslashes to forward slashes in shell invocations.
  -- WARN: %COMSPEC% invocations with vim.system become tricky.
  -- Path to cmd.exe must be provided as an absolute with doubled backslashes.
  -- It does not apply to arguments. Won't harm (shouldn't, at least), but redundant.
  -- Using system() and systemlist() should always be avoided, so a convenient
  -- wrapper, vim.system, around vim.uv.spawn was created for most commands.
  vim.opt.shellslash = true
elseif vars.is_win then
  local pwsh_available = vim.fn.executable("pwsh") == 1
  vim.opt.shell = pwsh_available and "pwsh" or "powershell"
  vim.opt.shellcmdflag = "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command "
    .. "[Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.UTF8Encoding]::new();"
    .. "$PSDefaultParameterValues['Out-File:Encoding']='utf8';"
    .. (pwsh_available and "$PSStyle.OutputRendering='PlainText';" or "")
  vim.opt.shellpipe = "> %s 2>&1"
  vim.opt.shellquote = ""
  vim.opt.shellxquote = ""
  vim.opt.shelltemp = false
end



-- Useful help pages:
-- startup CTRL-W current-directory :verbose
-- :mksession [:]terminal history
-- quickfix quickfix-window :copen :cwindow getqflist() setqflist()
-- location-list location-list-window :lopen :lwindow getloclist() setloclist()
-- 'switchbuf' setreg search-offset
-- folding fold-methods fold-commands fold-marker
-- tags preview-window buffer-hidden
-- [:]registers mark-motions jump-motions restore-position restore-cursor
-- 'tabline' setting-tabline
-- :lockmarks :keepmarks :keepjumps
-- option-window :browse
-- keybind operator 'shortmess'
-- vim-modes keycodes global-local local-noglobal
-- cmdline-completion cmdline-editing normal-index insert-index
-- cmdline-window q:
-- ins-special-keys ins-special-special
-- i_CTRL-X_index
-- 'backspace' [:]digraphs Ctrl-K
-- 'wildmode' include-search
-- 'wrap' `= wildcards write-quit
-- list-repeat user-commands
-- :redirection
-- write-quit write-device
-- editing.txt
-- :browse options eol-and-eof

--vim.opt.statusline = "%<%F %h%w%y%m%r%=EOL:%{&ff} | TAB:%{&et?'spaces':'tabs'} | TW:%{&ts} | %-14.(%l,%c%V%) %P"
-- Use Treesitter folding.

--vim.opt.foldmethod = "expr"
-- :help v:lua
--foldexpr=v:lua.vim.treesitter.foldexpr()
