-- https://dev.to/voyeg3r/-building-a-robust-neovim-format-autocommand-9ii
local M = {}

M.trim_whitespace = function(bufnr)
  bufnr = bufnr or 0
  if vim.bo[bufnr].modifiable == false then return end
  local view = vim.fn.winsaveview()
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local modified = false

  for i = 1, #lines do
    local trimmed = lines[i]:gsub('%s+$', '')
    if trimmed ~= lines[i] then
      lines[i] = trimmed
      modified = true
    end
  end

  if modified then
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
    vim.fn.winrestview(view)
  end
end

M.squeeze_blank_lines = function(bufnr)
  bufnr = bufnr or 0
  if vim.bo[bufnr].binary or vim.bo[bufnr].filetype == 'diff' then return end

  local cursor_line, cursor_col = unpack(vim.api.nvim_win_get_cursor(0))
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

  local cleaned = {}
  local excess_blank_lines = 0
  local blank_run = 0

  for i, line in ipairs(lines) do
    local is_blank = line:match('^%s*$') ~= nil

    if is_blank then
      blank_run = blank_run + 1
    else
      if blank_run >= 2 and i <= cursor_line then
        excess_blank_lines = excess_blank_lines + (blank_run - 1)
      end
      blank_run = 0
    end

    if not is_blank or (is_blank and blank_run == 1) then
      table.insert(cleaned, is_blank and '' or line)
    end
  end

  -- Remove trailing blank lines
  for i = #cleaned, 1, -1 do
    if cleaned[i]:match('^%s*$') then
      table.remove(cleaned, i)
    else
      break
    end
  end

  M.with_preserved_view(function() vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, cleaned) end)

  if excess_blank_lines > 0 then
    local final_line = math.max(1, cursor_line - excess_blank_lines)
    final_line = math.min(final_line, #cleaned)
    vim.api.nvim_win_set_cursor(bufnr, { final_line, cursor_col })
  end
end

M.with_preserved_view = function(op)
  local view = vim.fn.winsaveview()
  local ok, err = pcall(function()
    if type(op) == 'function' then
      op()
    else
      vim.cmd(('keepjumps keeppatterns %s'):format(op))
    end
  end)
  vim.fn.winrestview(view)
  if not ok then vim.notify(err, vim.log.levels.ERROR) end
end

M.format_all = function(bufnr)
  bufnr = bufnr or 0

  if
    not vim.api.nvim_buf_is_loaded(bufnr)
    or not vim.api.nvim_buf_get_option(bufnr, 'modifiable')
    or vim.api.nvim_buf_get_option(bufnr, 'buftype') ~= ''
    or vim.api.nvim_buf_get_option(bufnr, 'filetype') == ''
  then
    return
  end

  local conform = require('conform')
  --local utils = require('core.utils')
  --utils.text_manipulation.trim_whitespace(bufnr)
  --utils.text_manipulation.squeeze_blank_lines(bufnr)

  M.trim_whitespace(bufnr)
  M.squeeze_blank_lines(bufnr)

  local ok, err = pcall(function()
    conform.format({
      bufnr = bufnr,
      async = false,
      lsp_format = "never",
      timeout_ms = 2000,
    })
  end)

  if not ok then
    -- fallback manual: reindent a buffer while preserving the view
    vim.api.nvim_buf_call(bufnr, function()
      M.with_preserved_view(function()
        vim.cmd('normal! gg=G')
      end)
    end)
  end
end
