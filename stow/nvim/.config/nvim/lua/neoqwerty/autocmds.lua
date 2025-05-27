local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd
local remap = CFG_REQ("remap")
local vars = CFG_REQ("vars")

local NeoqwertyGroup = augroup("Neoqwerty", {})
local FugitiveGroup = augroup("NeoqwertyFugitive", {})
local YankGroup = augroup("HighlightYank", {})

-- Looks like trimming from .editorconfig runs later,
-- so cursor position can be saved in undo history here.
autocmd("BufWritePre", {
  group = NeoqwertyGroup,
  callback = function(ev)
    local bufnr = ev.buf
    if not vim.bo[bufnr].modifiable then return end

    local original_lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    local new_lines, modified

    for i = 1, #original_lines do
      local trimmed = original_lines[i]:gsub("%s+$", "")
      if trimmed ~= original_lines[i] then
        if not new_lines then
          new_lines = vim.deepcopy(original_lines)
          modified = true
        end
        new_lines[i] = trimmed
      end
    end

    if modified then
      CFG_REQ("format").update_lines_preserve_cursor(bufnr, original_lines, new_lines)
    end
  end,
})

autocmd("BufWinEnter", {
  group = FugitiveGroup,
  callback = remap.fugitive.bufWinEnter,
})

autocmd({ "BufEnter", "FileType" }, {
  group = NeoqwertyGroup,
  callback = function(ev)
    local ft = vim.bo[ev.buf].filetype
    if ft == "markdown" then
      local winid = vim.fn.bufwinid(ev.buf)
      if winid ~= -1 and vim.api.nvim_win_get_config(winid).relative ~= "" then
        return
      end
    end
    ColorMyPencils(vars.ftOpts[ft].colorscheme)
    vim.wo.colorcolumn = vars.ftOpts[ft].colorcolumn
  end,
})

autocmd("FileType", {
  group = NeoqwertyGroup,
  pattern = "markdown",
  callback = function(ev)
    local winid = vim.fn.bufwinid(ev.buf)
    if winid ~= -1 and vim.api.nvim_win_get_config(winid).relative ~= "" then
      vim.wo[winid].winhighlight = "NormalFloat:LspFloat"
    end
  end,
})

autocmd("FileType", {
  group = NeoqwertyGroup,
  pattern = "rust",
  callback = remap.rust.fileType,
})

autocmd("FileType", {
  group = NeoqwertyGroup,
  pattern = { "dosbatch", "ps1" },
  callback = function(ev)
    vim.bo[ev.buf].fileformat = "dos"
  end,
})

autocmd("LspAttach", {
  group = NeoqwertyGroup,
  callback = remap.lsp.lspAttach,
})

autocmd("VimEnter", {
  group = NeoqwertyGroup,
  callback = function(ev)
    if not vars.colorscheme then
      ColorMyPencils()
    end
  end,
  once = true,
})

autocmd("TextYankPost", {
  group = YankGroup,
  callback = function()
    vim.highlight.on_yank({
      higroup = "IncSearch",
      timeout = 40,
    })
  end,
})

-- For Windows, happens very often.
-- https://github.com/neovim/neovim/issues/8587
if vars.is_win then
  autocmd("VimLeavePre", {
    group = NeoqwertyGroup,
    callback = function()
      local status = 0
      for _, f in
        ipairs(
          vim.fn.globpath(vim.fn.stdpath("state") .. "/shada", "main.shada.tmp.?", false, true)
        )
      do
        if #vim.fn.readfile(f, "", 1) == 0 then
          status = status + vim.fn.delete(f)
        end
      end
      if status ~= 0 then
        vim.notify("Could not delete empty temp ShaDa files!", vim.log.levels.ERROR)
        vim.fn.getchar()
      end
    end,
    desc = "Delete empty temp ShaDa files",
  })
end
