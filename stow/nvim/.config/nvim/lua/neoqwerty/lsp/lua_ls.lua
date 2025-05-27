-- Take everything from rtp except user config: neovim/nvim-lspconfig/issues/3189
-- The issue still applies if an active plugin is being edited elsewhere.
--local function library_except_user()
--  return vim.tbl_filter(function(d)
--    return not d:match(vim.fn.stdpath("config") .. "/?a?f?t?e?r?")
--  end, vim.api.nvim_get_runtime_file("", true))
--end

local function configure_nvim_library(client)
  if os.getenv("NVIM_NO_LUA_LSP_LIBRARY") then
    return
  end
  if client.workspace_folders then
    local path = client.workspace_folders[1].name
    if
      path ~= vim.fn.stdpath("config")
      and (vim.uv.fs_stat(path .. "/.luarc.json") or vim.uv.fs_stat(path .. "/.luarc.jsonc"))
    then
      return
    end
  end
  client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
    runtime = {
      version = "LuaJIT",
      path = {
        "lua/?.lua",
        "lua/?/init.lua",
      },
    },
    workspace = {
      checkThirdParty = false,
      library = {
        os.getenv("VIMRUNTIME"),
        vim.api.nvim_get_runtime_file("lua/lspconfig", false)[1],
      },
      --library = library_except_user(),
    },
  })
end

vim.lsp.config("lua_ls", {
  on_init = configure_nvim_library,
  cmd = { "lua-language-server" },
  filetypes = { "lua" },
  root_markers = {
    { ".emmyrc.json", ".luarc.json", ".luarc.jsonc" },
    { ".luacheckrc", ".stylua.toml", "stylua.toml", "selene.toml", "selene.yml" },
    { ".git" },
  },
  settings = {
    Lua = {
      runtime = { version = "LuaJIT" },
      codeLens = { enable = true },
      hint = { enable = true, semicolon = "Disable" },
      diagnostics = { globals = { "vim", "bit", "it", "describe", "before_each", "after_each" } },
    },
  },
})
vim.lsp.enable("lua_ls")
