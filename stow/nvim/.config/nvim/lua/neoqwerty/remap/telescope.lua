local M, L = {}, {}

M.keys = {
  { "<leader>pf", function() M.builtin.find_files() end },
  { "<leader>pF", function() L.find_files_all() end },
  { "<leader>pg", function() M.builtin.live_grep() end },
  { "<leader>pG", function() L.live_grep_all() end },
  { "<C-p>", function() M.builtin.git_files() end },
  --{ "<C-[>", function() M.git_files_root() end },
  { "<leader>pws", function() L.grep_word() end },
  { "<leader>pwS", function() L.grep_word_all() end },
  { "<leader>pWs", function() L.grep_WORD() end },
  { "<leader>pWS", function() L.grep_WORD_all() end },
  { "<leader>ps", function() L.grep_string() end },
  { "<leader>pS", function() L.grep_string_all() end },
  { "<leader>vh", function() M.builtin.help_tags() end },
}

L.find_all_args = { follow = true, hidden = true, no_ignore = true }
L.grep_all_args = { "--follow", "--hidden", "--no-ignore" }

L.find_files_all = function()
  M.builtin.find_files(M.find_all_args)
end

L.live_grep_all = function()
  M.builtin.live_grep({ additional_args = M.grep_all_args })
end

L.grep_word = function()
  local word = vim.fn.expand("<cword>")
  M.builtin.grep_string({ search = word })
end

L.grep_word_all = function()
  local word = vim.fn.expand("<cword>")
  M.builtin.grep_string({ search = word, additional_args = M.grep_all_args })
end

L.grep_WORD = function()
  local word = vim.fn.expand("<cWORD>")
  M.builtin.grep_string({ search = word })
end

L.grep_WORD_all = function()
  local word = vim.fn.expand("<cWORD>")
  M.builtin.grep_string({ search = word, additional_args = M.grep_all_args })
end

L.grep_string = function()
  M.builtin.grep_string({ search = vim.fn.input("Grep > ") })
end

L.grep_string_all = function()
  M.builtin.grep_string({ search = vim.fn.input("Grep > "), additional_args = M.grep_all_args })
end

L.git_files_root = function()
  -- made by @wesbragagt
  local function is_git_repo()
    local obj = vim.system({ "git", "rev-parse", "--is-inside-work-tree" }):wait()
    return obj.code == 0
  end
  local function get_git_root()
    local dot_git_path = vim.fn.finddir(".git", ".;")
    return vim.fn.fnamemodify(dot_git_path, ":h")
  end
  local opts = {}
  if is_git_repo() then
    opts = {
      cwd = get_git_root(),
    }
  end
  M.builtin.find_files(opts)
end

return M
