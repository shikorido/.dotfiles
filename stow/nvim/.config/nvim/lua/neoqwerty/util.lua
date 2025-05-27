local fmt = CFG_REQ("format")
local log = CFG_REQ("log")

local M = {}

--local function endswith(str, suffix)
--  return str:sub(- #suffix) == suffix
--end

M.toggle_whitespace = function()
  vim.wo.list = not vim.wo.list
  if vim.wo.list then
    vim.notify("Whitespace: visible", vim.log.levels.INFO)
  else
    vim.notify("Whitespace: hidden", vim.log.levels.INFO)
  end
end

M.toggle_expandtab = function()
  vim.bo.et = not vim.bo.et
  if vim.bo.et then
    vim.notify("Tab: spaces enabled", vim.log.levels.INFO)
  else
    vim.notify("Tab: real tabs enabled", vim.log.levels.INFO)
  end
end

local ff_shuffle = {
  unix = { "dos", "CRLF" },
  dos = { "mac", "CR" },
  mac = { "unix", "LF" },
}

M.toggle_fileformat = function()
  local ff, eol = unpack(ff_shuffle[vim.bo.ff])
  vim.bo.ff = ff ---@diagnostic disable-line:assign-type-mismatch
  vim.notify("EOL: switched to " .. eol .. " (" .. ff .. ")", vim.log.levels.INFO)
end

M.set_shiftwidth = function(sw, bo)
  if sw == nil then
    sw = 4
  end
  if bo == nil then
    bo = true
  end
  if bo then
    vim.bo.sw = sw
    vim.notify("shiftwidth=" .. sw .. " for the current buffer", vim.log.levels.INFO)
  else
    vim.go.sw = sw
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      if vim.bo[buf].bl and vim.bo[buf].bt ~= "" and vim.bo[buf].ma then
        vim.bo[buf].sw = sw
      end
    end
    vim.notify("shiftwidth=" .. sw .. " for all listed buffers", vim.log.levels.INFO)
  end
end

-- Convert leading spaces to tabs based on shiftwidth.
M.to_tabs = function(bufnr)
  if not bufnr or bufnr == 0 then
    bufnr = vim.api.nvim_get_current_buf()
  end
  local sw = vim.bo[bufnr].sw
  if sw == 0 then
    sw = vim.bo[bufnr].ts
  end
  vim.bo[bufnr].et = false

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
    vim.notify(
      sw .. " leading spaces were replaced with tabs, expandtab disabled",
      vim.log.levels.INFO
    )
  end

  return modified
end

-- Convert leading tabs to spaces based on shiftwidth.
M.to_spaces = function(bufnr)
  if not bufnr or bufnr == 0 then
    bufnr = vim.api.nvim_get_current_buf()
  end
  local sw = vim.bo[bufnr].sw
  if sw == 0 then
    sw = vim.bo[bufnr].ts
  end
  vim.bo[bufnr].et = true

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
    vim.notify(
      "Leading tabs were replaced with " .. sw .. " spaces, expandtab enabled",
      vim.log.levels.INFO
    )
  end

  return modified
end
-- Vimscript, but view still must be restored afterwards (:h :s\=).
--vim.cmd(string.format([[
--  silent keepjumps keeppatterns lockmarks %%s@^\( *\)@\=repeat("\t", strlen(submatch(1)) / %d) . repeat(" ", strlen(submatch(1)) %% %d)@e
--]], sw, sw))

-- If register contains NL at the end of string, vim uses special behavior for put:
-- insert after (p) or before (P) current line. If so, just pass "_dP straight away.
-- One more special case. If the whole buffer contents is being replaced. NL survives "_d.
-- Proposed solution: save " contents, do regular put (p and P are equal in x mode), restore ".
-- However, it'll populate number registers history and small delete register (-).
-- Unlikely bothers someone, but good to know. Can be solved similarly (expensive?).
M.greatest_remap_fix = function()
  local saved_unnamed = vim.fn.getreg('"')
  local saved_numbers = {}
  for i = 1, 9 do
    saved_numbers[#saved_numbers + 1] = vim.fn.getreg(tostring(i))
  end
  local saved_small_delete = vim.fn.getreg("-")
  vim.cmd([[norm! p]])
  vim.fn.setreg('"', saved_unnamed)
  for i = 1, 9 do
    vim.fn.setreg(tostring(i), saved_numbers[i])
  end
  vim.fn.setreg("-", saved_small_delete)
  --if vim.fn.getreg('"'):byte(-1) == 10 then
  --  vim.cmd([[norm! "_dP]])
  --  return
  --end
  --local mode = vim.fn.mode()
  --local regionpos = vim.fn.getregionpos(vim.fn.getpos("v"), vim.fn.getpos("."), { type = mode })
  --vim.cmd([[norm! "_d]])
  --if vim.fn.getpos(".")[3] ~= regionpos[1][1][3] then
  --  vim.cmd("undoj|norm! p")
  --else
  --  vim.cmd("undoj|norm! P")
  --end
end

M.cd_current = function()
  if vim.bo.ft == "netrw" then
    vim.cmd("norm cd")
  else
    if vim.fn.expand("%") ~= "" then
      vim.cmd("cd %:h")
    end
  end
end

M.undo_diff = function()
  local buf = vim.api.nvim_get_current_buf()
  local current = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  if #current[#current] ~= "" then
    current[#current + 1] = ""
  end
  local cur_str = table.concat(current, "\n")

  local seq = vim.fn.undotree().seq_cur
  if seq == 0 then return end
  vim.cmd("sil noa loc keepj keepp u 0")

  local original = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  if #original[#original] ~= "" then
    original[#original + 1] = ""
  end
  local orig_str = table.concat(original, "\n")

  vim.cmd("sil noa loc keepj keepp u " .. seq)
  ---@type string
  ---@diagnostic disable-next-line
  local diff = vim.text.diff(orig_str, cur_str, { ctxlen = 3 })
  local buftmp = vim.api.nvim_create_buf(true, false)
  vim.bo[buftmp].bh = "wipe"
  vim.bo[buftmp].bt = "nofile"
  vim.bo[buftmp].ft = "diff"
  vim.bo[buftmp].swf = false
  local diff_lines = vim.split(diff, "\n")
  if diff_lines[#diff_lines] == "" then
    diff = diff:sub(0, -2)
    table.remove(diff_lines)
  end
  vim.api.nvim_buf_set_lines(buftmp, 0, -1, false, diff_lines)
  vim.cmd("vs +" .. buftmp .. "b")

  log.warn("Original string:%s", orig_str)
  log.warn("Current string:%s", cur_str)
  log.warn("Diff:%s", diff)
end

return M
