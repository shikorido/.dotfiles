local M = {}

M.is_win = vim.uv.os_uname().version:find("Windows") and true or false

-- To be aple to use vim's dumb vim.fn.system and vim.fn.systemlist
-- from msys2, we must already have shell setted up.
-- However, we still can use vim.system (nvim's wrapper over libuv spawn).
M.is_msys2 = (function()
  local obj = vim.system( { "uname" }, { text = true }):wait()
  if obj.code == 0 then
    local stdout = obj.stdout
    if stdout:find("MINGW64_NT") or
       stdout:find("MINGW32_NT") or
       stdout:find("MSYS_NT") then
       return true
    end
  end
  return false
end)()

M.msys2_root = M.is_msys2 and (function()
  local root = vim.fn.expand("~"):gsub("/", "\\"):match("^.*msys64")
  if not root then
    root = "C:\\msys64"
  end
  return root
end)() or nil

M.home = os.getenv("HOME")
if not M.home and M.is_win then
  M.home = os.getenv("USERPROFILE")
end

if M.is_msys2 then
  local bash = M.msys2_root.."\\usr\\bin\\bash.exe"
  if vim.fn.executable(bash) then
    vim.opt.shell = bash
    vim.opt.shellcmdflag = "-c"
    vim.opt.shellquote = ""
    vim.opt.shellxquote = ""
    -- Changes backslashes slashes to forward slashes in shell invocations.
    vim.opt.shellslash = true
  end
end

M.icons_enabled = (function()
  if os.getenv("NVIM_DISABLE_ICONS") then
    return false
  end
  return true
  -- Termux:Styling supports NerdFonts.
  --return false or vim.env.TERMUX_VERSION
  --  and not vim.env.SSH_CONNECTION
  --  and not vim.env.TERM_PROGRAM
end)()

return M
