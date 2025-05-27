local Path = require("plenary.path")
local remap = CFG_REQ("remap")

return {
  "shikorido/harpoon", -- ThePrimeagen/harpoon
  branch = "harpoon2",
  lazy = false,
  keys = remap.harpoon.keys,
  opts = {
    settings = {
      save_on_toggle = false,
      sync_on_ui_close = true,
      -- Key for lists lookup. One key => multiple named lists.
      -- Default list name is "__harpoon_files".
      --key = function()
      --  return vim.uv.cwd()
      --end
      -- No more HARPOON_LISTS_DICT->UV_CWD_KEY->LISTS_DICT->__harpoon_files (default).
      -- It will be only HARPOON_LISTS_DICT->GLOBAL_KEY->LISTS_DICT->UV_CWD_KEY (new default if conditions met).
      -- To make it work, Config.DEFAULT_LIST must be changed to vim.uv.cwd()
      -- if no list name provided, key returns "<global>" and new_default_list_behavior is true.
      key = function() return "<global>" end,
      new_default_list_behavior = true,
    },
    global = {
      create_list_item = function(config)
        local bufnr = vim.api.nvim_get_current_buf()
        local name = Path:new(vim.api.nvim_buf_get_name(0)):absolute()
        local pos = { 1, 0 }
        local opts = {}
        if bufnr ~= -1 then
          pos = vim.api.nvim_win_get_cursor(0)
          local buftype = vim.fn.getbufvar(bufnr, "&bt")
          if buftype ~= "" then
            opts.buftype = buftype
          end
        end
        return {
          value = name,
          context = {
            row = pos[1],
            col = pos[2],
            opts = opts,
          },
        }
      end,
    },
  },
  config = function(_, opts)
    local harpoon = require("harpoon")
    local harpoon_extensions = require("harpoon.extensions")
    harpoon:setup(opts)
    remap.harpoon.harpoon = harpoon
    harpoon:extend(harpoon_extensions.builtins.highlight_current_file())
    harpoon:extend({
      UI_CREATE = function(cx)
        remap.harpoon.uiCreateKeymaps(cx)
        vim.wo[cx.win_id].rnu = true
      end,
    })
  end,
}
