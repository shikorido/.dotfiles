local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.uv.fs_stat(lazypath) then
  local obj = vim.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  }):wait()
  assert(obj.code == 0, vim.inspect(obj))
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = CFG_REQ("vars").base .. ".lazy",
  change_detection = { notify = false },
})
