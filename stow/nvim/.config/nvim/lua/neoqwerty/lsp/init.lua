local M = setmetatable({}, {
  __index = function(t, k)
    local v = rawget(t, k)
    if v == nil then
      v = CFG_REQ("lsp." .. k)
      rawset(t, k, v)
    end
    return v
  end
})

local _
_ = M.clangd
_ = M.lua_ls
_ = M.powershell_es

return M
