local M, L = {}, {}

vim.keymap.set("n", "<leader>tsr", vim.cmd.TSRestart)
vim.keymap.set("n", "<leader>lsr", vim.cmd.LspRestart)
vim.keymap.set("n", "<leader>bf", vim.lsp.buf.format)

M.cmpMapping = function(cmp)
  local cmp_select = { behavior = cmp.SelectBehavior.Select }
  return {
    ["<C-p>"] = cmp.mapping.select_prev_item(cmp_select),
    ["<C-n>"] = cmp.mapping.select_next_item(cmp_select),
    ["<C-y>"] = cmp.mapping.confirm({ select = true }),
    ["<C-Space>"] = cmp.mapping.complete(),
  }
end

M.lspAttach = function(ev)
  local opts = { buffer = ev.buf }
  vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
  vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
  vim.keymap.set("n", "L", "K", opts)
  vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)
  vim.keymap.set("n", "<leader>vd", function() L.open_float_LspFloat() end, opts)
  vim.keymap.set("n", "<leader>vca", function() vim.lsp.buf.code_action() end, opts)
  vim.keymap.set("n", "<leader>vrr", function() vim.lsp.buf.references() end, opts)
  vim.keymap.set("n", "<leader>vrn", function() vim.lsp.buf.rename() end, opts)
  vim.keymap.set("i", "<C-q>", function() vim.lsp.buf.signature_help() end, opts)
  vim.keymap.set("n", "[d", function() L.jump_float_LspFloat(-1) end, opts)
  vim.keymap.set("n", "]d", function() L.jump_float_LspFloat(1) end, opts)
end

L.open_float_LspFloat = function()
  local bufnr, winid = vim.diagnostic.open_float()
  if winid then
    vim.wo[winid].winhighlight = "NormalFloat:LspFloat"
  end
end

L.jump_float_LspFloat = function(count)
  local info = vim.diagnostic.jump({ count = count, float = true })
  if not info then return end
  local winid = vim.fn.bufwinid(info.bufnr)
  if winid then
    vim.wo[winid].winhighlight = "NormalFloat:LspFloat"
  end
end

return M
