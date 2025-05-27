local M = {}

M.fileType = function(ev)
  local opts = { buffer = ev.buf }
  vim.keymap.set("n", "<leader>ee", "oif err != nil {<CR>}<Esc>Oreturn err<Esc>", opts)
  vim.keymap.set("n", "<leader>ea", 'oassert.NoError(err, "")<Esc>F";a', opts)
  vim.keymap.set(
    "n",
    "<leader>ef",
    'oif err != nil {<CR>}<Esc>Olog.Fatalf("error: %s\\n", err.Error())<Esc>jj',
    opts
  )
  vim.keymap.set(
    "n",
    "<leader>el",
    'oif err != nil {<CR>}<Esc>O.logger.Error("error", "error", err)<Esc>F.;i',
    opts
  )
  -- Spaces after keymap to unmap are error prone (:help map-trailing-white).
  -- <buffer> is a map argument (:help map-arguments).
  vim.b[ev.buf].undo_ftplugin = (vim.b[ev.buf].undo_ftplugin .. "|" or "")
    .. "nunmap <buffer> <leader>ee| "
    .. "nunmap <buffer> <leader>ea| "
    .. "nunmap <buffer> <leader>ef| "
    .. "nunmap <buffer> <leader>el"
end

return M
