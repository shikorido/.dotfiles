local M = {}

M.keys = {
  { '<leader>qs', function() M.quickselect.quick_select() end },
  { '<leader>qy', function() M.quickselect.quick_yank() end },
}

return M
