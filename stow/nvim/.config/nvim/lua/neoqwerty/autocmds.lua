local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

local NeoqwertyGroup = augroup("Neoqwerty", {})
local YankGroup = augroup("HighlightYank", {})

autocmd("FileType", {
  group = NeoqwertyGroup,
  callback = function(args)
    local ft = vim.bo[args.buf].filetype

    local desired
    if ft == "zig" then
      desired = "tokyonight-night"
    else
      desired = "rose-pine-moon"
    end

    if desired ~= CURRENT_SCHEME then
      CURRENT_SCHEME = desired
      -- Both succeed.
      vim.schedule(function()
        vim.cmd.colorscheme(desired)
        --ColorMyPencils(desired)
      end)
      --vim.defer_fn(function()
      --  vim.cmd.colorscheme(desired)
      --end, 0)
      -- Breaks lualine highlighting in autocmds phase,
      -- must be deferred until next event-loop tick.
      --vim.cmd.colorscheme("rose-pine-moon")
    end
  end
})

autocmd("FileType", {
  group = NeoqwertyGroup,
  pattern = { "dosbatch", "ps1" },
  callback = function()
    vim.bo.fileformat = "dos"
  end
})

autocmd("BufNewFile", {
  group = NeoqwertyGroup,
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


autocmd("TextYankPost", {
  group = YankGroup,
  pattern = "*",
  callback = function()
    vim.highlight.on_yank({
      higroup = "IncSearch",
      timeout = 40
    })
  end
})

-- Looks like trimming from .editorconfig runs later,
-- so we can save cursor in undo history here.
autocmd("BufWritePre", {
  group = NeoqwertyGroup,
  pattern = "*",
  callback = function(event)
    local bufnr = event.buf
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
  end
})

autocmd("LspAttach", {
  group = NeoqwertyGroup,
  callback = function(e)
    local opts = { buffer = e.buf }
    vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
    vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
    vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)
    vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts)
    vim.keymap.set("n", "<leader>vca", function() vim.lsp.buf.code_action() end, opts)
    vim.keymap.set("n", "<leader>vrr", function() vim.lsp.buf.references() end, opts)
    vim.keymap.set("n", "<leader>vrn", function() vim.lsp.buf.rename() end, opts)
    vim.keymap.set("i", "<C-q>", function() vim.lsp.buf.signature_help() end, opts)
    vim.keymap.set("n", "[d", function() vim.diagnostic.goto_next() end, opts)
    vim.keymap.set("n", "]d", function() vim.diagnostic.goto_prev() end, opts)
  end
})

-- For Windows, happens very often.
-- https://github.com/neovim/neovim/issues/8587
if CFG_REQ("vars").is_win then
  autocmd("VimLeavePre", {
    group = NeoqwertyGroup,
    pattern = "*",
    callback = function()
      local status = 0
      for _, f in ipairs(vim.fn.globpath(vim.fn.stdpath("state") .. "/shada", "main.shada.tmp.?", false, true)) do
        if #vim.fn.readfile(f, "", 1) == 0 then
          status = status + vim.fn.delete(f)
        end
      end
      if status ~= 0 then
        vim.notify("Could not delete empty temp ShaDa files!", vim.log.levels.ERROR)
        vim.fn.getchar()
      end
    end,
    desc = "Delete empty temp ShaDa files"
  })
end
