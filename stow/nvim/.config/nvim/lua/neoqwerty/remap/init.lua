local M = setmetatable({}, {
  __index = function(t, k)
    local v = rawget(t, k)
    if v == nil then
      v = CFG_REQ("remap." .. k)
      rawset(t, k, v)
    end
    return v
  end
})

vim.g.mapleader = " "
vim.g.maplocalleader = "\\" -- at least for Lazy.nvim UI default bindings

local _ = M.vanilla

vim.keymap.set({ "n", "x" }, "<leader>g=", CFG_REQ("format").format_conform)
--[[m":silent lockmarks keepjumps keeppatterns normal! gg=G`"<CR>]]

if not CFG_REQ("vars").is_win then
  vim.keymap.set("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>")
end
vim.keymap.set("n", "<leader>mr", "<cmd>CellularAutomaton make_it_rain<CR>")
vim.keymap.set("n", "<leader>u", "<cmd>UndotreeToggle<CR>")

return M
