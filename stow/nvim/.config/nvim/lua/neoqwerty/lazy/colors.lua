local vars = CFG_REQ("vars")

local function colorize(color)
  vim.cmd.colorscheme(color)
  vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
  vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" })
  local lspFloat = vim.api.nvim_get_hl(0, { name = "NormalFloat" })
  vim.api.nvim_set_hl(0, "LspFloat", lspFloat)
  vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
  vars.colorscheme = color
end

local FIRST_COLOR_RUN = true
_G.ColorMyPencils = function(color)
  color = color or vars.ftDefaultOpts.colorscheme
  if color == vars.colorscheme then
    return
  end
  if FIRST_COLOR_RUN then
    colorize(color)
    FIRST_COLOR_RUN = false
  end
  -- vim.cmd.colorscheme breaks lualine hl in autocmds phase,
  -- so must be deferred until next event-loop tick.
  -- vim.schedule and vim.defer_fn succeed.
  -- It's double-edged sword, though.
  -- Defer = lualine hl is good, default tabline blinks a bit.
  -- Instant = goodbye, lualine hl.
  -- Both = lualine A and Z sections are filled
  -- rectangles until deferred call is done.
  vim.schedule(function()
    colorize(color)
  end)
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
        folds = false,
      },
      strikethrough = true,
      invert_selection = false,
      invert_signs = false,
      invert_tabline = false,
      invert_intend_guides = false,
      inverse = true, -- invert background for search, diffs, statuslines and errors
      contrast = "", -- can be "hard", "soft" or empty string
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
      style = "storm", -- The theme comes in four styles, `storm`, `moon`, a darker variant `night` and `day`
      transparent = true, -- Enable this to disable setting the background color
      terminal_colors = true, -- Configure the colors used when openning a `:terminal` in Neovim
      styles = {
        -- Style to be applied to different syntax groups
        -- Value is any valid attr-list value for `:help nvim_set_hl`
        comments = { italic = false },
        keywords = { italic = false },
        -- Background styles. Can be "dark", "transparent" or "normal"
        sidebars = "dark", -- style for sidebars, see below
        floats = "dark", -- style for floating windows
      },
    },
  },

  {
    "rose-pine/neovim",
    name = "rose-pine",
    priority = 1000,
    opts = {
      disable_background = true,
      dim_inactive_windows = false,
      styles = {
        italic = false,
      },
    },
  },
}
