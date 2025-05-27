local M = {}

----- @diagnostic disable-next-line:unused-local,unused-function
--local function get_buffer_hash(bufnr)
--  -- Create a hash of the buffer's contents.
--  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
--  return vim.fn.sha256(table.concat(lines))
--end

-- Note: to completely fix the cursor jump issue on undo we must either
-- replace the whole buffer with formatted lines (simplest),
-- or merge the diffs depending on 2 cases:
-- 1. If the cursor is on line before first diff we can simply
--    copy this one line the cursor stays on.
-- 2. If the cursor is on line after first diff we must merge
--    all the consequent lines with the current cursor line.
--    This way vim will respect our cursor pos on undo.
-- Also don't forget redo correction.
M.update_lines_preserve_cursor = function(bufnr, original_lines, new_lines)
  if not bufnr or bufnr == 0 then
    bufnr = vim.api.nvim_get_current_buf()
  end

  local cursor_line = vim.api.nvim_buf_call(bufnr, function()
    return vim.fn.getpos(".")[2]
  end)

  -- Preemptive redo correction.
  if cursor_line > #new_lines then
    vim.api.nvim_buf_call(bufnr, function()
      local view = vim.fn.winsaveview()
      local diff = cursor_line - #new_lines
      view.lnum = view.lnum - diff
      view.topline = view.topline - diff
      vim.fn.winrestview(view)
    end)
    cursor_line = #new_lines
  end

  local savedview = vim.api.nvim_buf_call(bufnr, function()
    return vim.fn.winsaveview()
  end)

  local first_diff_start_line, first_diff_end_line
  local first_diff = {}
  local min_lines = math.min(#original_lines, #new_lines)

  for i = 1, min_lines do
    if original_lines[i] ~= new_lines[i] then
      if first_diff then
        if not first_diff_start_line then
          first_diff_start_line = i
        else
          first_diff_end_line = i
        end
      else
        vim.api.nvim_buf_set_lines(bufnr, i - 1, i, false, { new_lines[i] })
      end
    end
    if first_diff then
      if i == cursor_line then
        if not first_diff_start_line then
          first_diff_start_line = cursor_line
        end
        first_diff_end_line = cursor_line
        for j = first_diff_start_line, first_diff_end_line do
          table.insert(first_diff, new_lines[j])
        end
        vim.api.nvim_buf_set_lines(bufnr, first_diff_start_line - 1, first_diff_end_line, false, first_diff)
        first_diff = nil
      end
    end
  end

  -- Or simply copy the formatted lines (with redo correction).
  --vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, new_lines)

  vim.api.nvim_buf_call(bufnr, function()
    vim.fn.winrestview(savedview)
  end)
end

M.format_builtin = function(bufnr)
  if not bufnr or bufnr == 0 then
    bufnr = vim.api.nvim_get_current_buf()
  end

  local mode = vim.api.nvim_get_mode().mode
  local start_line, end_line
  vim.api.nvim_buf_call(bufnr, function()
    -- mode == "\22" means visual block, conform
    -- only checks for regular and visual line.
    if mode == "v" or mode == "V" then
      start_line = vim.fn.getpos(".")[2]
      end_line = vim.fn.getpos("v")[2]
      if start_line > end_line then
        start_line, end_line = end_line, start_line
      end
    end
  end)

  -- Get all lines from the original buffer.
  local original_lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

  -- Create a temporary buffer to work with.
  local temp_buf = vim.api.nvim_create_buf(false, true)

  -- Copy buffer options to the temp buffer.
  local opts = {
    "ts", "sts", "sw", "et", "ft", "ff"
    -- The following options can be omitted.
    --"smarttab" -- window opt, does not work for buf.
    --"smartindent", "autoindent",
    --"cindent", "indentexpr"
  }
  for _, opt in ipairs(opts) do
    local sval = vim.api.nvim_get_option_value(opt, { buf = bufnr })
    vim.api.nvim_set_option_value(opt, sval, { buf = temp_buf })
  end

  -- Copy lines from the original buffer to the temporary buffer.
  vim.api.nvim_buf_set_lines(temp_buf, 0, -1, false, original_lines)

  if not start_line or not end_line then
    -- Run gg=G in the temporary buffer to indent everything.
    vim.api.nvim_buf_call(temp_buf, function() vim.cmd("silent normal! gg=G") end)
  else
    -- Indent range only.
    vim.api.nvim_buf_call(temp_buf, function()
      -- The following %dG=%dG action (and gg=G for a full buffer)
      -- does not reset mode, unlike
      -- "<", ">", "gv="
      -- and
      -- ".", mode, ".", "="
      vim.cmd(string.format(
        "silent normal! %dG=%dG",
        start_line,
        end_line
      ))
    end)
  end

  -- Get modified lines from the temporary buffer.
  local new_lines = vim.api.nvim_buf_get_lines(temp_buf, 0, -1, false)

  M.update_lines_preserve_cursor(bufnr, original_lines, new_lines)

  -- Clean up the temporary buffer.
  vim.api.nvim_buf_delete(temp_buf, { force = true })
end

M.format_conform = function(bufnr)
  if not bufnr or bufnr == 0 then
    bufnr = vim.api.nvim_get_current_buf()
  end

  -- Format the given buffer using conform.nvim
  -- (external formatter or fallback to LSP if specified).
  -- ok is true if "conform" is present.
  -- err is either false if no formatters attempted,
  -- or an actual error if "conform" was not found.
  -- But still, we can only find if any changes were made
  -- by either manually taking buffer hash before and after formatting
  -- or we can simply rely on did_edit flag (however, it might
  -- be already formatted, so we must rely on ok, err and did_edit altogether).
  local ok, err = pcall(function()
    local cb_err
    local edited = false
    local any_attempted = require("conform").format(
      {
        bufnr = bufnr,
        async = false,
        lsp_format = "never",
        timeout_ms = 2000,
        quiet = true,
        stop_after_first = true,
        save_cursorpos = true,
      },
      function(err, did_edit)
        cb_err = err
        edited = did_edit and true or false
      end
    )
    return {
      any_attempted = any_attempted,
      edited = edited,
      err = cb_err
    }
  end)

  if not ok or not err.any_attempted then
    vim.notify("Format failed with "..(type(err) == "string" and err or vim.inspect(err)), vim.log.levels.WARN)
    -- Fallback to temporary buffer format.
    M.format_builtin(bufnr)
  end
end

return M
