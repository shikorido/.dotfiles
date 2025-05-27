---:help cmdline-special
---:help filename-modifiers

local function parent_module_name()
  -- Path to this file (may be symlinked).
  local source = debug.getinfo(1, "S").source:sub(2) -- remove leading "@"

  -- Resolve symlinks -> real absolute path.
  local realpath = vim.uv.fs_realpath(source) or source

  -- Get parent directory name.
  return vim.fn.fnamemodify(realpath, ":h:t")
end

local base = parent_module_name()
_G.CFG_REQ = function(mod)
  local ok, val = pcall(require, base .. "." .. mod)
  if ok then
    return val
  end
  vim.notify("CFG_REQ: module " .. base .. "." .. mod .. " not found", vim.log.levels.WARN)
  return {}
end
-- We can't know base in vars.lua aforehead.
CFG_REQ("vars").base = base

local function source_modules(list)
  for _, mod in ipairs(list) do
    require(base .. "." .. mod)
  end
end

-- Order matters!
source_modules({
  "set",
  "remap",
  "lazy_init",
  "autocmds",
  "usercmds",
})

_G.R = function(name)
  require("plenary.reload").reload_module(name)
end

vim.filetype.add({
  extension = {
    log = "messages",
    service = "systemd",
    source = "sh",
    templ = "templ"
  }
})

-- DO.not
-- DO NOT INCLUDE THIS
-- If I want to keep doing lsp debugging
--function restart_htmx_lsp()
--    require("lsp-debug-tools").restart({ expected = {}, name = "htmx-lsp", cmd = { "htmx-lsp", "--level", "DEBUG" }, root_dir = vim.loop.cwd() })
--end
-- DO NOT INCLUDE THIS
-- DO.not
