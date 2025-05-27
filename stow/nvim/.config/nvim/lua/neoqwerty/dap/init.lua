local M = setmetatable({}, {
  __index = function(t, k)
    local v = rawget(t, k)
    if v == nil then
      v = CFG_REQ("dap." .. k)
      rawset(t, k, v)
    end
    return v
  end
})

local _
_ = M.powershell_es

return M
