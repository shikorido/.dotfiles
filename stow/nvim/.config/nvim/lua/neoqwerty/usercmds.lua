local usercmd = vim.api.nvim_create_user_command

-- Restart TS
usercmd("TSRestart", function()
  local bufnr = vim.api.nvim_get_current_buf()
  local lang  = vim.treesitter.language.get_lang(vim.bo[bufnr].filetype)

  vim.treesitter.highlighter.active[bufnr] = nil
  vim.treesitter.stop(bufnr)
  vim.treesitter.start(bufnr, lang)

  print("Tree-sitter restarted for buffer " .. bufnr)
end, {})
