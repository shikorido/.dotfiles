vim.lsp.config("zls", {
  capabilities = capabilities,
  root_markers = { "build.zig", "zls.json", ".git" },
  settings = {
    zls = {
      enable_inlay_hints = true,
      enable_snippets = true,
      warn_style = true,
    },
  },
  before_init = function()
    vim.g.zig_fmt_parse_errors = 0
    vim.g.zig_fmt_autosave = 0
  end,
})
