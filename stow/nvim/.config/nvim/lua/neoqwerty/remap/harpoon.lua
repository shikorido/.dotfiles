local M, L = {}, {}

M.keys = {
  { "<C-s>", function() M.harpoon.ui:toggle_quick_menu(M.harpoon:list(), L.toggle_opts) end },
  { "<leader>A", function() M.harpoon:list():prepend() end },
  { "<leader>a", function() M.harpoon:list():add() end },
  { "<leader><C-s>", function() L.toggle_telescope(M.harpoon:list()) end },
  { "<C-h>", function() M.harpoon:list():select(1) end },
  { "<C-j>", function() M.harpoon:list():select(2) end },
  { "<C-k>", function() M.harpoon:list():select(3) end },
  { "<C-l>", function() M.harpoon:list():select(4) end },
  { "<leader><C-h>", function() M.harpoon:list():replace_at(1) end },
  { "<leader><C-j>", function() M.harpoon:list():replace_at(2) end },
  { "<leader><C-k>", function() M.harpoon:list():replace_at(3) end },
  { "<leader><C-l>", function() M.harpoon:list():replace_at(4) end },
  { "<C-[>", function() M.harpoon:list():prev(L.nav_opts) end },
  { "<C-]>", function() M.harpoon:list():next(L.nav_opts) end },

  -- Global lists for key-independent files (use separate harpoon instance).
  -- TODO: Figure out how to maintain key for each CWD and in the same time
  --       have "<global>" key or smth. Many things in harpoon are tied to cwd.
  --       Therefore, it can be tough to achieve without invasive modifications.
  -- TODO2: Implement global list with marks, i.e. add new entry if the context (row, col)
  --        is different from existing ones. Also on select always jump to the context
  --        whenever buffer exists. Life saver for help files, I think.
  -- TODO3: Figure out why help files opened from Harpoon are not configured
  --        well (conceallevel, concealcursor, buftype, etc.).
  --{ "<leader>G", function() M.harpoon:list("global"):prepend() end) },
  --{ "<leader>g", function() M.harpoon:list("global"):add() end) },
  --{ "<C-g>", function() M.harpoon.ui:toggle_quick_menu(M.harpoon:list("global"), L.toggle_opts) end },
}

function M.uiCreateKeymaps(cx)
  vim.keymap.set("n", "<C-x>", function() L.ui_split() end, { buffer = cx.bufnr })
  vim.keymap.set("n", "<C-v>", function() L.ui_vsplit() end, { buffer = cx.bufnr })
  vim.keymap.set("n", "<C-t>", function() L.ui_tabedit() end, { buffer = cx.bufnr })
end

L.ui_split = function() M.harpoon.ui:select_menu_item({ split = true }) end
L.ui_vsplit = function() M.harpoon.ui:select_menu_item({ vsplit = true }) end
L.ui_tabedit = function() M.harpoon.ui:select_menu_item({ tabedit = true }) end

L.toggle_opts = {
  ui_fallback_width = 69,
  ui_width_ratio = 0.62569,
  height_in_lines = 12,
  ui_max_width = 100,
}

L.nav_opts = {
  ui_nav_wrap = false,
}

function L.toggle_telescope(harpoon_files)
  local conf = require("telescope.config").values
  local file_paths = {}
  for _, item in ipairs(harpoon_files.items) do
    file_paths[#file_paths + 1] = item.value
  end
  require("telescope.pickers")
    .new({}, {
      prompt_title = "Harpoon",
      finder = require("telescope.finders").new_table({
        results = file_paths,
      }),
      previewer = conf.file_previewer({}),
      sorter = conf.generic_sorter({}),
    })
    :find()
end

return M
