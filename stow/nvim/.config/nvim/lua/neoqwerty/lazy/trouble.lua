local remap = CFG_REQ("remap")
return {
  "folke/trouble.nvim",
  keys = remap.trouble.keys,
  opts = { icons = CFG_REQ("vars").icons_enabled },
  config = function(_, opts)
    local trouble = require("trouble")
    trouble.setup(opts)
    remap.trouble.trouble = trouble
  end,
}
