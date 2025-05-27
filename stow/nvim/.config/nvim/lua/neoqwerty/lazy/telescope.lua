local remap = CFG_REQ("remap")
return {
  "nvim-telescope/telescope.nvim",
  lazy = false,
  keys = remap.telescope.keys,
  opts = {},
  config = function(_, opts)
    require("telescope").setup(opts)
    remap.telescope.builtin = require("telescope.builtin")
  end,
}
