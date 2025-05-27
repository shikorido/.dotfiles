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
  vim.notify("CFG_REQ: " .. val, vim.log.levels.WARN)
  return {}
end
-- Set base in vars.lua.
CFG_REQ("vars").base = base

local function source_modules(list)
  for _, mod in ipairs(list) do
    CFG_REQ(mod)
  end
end

-- Order matters!
source_modules({
  "set",
  "remap",
  "lazy_init",
  "autocmds",
  "usercmds",
  "dap",
  "lsp",
})

_G.R = function(name)
  require("plenary.reload").reload_module(name)
end

vim.filetype.add({
  extension = {
    c_shipped = "c",
    h_shipped = "cpp",
    log = "messages",
    service = "systemd",
    source = "sh",
    templ = "templ",
  }
})



--function restart_htmx_lsp()
--  require("lsp-debug-tools").restart({ expected = {}, name = "htmx-lsp", cmd = { "htmx-lsp", "--level", "DEBUG" }, root_dir = vim.loop.cwd() })
--end
