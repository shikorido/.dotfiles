local M = {}

M.keys = {
  { "<leader>trt", function() M.trouble.toggle() end },
  { "[t", function() M.trouble.next({ skip_groups = true, jump = true }) end },
  { "]t", function() M.trouble.previous({ skip_groups = true, jump = true }) end },
}

return M
