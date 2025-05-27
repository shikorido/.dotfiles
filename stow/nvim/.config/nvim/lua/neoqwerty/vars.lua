local M = {}

--M.is_win = vim.fn.has("win32") == 1
M.is_win = vim.uv.os_uname().version:find("Windows") and true or false

-- To be able to use vim's dumb vim.fn.system and vim.fn.systemlist
-- from msys2, we must already have shell setted up.
-- However, we still can use vim.system (nvim's wrapper over libuv spawn).
M.is_msys2 = (function()
  local obj = vim.system({ "uname" }, { text = true }):wait()
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
-- Temporary for testing.
--M.is_msys2 = false

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
if not M.home then
  M.home = vim.expand("~")
  vim.notify(
    "Unable to locate home directory!\n"..
    "Defaulting to vim.expand('~') value:\n"..
    M.home
  )
end

if M.is_win then
  local pwsh_available = vim.fn.executable("pwsh") == 1
  vim.opt.shell = pwsh_available and "pwsh" or "powershell"
  vim.opt.shellcmdflag =
  "-NoLogo -NonInteractive -ExecutionPolicy RemoteSigned -Command " ..
  "[Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.UTF8Encoding]::new();" ..
  "$PSDefaultParameterValues['Out-File:Encoding']='utf8';" ..
  (pwsh_available and "$PSStyle.OutputRendering='PlainText';" or "")
  -- Just in case `:help shell-pwsh`.
  -- Workaround (may not be needed in future version of pwsh):
  --let $__SuppressAnsiEscapeSequences = 1
  --vim.opt.shellredir = "2>&1 | %%{ \"$_\" } | Out-File %s; exit $LastExitCode"
  vim.opt.shellpipe  = "> %s 2>&1"
  vim.opt.shellquote = ""
  vim.opt.shellxquote = ""
end
--if M.is_msys2 then
--  local bash = M.msys2_root.."\\usr\\bin\\bash.exe"
--  if vim.fn.executable(bash) then
--    vim.opt.shell = bash
--    vim.opt.shellcmdflag = "-c"
--    vim.opt.shellquote = ""
--    vim.opt.shellxquote = ""
--    -- Changes backslashes to forward slashes in shell invocations.
--    vim.opt.shellslash = true
--  end
--end

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
