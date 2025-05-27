return {
  "neovim/nvim-lspconfig",
  dependencies = {
    {
      --"stevearc/conform.nvim",
      "shikorido/conform.nvim",
      branch = "save-cursorpos"
    },
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-path",
    "hrsh7th/cmp-cmdline",
    "hrsh7th/nvim-cmp",
    "L3MON4D3/LuaSnip",
    "saadparwaiz1/cmp_luasnip",
    "j-hui/fidget.nvim",
  },

  config = function()
    require("conform").setup({
      --default_format_opts = { save_cursorpos = true },
      formatters_by_ft = {
        javascript = { "prettier" },
        lua = { "stylua", "vim_indent" },
        python = { "black" },
      },
    })
    local cmp = require("cmp")
    local cmp_lsp = require("cmp_nvim_lsp")
    local capabilities = vim.tbl_deep_extend(
      "force",
      {},
      vim.lsp.protocol.make_client_capabilities(),
      cmp_lsp.default_capabilities()
    )

    require("fidget").setup({})
    require("mason").setup()
    require("mason-lspconfig").setup({
      ensure_installed = {
        --Until I do split configs in lua for termux it is better to not preinstall anything
        --"lua_ls",
      },
      handlers = {
        function(server_name) -- default handler (optional)
          require("lspconfig")[server_name].setup {
            capabilities = capabilities
          }
        end,

        -- zls config (ThePrimeAgen's) (legacy config style but still works)
        --zls = function()
        --    local lspconfig = require("lspconfig")
        --    lspconfig.zls.setup({
        --        root_dir = lspconfig.util.root_pattern(".git", "build.zig", "zls.json"),
        --        settings = {
        --            zls = {
        --                enable_inlay_hints = true,
        --                enable_snippets = true,
        --                warn_style = true
        --            }
        --        }
        --    })
        --    vim.g.zig_fmt_parse_errors = 0
        --    vim.g.zig_fmt_autosave = 0
        --end,

        -- lua-language-server config
        --lua_ls = function()
        --    local lspconfig = require("lspconfig")
        --    lspconfig.lua_ls.setup({
        --        capabilities = capabilities,
        --        -- Command and arguments to start the server.
        --        --cmd = { "lua-language-server" },
        --        -- Filetypes to automatically attach to.
        --        --filetypes = { "lua" },
        --        -- Sets the "root directory" to the parent directory of the file in the
        --        -- current buffer that contains either ".luarc.json" or a
        --        -- ".luarc.jsonc" file, otherwise .git folder location will serve as root dir marker.
        --        -- Files that share a root directory will reuse
        --        -- the connection to the same LSP server.
        --        --root_markers = { ".luarc.json", ".luarc.jsonc", ".luacheckrc", ".stylua.toml", "stylua.toml", "selene.toml", "selene.yml", ".git" },
        --        -- Specific settings to send to the server. The schema for this is
        --        -- defined by the server. For example the schema for lua-language-server
        --        -- can be found here
        --        -- https://raw.githubusercontent.com/LuaLS/vscode-lua/master/settings/schema.json
        --        settings = {
        --            Lua = {
        --                runtime = { version = "Lua 5.1" },
        --                diagnostics = {
        --                    globals = { "bit", "vim", "it", "describe", "before_each", "after_each" }
        --                }
        --            }
        --        }
        --    })
        --end,

        -- pylsp config
        --pylsp = function()
        --    local lspconfig = require("lspconfig")
        --    lspconfig.pylsp.setup({
        --        capabilities = capabilities,
        --        --cmd = { "pylsp" },
        --        --filetypes = { "python" },
        --        --root_markers = { "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", "Pipfile", ".git" },
        --        -- Useful links to configure pylsp
        --        -- https://jdhao.github.io/2023/07/22/neovim-pylsp-setup/
        --        -- https://vi.stackexchange.com/questions/39765/how-to-configure-pylsp-when-using-mason-and-mason-lspconfig-in-neovim
        --        -- https://www.reddit.com/r/neovim/comments/tttofk/how_to_disable_annoying_pylint_warningespecially/
        --        -- https://github.com/python-lsp/python-lsp-server
        --        settings = {
        --            pylsp = {
        --                plugins = {
        --                    pycodestyle = {
        --                        ignore = { 'E221', 'E266', 'E501' }
        --                    }
        --                }
        --            }
        --        }
        --    })
        --end,

        -- clangd config
        --clangd = function()
        --    local lspconfig = require("lspconfig")
        --    lspconfig.clangd.setup({
        --        capabilities = capabilities,
        --        --cmd = { "clangd" },
        --        -- How to specify extensions? Does separate BufEnter func is required?
        --        --filetypes = { "c", "cpp", "h", "hpp", "objc", "objcpp", "cuda", "proto", "S", "c_shipped", "h_shipped", "S_shipped" },
        --        --root_markers = { ".clangd", ".clang-tidy", ".clang-format", "compile_commands.json", "compile-flags.txt", "configure.ac", ".git" },
        --        settings = {
        --        }
        --    })
        --end
      }
    })

    -- pylsp config
    vim.lsp.config("pylsp", {
      capabilities = capabilities,
      --cmd = { "pylsp" },
      --filetypes = { "python" },
      --root_markers = { "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", "Pipfile", ".git" },
      -- Useful links to configure pylsp
      -- https://jdhao.github.io/2023/07/22/neovim-pylsp-setup/
      -- https://vi.stackexchange.com/questions/39765/how-to-configure-pylsp-when-using-mason-and-mason-lspconfig-in-neovim
      -- https://www.reddit.com/r/neovim/comments/tttofk/how_to_disable_annoying_pylint_warningespecially/
      -- https://github.com/python-lsp/python-lsp-server
      settings = {
        pylsp = {
          plugins = {
            pycodestyle = {
              ignore = { 'E221', 'E266', 'E501' }
            },
          },
        },
      },
    })
    --vim.lsp.enable("pylsp");

    -- lua-language-server config
    vim.lsp.config("lua_ls", {
      capabilities = capabilities,
      -- Command and arguments to start the server.
      --cmd = { "lua-language-server" },
      -- Filetypes to automatically attach to.
      --filetypes = { "lua" },
      -- Sets the "root directory" to the parent directory of the file in the
      -- current buffer that contains either ".luarc.json" or a
      -- ".luarc.jsonc" file, otherwise .git folder location will serve as root dir marker.
      -- Files that share a root directory will reuse
      -- the connection to the same LSP server.
      --root_markers = { ".luarc.json", ".luarc.jsonc", ".luacheckrc", ".stylua.toml", "stylua.toml", "selene.toml", "selene.yml", ".git" },
      -- Specific settings to send to the server. The schema for this is
      -- defined by the server. For example the schema for lua-language-server
      -- can be found here
      -- https://raw.githubusercontent.com/LuaLS/vscode-lua/master/settings/schema.json
      settings = {
        Lua = {
          runtime = { version = "Lua 5.1" },
          diagnostics = {
            globals = { "bit", "vim", "it", "describe", "before_each", "after_each" },
          },
        },
      },
    })
    --vim.lsp.enable("lua_ls");

    -- clangd config
    vim.lsp.config("clangd", {
      capabilities = capabilities,
      --cmd = { "clangd" },
      -- How to specify extensions? Does separate BufEnter func is required?
      --filetypes = { "c", "cpp", "h", "hpp", "objc", "objcpp", "cuda", "proto", "S", "c_shipped", "h_shipped", "S_shipped" },
      --root_markers = { ".clangd", ".clang-tidy", ".clang-format", "compile_commands.json", "compile-flags.txt", "configure.ac", ".git" },
      settings = {
      },
    })
    --vim.lsp.enable("clangd");

    local cmp_select = { behavior = cmp.SelectBehavior.Select }

    cmp.setup({
      snippet = {
        expand = function(args)
          require("luasnip").lsp_expand(args.body) -- For `luasnip` users.
        end,
      },
      mapping = cmp.mapping.preset.insert({
        ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
        ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
        ['<C-y>'] = cmp.mapping.confirm({ select = true }),
        ['<C-Space>'] = cmp.mapping.complete(),
      }),
      sources = cmp.config.sources(
        {
          { name = "nvim_lsp" },
          { name = "luasnip" }, -- For luasnip users.
        },
        {
          { name = "buffer" },
        }
      )
    })

    vim.diagnostic.config({
      -- update_in_insert = true,
      float = {
        focusable = false,
        style = "minimal",
        border = "rounded",
        source = "always",
        header = "",
        prefix = "",
      },
    })
  end,
}
