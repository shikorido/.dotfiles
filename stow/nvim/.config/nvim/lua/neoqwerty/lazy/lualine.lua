local icons_enabled = CFG_REQ("vars").icons_enabled

return {
  "nvim-lualine/lualine.nvim",
  dependencies = {
    "gitsigns.nvim"
    --"nvim-web-devicons"
  },

  config = function()
    local icons = {
      branch = "",
    }
    local separators = {
      component = { left = "|", right = "|" }
    }
    if icons_enabled then
      icons.fileformats = { dos = "", mac = "", unix = "" }
      --separators.component = { left = "", right = "" }
      separators.section = { left = "", right = "" }
    else
      icons.fileformats = { dos = "", mac = "", unix = "" }
      separators.section = { left = "|", right = "|" }
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
      if not path or not path:find("/") then
        return path
      end

      local parts = {}
      for part in path:gmatch("[^/]+") do
        table.insert(parts, part)
      end

      -- Shorten all but the last component.
      for i = 1, #parts - 1 do
        parts[i] = shorten_component(parts[i])
      end

      local result = table.concat(parts, "/")

      -- Preserve leading slash.
      if path:sub(1, 1) == "/" then
        result = "/" .. result
      elseif path:find("^[A-Za-z]:/?") then
        result = path:sub(1, 2) .. result:sub(2):gsub("/", "\\")
      end

      return result
    end

    --vim.opt.statusline = "%<%F %y%h%w%m%r%=EOL:%{&ff} | TAB:%{&et?'spaces':'tabs'} | TS:%{&ts} STS:%{&sts} SW:%{&sw} | %-14.(%l,%c%V%) %P"

    local function buf_info()
      local ft  = vim.bo.filetype ~= "" and "["..vim.bo.filetype.."]" or ""
      local hf  = vim.bo.buftype == "help" and vim.bo.filetype ~= "help" and "[help]" or ""
      local pwf = vim.wo.previewwindow and "[Preview]" or ""
      local mf  = not vim.bo.modifiable and "[-]" or vim.bo.modified and "[+]" or "[-]"
      local rof = vim.bo.readonly and "[RO]" or ""
      return ft..hf..pwf..mf..rof
    end

    local function git_branch_or_commit()
      -- Broken until I make Fugitive to work with worktrees.
      --if vim.fn.exists("*FugitiveHead") == 1 then
      --  local branch = vim.fn.FugitiveHead()
      --  if branch ~= "" then
      --    return branch
      --  end
      --end

      local head = vim.b.gitsigns_head
      if not head or head == "" then
        return ""
      end

      return head
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
      return "TS:" .. vim.bo.tabstop .. " STS:" .. softtabstop .. " SW:" .. shiftwidth
    end

    local function pad_left_trunc(s, width)
      if #s > width then
        return s:sub(1, width)
      end
      return s .. string.rep(" ", width - #s)
    end

    --local function pad_right_trunc(s, width)
    --	if #s > width then
    --		return s:sub(-width)
    --	end
    --	return string.rep(" ", width - #s) .. s
    --end

    local function cursor_pos()
      local line = vim.fn.line(".")
      local col = vim.fn.col(".")
      local vcol = vim.fn.virtcol(".")
      if col == vcol then
        return pad_left_trunc(string.format("%d,%d", line, col), 14)
      else
        return pad_left_trunc(string.format("%d,%d-%d", line, col, vcol), 14)
      end
    end

    local utils = require("lualine.utils.utils")

    local function vim_progress()
      local s = vim.api.nvim_eval_statusline('%P', { maxwidth = 0 }).str

      return utils.stl_escape(s)
    end

    require("lualine").setup {
      --extensions = {"fugitive"},

      options = {
        icons_enabled = icons_enabled,
        theme = "auto",
        component_separators = separators.component,
        section_separators = separators.section,
        disable_filetypes = {
          statusline = {},
          winbar = {}
        },

        ignore_focus = {},

        always_divide_middle = true,

        always_show_tabline = true,

        globalstatus = true,

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
            "FileType",
            "CursorMoved",
            "CursorMovedI",
            "ModeChanged",
          },
        },
      },

      inactive_sections = {},

      sections = {
        -- LEFT
        lualine_a = { "mode" },

        lualine_b = {
          {
            function()
              local shortpath = pathshorten_custom(vim.fn.expand("%:p"))
              local bufinfo = buf_info()
              return shortpath..(bufinfo ~= "" and " "..bufinfo or "")
            end,
          },
        },

        lualine_c = {
          {
            git_branch_or_commit,
            icon = icons.branch,
          }
        },

        -- RIGHT
        lualine_x = {
          eol_type,
          indent_type,
          indent_info,
        },

        lualine_y = {
          cursor_pos,
        },

        lualine_z = {
          "progress",
          vim_progress,
        },
      },
    }
  end,
}
