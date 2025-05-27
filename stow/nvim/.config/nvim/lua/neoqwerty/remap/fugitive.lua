local M = {}

vim.keymap.set("n", "<leader>gs", vim.cmd.Git)
vim.keymap.set("n", "gu", "<cmd>diffget //2<CR>")
vim.keymap.set("n", "gh", "<cmd>diffget //3<CR>")

M.bufWinEnter = function(ev)
  if vim.bo[ev.buf].ft ~= "fugitive" then return end
  local opts = { buffer = ev.buf }
  vim.keymap.set("n", "<leader>p", function() vim.cmd.Git("push") end, opts)
  vim.keymap.set("n", "<leader>P", function() vim.cmd.Git({ "pull", "--rebase" }) end, opts)
  -- NOTE: It allows me to easily set the branch I am pushing
  -- and any tracking needed if I did not set the branch up correctly
  vim.keymap.set("n", "<leader>t", ":Git push -u origin ", opts)
end

return M
