_G.ColorMyPencils = function(color)
  color = color or "rose-pine-moon"

  -- Works but not well enough, Lazy is transparent
  -- without vim.cmd.colorscheme call.
  --if CURRENT_SCHEME ~= color then
  --  CURRENT_SCHEME = color
  --  vim.cmd.colorscheme(color)
  --end

  vim.cmd.colorscheme(color)

  vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
  vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
  -- Temporary.
  --vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" })
end

return {
  {
    "erikbackman/brightburn.vim",
    priority = 1000,
  },

  {
    "ellisonleao/gruvbox.nvim",
    priority = 1000,
    opts = {
      terminal_colors = true, -- add neovim terminal colors
      undercurl = true,
      underline = false,
      bold = true,
      italic = {
        strings = false,
        emphasis = false,
        comments = false,
        operators = false,
        folds = false
      },
      strikethrough = true,
      invert_selection = false,
      invert_signs = false,
      invert_tabline = false,
      invert_intend_guides = false,
      inverse = true, -- invert background for search, diffs, statuslines and errors
      contrast = "",  -- can be "hard", "soft" or empty string
      palette_overrides = {},
      overrides = {},
      dim_inactive = false,
      transparent_mode = false,
    },
  },

  {
    "folke/tokyonight.nvim",
    priority = 1000,
    opts = {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      style = "storm",        -- The theme comes in four styles, `storm`, `moon`, a darker variant `night` and `day`
      transparent = true,     -- Enable this to disable setting the background color
      terminal_colors = true, -- Configure the colors used when openning a `:terminal` in Neovim
      styles = {
        -- Style to be applied to different syntax groups
        -- Value is any valid attr-list value for `:help nvim_set_hl`
        comments = { italic = false },
        keywords = { italic = false },
        -- Background styles. Can be "dark", "transparent" or "normal"
        sidebars = "dark", -- style for sidebars, see below
        floats = "dark",   -- style for floating windows
      },
    },
    config = function(_, opts)
      require("tokyonight").setup(opts)
      ColorMyPencils()
    end,
  },

  {
    "rose-pine/neovim",
    name = "rose-pine",
    priority = 1000,
    opts = {
      disable_background = true,
      styles = {
        italic = false
      },
    },
    config = function(_, opts)
      require("rose-pine").setup(opts)
      ColorMyPencils()
    end,
  },
}
