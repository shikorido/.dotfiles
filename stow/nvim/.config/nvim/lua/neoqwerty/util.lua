local fmt = CFG_REQ("format")

local M = {}

--local function endswith(str, suffix)
--  return str:sub(- #suffix) == suffix
--end

M.set_tabwidth = function(tw, bo)
  if bo == nil then
    bo = true
  end
  if tw == nil then
    tw = 4
  end
  if bo then
    vim.bo.tabstop = tw
    vim.bo.softtabstop = tw
    vim.bo.shiftwidth = tw
    vim.notify("Tabwidth: "..tw.." for the current buffer", vim.log.levels.INFO)
  else
    vim.opt.tabstop = tw
    vim.opt.softtabstop = tw
    vim.opt.shiftwidth = tw
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      vim.bo[buf].tabstop     = vim.opt.tabstop:get()
      vim.bo[buf].softtabstop = vim.opt.softtabstop:get()
      vim.bo[buf].shiftwidth  = vim.opt.shiftwidth:get()
      vim.notify("Tabwidth: "..tw.." for all opened buffers", vim.log.levels.INFO)
    end
  end
end

M.to_tabs = function(bufnr)
  if not bufnr or bufnr == 0 then
    bufnr = vim.api.nvim_get_current_buf()
  end
  local sw = vim.bo[bufnr].sw
  if sw == 0 then
    sw = vim.bo[bufnr].ts
  end

  local original_lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local new_lines, modified
  for i, line in ipairs(original_lines) do
    local spaces = line:match("^( +)")
    if spaces then
      if not new_lines then
        new_lines = vim.deepcopy(original_lines)
        modified = true
      end
      local n = #spaces
      local tabs = math.floor(n / sw)
      local rest = n % sw
      new_lines[i] = string.rep("\t", tabs) .. string.rep(" ", rest) .. line:sub(n + 1)
    end
  end

  if modified then
    fmt.update_lines_preserve_cursor(bufnr, original_lines, new_lines)
  end

  return modified
end
-- Vimscript, but it does not work by some reason, or I'm dumb.
--vim.cmd(string.format([[
--  silent keepjumps %%s/^\( *\)/\=repeat("\t", strlen(submatch(1)) / %d) . repeat(" ", strlen(submatch(1)) %% %d)/e
--]], ts, ts))

-- Convert leading tabs to spaces based on shiftwidth.
M.to_spaces = function(bufnr)
  if not bufnr or bufnr == 0 then
    bufnr = vim.api.nvim_get_current_buf()
  end
  local sw = vim.bo[bufnr].sw
  if sw == 0 then
    sw = vim.bo[bufnr].ts
  end

  local original_lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local new_lines, modified
  for i, line in ipairs(original_lines) do
    local tabs = line:match("^(\t+)")
    if tabs then
      if not new_lines then
        new_lines = vim.deepcopy(original_lines)
        modified = true
      end
      local n = #tabs
      local spaces = n * sw
      new_lines[i] = string.rep(" ", spaces) .. line:sub(n + 1)
    end
  end

  if modified then
    fmt.update_lines_preserve_cursor(bufnr, original_lines, new_lines)
  end

  return modified
end

return M
