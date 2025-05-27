local icons_enabled = CFG_REQ("vars").icons_enabled

return {
  "nvim-lualine/lualine.nvim",
  dependencies = {
    "gitsigns.nvim",
    --"nvim-web-devicons",
  },

  config = function()
    local icons = {
      branch = "",
      fileformats = { dos = "", mac = "", unix = "" },
    }
    local separators
    if icons_enabled then
      separators = {
        component = { left = "", right = "" },
        --component = { left = "", right = "" },
        section = { left = "", right = "" },
      }
      setmetatable(icons, {
        __index = function(t, k)
          if rawget(t) == nil then
            error(debug.traceback("No icon for " .. k))
          end
        end,
      })
    else
      separators = {
        component = { left = "|", right = "|" },
        section = { left = "", right = "" },
      }
      setmetatable(icons, {
        __newindex = function(t, k, v) error(debug.traceback("Icons are disabled")) end,
      })
    end

    local function shorten_component(comp)
      -- Preserve leading non-alphanumeric characters.
      local prefix, rest = comp:match("^([^%w]*)(.*)$")

      -- Find first alphanumeric character in remainder.
      local first = rest:match("(%w)")

      if not first then
        -- No alphanumeric content at all -> return as-is.
        return comp
      end

      return prefix .. first
    end

    local function pathshorten_custom(path)
      local is_win_path = path:find("^%a:[/\\]")
      if not path or (not is_win_path and not path:find("^/")) then
        return path
      end
      local sep = is_win_path and "\\" or "/"

      local parts = {}
      for part in path:gmatch("[^/\\]+") do
        table.insert(parts, part)
      end

      -- Shorten all but the last component.
      local start = is_win_path and 2 or 1
      for i = start, #parts - 1 do
        parts[i] = shorten_component(parts[i])
      end

      local result = table.concat(parts, sep)

      -- Preserve leading slash.
      if path:sub(1, 1) == "/" then
        result = "/" .. result
      elseif path:find("^[a-z]:\\?") then
        result = path:sub(1, 1):upper() .. result(2)
      end

      return result
    end

    --vim.opt.statusline = "%<%F %y%h%w%m%r%=EOL:%{&ff} | TAB:%{&et?'spaces':'tabs'} | TS:%{&ts} STS:%{&sts} SW:%{&sw} | %-14.(%l,%c%V%) %P"

    local function buf_info()
      local ft  = vim.bo.filetype ~= "" and "["..vim.bo.filetype.."]" or ""
      local hlp = vim.bo.buftype == "help" and vim.bo.filetype ~= "help" and "[help]" or ""
      local pvw = vim.wo.previewwindow and "[Preview]" or ""
      local mod = not vim.bo.modifiable and "[-]" or vim.bo.modified and "[+]" or ""
      local ro  = vim.bo.readonly and "[RO]" or ""
      return ft..hlp..pvw..mod..ro
    end

    local function eol_type()
      local ff = vim.bo.fileformat
      local icon = icons.fileformats[ff]
      return ff .. (icon and #icon ~= 0 and " " .. icon or "")
    end

    local function indent_type()
      return vim.bo.expandtab and "spaces" or "tabs"
    end

    local function indent_info()
      local softtabstop = vim.bo.softtabstop
      if softtabstop == 0 then
        softtabstop = "TS"
      elseif softtabstop < 0 then
        softtabstop = "SW"
      end
      local shiftwidth = vim.bo.shiftwidth
      if shiftwidth == 0 then
        shiftwidth = "TS"
      end
      return "TS:"..vim.bo.tabstop.." STS:"..softtabstop.." SW:"..shiftwidth
    end

    --local function trunc_or_pad_right(s, width)
    --  if #s > width then
    --    return s:sub(1, width)
    --  end
    --  return s .. string.rep(" ", width - #s)
    --end

    --local function trunc_or_pad_left(s, width)
    --	if #s > width then
    --		return s:sub(-width)
    --	end
    --	return string.rep(" ", width - #s) .. s
    --end

    --local function cursor_pos()
    --  return "%-14.(%l,%c%V%)"
    --  --local line = vim.fn.line(".")
    --  --local col = vim.fn.col(".")
    --  --local vcol = vim.fn.virtcol(".")
    --  --if col == vcol then
    --  --  return trunc_or_pad_right(string.format("%d,%d", line, col), 14)
    --  --else
    --  --  return trunc_or_pad_right(string.format("%d,%d-%d", line, col, vcol), 14)
    --  --end
    --end

    --local utils = require("lualine.utils.utils")
    --local function vim_progress()
    --  return "%P"
    --  --local s = vim.api.nvim_eval_statusline("%P", { maxwidth = 0 }).str
    --  --return utils.stl_escape(s)
    --end


    -- lualine.nvim/wiki/Component-snippets

    ---@param trunc_width number trunctates component when screen width is less then trunc_width
    ---@param trunc_len number truncates component to trunc_len number of chars
    ---@param hide_width number hides component when window width is smaller then hide_width
    ---@param no_ellipsis boolean whether to disable adding '...' at end after truncation
    ---return function that can format the component accordingly
    local function trunc(trunc_width, trunc_len, hide_width, no_ellipsis)
      return function(str)
        local win_width = vm.fn.winwidth(0)
        if hide_width and win_width < hide_width then return ""
        elseif trunc_width and trunc_len and win_width < trunc_width and #str > trunc_len then
          return str:sub(1, trunc_len) .. (no_ellipsis and "" or "...")
        end
        return str
      end
    end
    local function mixed_indent()
      -- Help pages use mixed indent a lot.
      if vim.bo.bt == "help" then return "" end
      local space_pat = [[\v^ +]]
      local tab_pat = [[\v^\t+]]
      local space_indent = vim.fn.search(space_pat, "nwc")
      local tab_indent = vim.fn.search(tab_pat, "nwc")
      if not (space_indent > 0 and tab_indent > 0) then
        local mixed_same_line = vim.fn.search([[\v^(\t+ | +\t)]], "nwc")
        if not (mixed_same_line > 0) then return "" end
        return "MI:"..mixed_same_line
      end
      local space_indent_cnt = vim.fn.searchcount({pattern=space_pat, max_count=1e3}).total
      local tab_indent_cnt = vim.fn.searchcount({pattern=tab_pat, max_count=1e3}).total
      if space_indent_cnt > tab_indent_cnt then
        return "MI:"..tab_indent
      end
      return "MI:"..space_indent
    end
    local function window() return vim.api.nvim_win_get_number(0) end
    local function diff_source()
      local gitsigns = vim.b.gitsigns_status_dict
      if gitsigns then
        return {
          added = gitsigns.added,
          modified = gitsigns.changed,
          removed = gitsigns.removed,
        }
      end
    end


    require("lualine").setup {
      extensions = {
        "fugitive",
        "lazy",
        "neo-tree",
        "nvim-dap-ui",
        "trouble",
      },

      options = {
        icons_enabled = icons_enabled,
        theme = "auto",
        component_separators = separators.component,
        section_separators = separators.section,
        disable_filetypes = {
          statusline = {},
          winbar = {},
        },
        ignore_focus = {},
        always_divide_middle = true,
        --always_show_tabline = true,
        --globalstatus = true,
        refresh = {
          statusline = 100,
          tabline = 100,
          winbar = 100,
          refresh_time = 1000 / 30,
          events = {
            "WinEnter",
            "BufEnter",
            "BufWritePost",
            "SessionLoadPost",
            "FileChangedShellPost",
            "VimResized",
            "Filetype",
            "CursorMoved",
            "CursorMovedI",
            "ModeChanged",
          },
        },
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = {
          { "b:gitsigns_head", icon = icons.branch },
          { "diff", source = diff_source },
          "diagnostics",
          "lsp_status",
        },
        lualine_c = {
          {
            "filename",
            newfile_status = true,
            path = 3,
          },
          mixed_indent,
        },
        lualine_x = {
          "encoding",
          "fileformat",
          "filetype",
        },
        lualine_y = {
        },
        lualine_z = {
          "location",
          "progress",
        },
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = {
          {
            "filename",
            newfile_status = true,
            path = 3,
          },
        },
        lualine_x = { "location" },
        lualine_y = {},
        lualine_z = {},
      },
      tabline = {},
      winbar = {},
    }
  end,
}
