-- TODO: Figure out how to make fugitive understand worktrees,
-- because it always shows branch for the main git worktree.
--
-- UPD. As can be seen in issues history,
-- tpope did a great work to support worktrees.
-- Edge cases still exist, refer to issues then.
-- The TODO was written when I used msys' git, btw.
return {
  "tpope/vim-fugitive",
  -- UPD. Read lazy_init.lua for more info.
  --"shikorido/vim-fugitive",
  --dir = CFG_REQ("vars").home .. "/forks/vim-fugitive",
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
