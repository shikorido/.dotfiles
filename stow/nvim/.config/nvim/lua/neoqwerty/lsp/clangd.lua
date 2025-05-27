local vars = CFG_REQ("vars")

local function find_all_in_path(name, exts)
  local result = {}
  local sep = vars.is_win and ";" or ":"
  if exts == nil then
    exts = { "" }
    if vars.is_win then
      local pathext = os.getenv("PATHEXT")
        or ".COM;.EXE;.BAT;.CMD;.VBS;.VBE;.JS;.JSE;.WSF;.WSH;.MSC;.PY;.PYW"
      exts = vim.split(pathext, ";", { trimempty = true })
      table.insert(exts, 1, "")
    end
  elseif type(exts) == "string" then
    exts = { exts }
  end
  for _, dir in ipairs(vim.split(os.getenv("PATH") or "", sep, { trimempty = true })) do
    for _, ext in ipairs(exts) do
      local path = vim.fs.joinpath(dir, name .. ext)
      local fs_stat = vim.uv.fs_stat(path)
      if fs_stat and fs_stat.type == "file" then
        result[#result + 1] = vim.uv.fs_realpath(path):gsub("\\", "/")
      end
    end
  end
  return result
end

local clangd_exes = {}

if not vars.is_win then
  local exe = vim.fn.exepath("clangd")
  if exe then
    clangd_exes.gnu = exe
  end
else
  for _, exe in ipairs(find_all_in_path("clangd", ".EXE")) do
    local ok, obj = pcall(function()
      return vim.system({ exe, "--version" }, { text = true }):wait()
    end)
    if ok and obj.code == 0 then
      local clangd_type
      if obj.stdout:find("Platform: .+%-windows%-gnu") then
        clangd_type = "gnu"
      elseif obj.stdout:find("Platform: .+%-windows%-msvc") then
        clangd_type = "msvc"
      end
      if clangd_type then
        if not clangd_exes.gnu and clangd_type == "gnu" then
          clangd_exes.gnu = exe
        elseif not clangd_exes.msvc and clangd_type == "msvc" then
          clangd_exes.msvc = exe
        end
        if clangd_exes.gnu and clangd_exes.msvc then
          break
        end
      end
    end
  end
end

if vars.is_win then
  if not clangd_exes.gnu then
    local clangd_gnu = vars.msys2_root .. "/clang64/bin/clangd.EXE"
    if vim.uv.fs_stat(clangd_gnu) then
      clangd_exes.gnu = clangd_gnu
    end
  end
  if not clangd_exes.msvc then
    local clangd_msvc = os.getenv("PROGRAMFILES"):gsub("\\", "/")
      .. "/Microsoft Visual Studio/2022/Community/VC/Tools/Llvm/x64/bin/clangd.EXE"
    if vim.uv.fs_stat(clangd_msvc) then
      clangd_exes.msvc = clangd_msvc
    end
  end
end

if not clangd_exes.gnu and not clangd_exes.msvc then
  if vars.is_win then
    vim.notify("No clangd found in PATH, MSYS2 root, or MSVS installation", vim.log.levels.WARN)
  else
    vim.notify("No clangd found in PATH", vim.log.levels.WARN)
  end
  return
end

local clangd_default
-- The truth is, almost every project uses MSVC on windows,
-- I personally didn't encounter any mingw yet in projects of my interest.
if vars.is_win then
  if clangd_exes.msvc then
    clangd_default = clangd_exes.msvc
  else
    clangd_default = clangd_exes.gnu
  end
else
  -- Idk whether MSVC cross-compiling LLVM toolchain exists for linux...
  clangd_default = clangd_exes.gnu
end

-- Basic automatic detection.
local function detect_toolchain(root)
    -- CMake-generated build configuration.
    local cache = root .. "/build/CMakeCache.txt"
    local file = io.open(cache, "r")
    if file then
        local content = file:read("*a")
        file:close()
        if content:find("CMAKE_CXX_COMPILER:FILEPATH=.*[Mm][Ss][Vv][Cc]")
          or content:find("CMAKE_CXX_COMPILER_ID:STRING=MSVC") then
          return "msvc"
        end
        if content:find("CMAKE_CXX_COMPILER_ID:STRING=GNU") then return "gnu" end
    end
end

local function get_toolchain(root)
  if not root then return end
  local marker = root .. "/.clangd-toolchain"
  local file = io.open(marker, "r")
  if not file then
    if not vars.is_win then return "gnu" end
    vim.notify("Prompt user to add .clangd-toolchain marker at project root with gnu or msvc")
  end
  if file then
    local value = file:read("*l")
    file:close()
    if clangd_exes[value] then
      return value
    else
      error(marker .. ": Invalid value")
    end
  end
  -- Automatic project detection heuristic.
  local tc = detect_toolchain(root)
  if tc then return tc end
end

local function clangd_select(root)
  local tc = get_toolchain(root)
  return clangd_exes[tc] or clangd_default
end

-- https://clangd.llvm.org/extensions.html#switch-between-sourceheader
local function switch_source_header(bufnr, client)
  local method_name = "textDocument/switchSourceHeader"
  ---@diagnostic disable-next-line:param-type-mismatch
  if not client or not client:supports_method(method_name) then
    return vim.notify(("method %s is not supported by any servers active on the current buffer"):format(method_name))
  end
  local params = vim.lsp.util.make_text_document_params(bufnr)
  ---@diagnostic disable-next-line:param-type-mismatch
  client:request(method_name, params, function(err, result)
    if err then
      error(tostring(err))
    end
    if not result then
      vim.notify("corresponding file cannot be determined")
      return
    end
    vim.cmd.edit(vim.uri_to_fname(result))
  end, bufnr)
end

local function symbol_info(bufnr, client)
  local method_name = "textDocument/symbolInfo"
  ---@diagnostic disable-next-line:param-type-mismatch
  if not client or not client:supports_method(method_name) then
    return vim.notify("Clangd client not found", vim.log.levels.ERROR)
  end
  local win = vim.api.nvim_get_current_win()
  local params = vim.lsp.util.make_position_params(win, client.offset_encoding)
  ---@diagnostic disable-next-line:param-type-mismatch
  client:request(method_name, params, function(err, res)
    if err or #res == 0 then
      -- Clangd always returns an error, there is no reason to parse it
      return
    end
    local container = string.format("container: %s", res[1].containerName) ---@type string
    local name = string.format("name: %s", res[1].name) ---@type string
    vim.lsp.util.open_floating_preview({ name, container }, "", {
      height = 2,
      width = math.max(string.len(name), string.len(container)),
      focusable = false,
      focus = false,
      title = "Symbol Info",
    })
  end, bufnr)
end

vim.lsp.config("clangd", {
  cmd = function(dispatchers, config)
    local root_dir = config.root_dir
    local cmd = { clangd_select(root_dir) }
    return vim.lsp.rpc.start(cmd, dispatchers, {
      cwd = root_dir,
      env = config.cmd_env,
      detached = config.detached,
    })
  end,
  filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
  root_markers = {
    { ".clangd", ".clang-tidy", ".clang-format" },
    { "compile_commands.json", "compile_flags.txt", "configure.ac" },
    { ".git" },
  },
  get_language_id = function(_, ftype)
    local t = { objc = "objective-c", objcpp = "objective-cpp", cuda = "cuda-cpp" }
    return t[ftype] or ftype
  end,
  on_init = function(client, init_result)
    if init_result.offsetEncoding then
      client.offset_encoding = init_result.offsetEncoding
    end
  end,
  on_attach = function(client, bufnr)
    vim.api.nvim_buf_create_user_command(bufnr, "LspClangdSwitchSourceHeader", function()
      switch_source_header(bufnr, client)
    end, { desc = "Switch between source/header" })

    vim.api.nvim_buf_create_user_command(bufnr, "LspClangdShowSymbolInfo", function()
      symbol_info(bufnr, client)
    end, { desc = "Show symbol info" })

    --local cot = vim.bo[bufnr].cot
    --vim.bo[bufnr].completeopt = (cot ~= "" and cot .. "," or "") .. "menuone,noselect,popup"
    --vim.lsp.completion.enable(true, client.id, bufnr, {
    --  autotrigger = true,
    --  --convert = function(item)
    --  --  return { abbr = item.label:gsub("%b()", "") }
    --  --end,
    --})
  end,
})
vim.lsp.enable("clangd")
