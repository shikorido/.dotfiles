return {
  "folke/trouble.nvim",
  opts = { icons = false },
  keys = {
    { "<leader>trt",
      function()
        require("trouble").toggle()
      end
    },
    { "[t",
      function()
        require("trouble").next({ skip_groups = true, jump = true })
      end
    },
    { "]t",
      function()
        require("trouble").previous({ skip_groups = true, jump = true })
      end
    },
  },
}
