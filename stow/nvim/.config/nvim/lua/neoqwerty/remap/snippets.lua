local M = {}

M.keys = {
  { "<C-s>e", function() M.luasnip.expand() end, mode = "i", silent = true },
  { "<C-s>;", function() M.luasnip.jump(1) end, mode = { "i", "s" }, silent = true },
  { "<C-s>,", function() M.luasnip.jump(-1) end, mode = { "i", "s" }, silent = true },
  {
    "<C-e>",
    function()
      if M.luasnip.choice_active() then
        M.luasnip.change_choice(1)
      end
    end,
    mode = { "i", "s" },
    silent = true,
  },
}

return M
