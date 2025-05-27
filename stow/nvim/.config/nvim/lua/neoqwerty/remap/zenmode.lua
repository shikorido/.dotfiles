local M = {}

M.keys = {
  {
    "<leader>zz",
    function()
      require("zen-mode").toggle({ window = { width = 90 } })
      vim.cmd.setl("nowrap nu rnu")
    end,
  },
  {
    "<leader>zZ",
    function()
      require("zen-mode").toggle({ window = { width = 80 } })
      vim.cmd.setl("nowrap nonu nornu cc=0")
    end,
  },
}

return M
