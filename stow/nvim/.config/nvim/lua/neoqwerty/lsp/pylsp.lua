vim.lsp.config("pylsp", {
  cmd = { "pylsp" },
  filetypes = { "python" },
  root_markers = {
    { "Pipfile", "pyproject.toml", "requirements.txt" },
    { "setup.py", "setup.cfg" },
    ".git",
  },
  settings = {
    pylsp = {
      plugins = {
        pycodestyle = {
          ignore = { "E221", "E266", "E501" },
        },
      },
    },
  },
})
