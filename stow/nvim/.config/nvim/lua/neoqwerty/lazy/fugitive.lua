-- TODO: Figure out how to make fugitive understand worktrees,
-- because it always shows branch for the main git worktree.
return {
  "tpope/vim-fugitive",
  config = function()
    vim.keymap.set("n", "<leader>gs", vim.cmd.Git)

    local FugitiveGroup = vim.api.nvim_create_augroup("NeoqwertyFugitive", {})

    local autocmd = vim.api.nvim_create_autocmd
    autocmd("BufWinEnter", {
      group = FugitiveGroup,
      pattern = "*",
      callback = function()
        if vim.bo.ft ~= "fugitive" then
          return
        end

        local bufnr = vim.api.nvim_get_current_buf()
        local opts = { buffer = bufnr, remap = false }
        vim.keymap.set("n", "<leader>p", function()
          vim.cmd.Git("push")
        end, opts)

        -- rebase always
        vim.keymap.set("n", "<leader>P", function()
          vim.cmd.Git({ "pull", "--rebase" })
        end, opts)

        -- NOTE: It allows me to easily set the branch I am pushing
        -- and any tracking needed if I did not set the branch up correctly
        vim.keymap.set("n", "<leader>t", ":Git push -u origin ", opts)
      end
    })

    vim.keymap.set("n", "gu", "<cmd>diffget //2<CR>")
    vim.keymap.set("n", "gh", "<cmd>diffget //3<CR>")
  end,
}
