local M = {}

M.ftDefaultOpts = {
  colorcolumn = "100",
  colorscheme = "rose-pine-moon",
}

M.ftOpts = {
  c = {
    colorcolumn = "80",
    --colorscheme = "tokyonight-night",
  },
}
M.ftOpts.cpp = M.ftOpts.c
for k, v in pairs(M.ftOpts) do
  if not getmetatable(v) then
    setmetatable(v, {
      __index = function(t, k)
        local v = rawget(t, k)
        if v == nil then
          return M.ftDefaultOpts[k]
        end
        return v
      end
    })
  end
end
setmetatable(M.ftOpts, {
  __index = function(t, k)
    local v = rawget(t, k)
    if v == nil then
      return M.ftDefaultOpts
    end
    return v
  end
})

M.is_win = vim.fn.has("win32") == 1
--vim.uv.os_uname().version:find("Windows") ~= nil

-- To be able to use vim's dumb vim.fn.system and vim.fn.systemlist
-- from MSYS2, shell must already be setted up
-- However, we still can use vim.system (nvim's wrapper over libuv spawn).
-- Otherwise, we might look at MSYSTEM variable, but it matches
-- against one of MINGW*|CLANG*|UCRT* for native tools, otherwise
-- defaults to MSYS with match-all, not strict. In this sense,
-- looking at MSYSTEM solely might not be enough if it's empty,
-- but looking at MSYSTEM_PREFIX might be.
M.is_msys2 = (function()
  local obj = vim.system({ "uname" }, { text = true }):wait()
  if obj.code == 0 then
    local stdout = obj.stdout
    if stdout:find("MINGW64_NT") or stdout:find("MINGW32_NT") or stdout:find("MSYS_NT") then
      return true
    end
  end
  return false
end)()

M.msys2_root = M.is_msys2
    and (function()
      local root, obj
      if vim.fn.executable("cygpath") == 1 then
        obj = vim.system({ "cygpath", "-m", "/" }, { text = true }):wait()
        if obj.code == 0 then
          root = obj.stdout:sub(1, -3) --drop /\n at the end
        end
      end
      if not root then
        root = vim.fn.expand("~"):match("^.*msys64")
      end
      if not root then
        root = "C:/msys64"
      end
      if not vim.uv.fs_stat(root .. "/usr/bin/cygpath.exe") then
        vim.notify("MSYS2 root not found or does not exist: " .. root, vim.log.levels.ERROR)
        M.is_msys2 = false
        return nil
      end
      return root
    end)()
  or nil

M.home = os.getenv("HOME")
if not M.home and M.is_win then
  M.home = os.getenv("USERPROFILE")
end
if not M.home then
  M.home = vim.expand("~")
  vim.notify("Unable to locate home! Defaulting to vim.expand('~'):\n" .. M.home)
end

M.icons_enabled = (function()
  if os.getenv("NVIM_NO_ICONS") then
    return false
  end
  return true
  -- Termux:Styling supports NerdFonts.
  -- TERMUX_VERSION SSH_CONNECTION TERM_PROGRAM
end)()

return M
