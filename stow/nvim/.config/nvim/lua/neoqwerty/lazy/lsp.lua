local remap = CFG_REQ("remap")

return {
  "neovim/nvim-lspconfig",
  dependencies = {
    {
      "shikorido/conform.nvim", -- stevearc/conform.nvim
      branch = "save-cursorpos",
    },
--    --"williamboman/mason.nvim",
--    --"williamboman/mason-lspconfig.nvim",
--    --"hrsh7th/cmp-nvim-lsp",
--    --"hrsh7th/cmp-buffer",
--    --"hrsh7th/cmp-path",
--    --"hrsh7th/cmp-cmdline",
--    --"hrsh7th/nvim-cmp",
--    --"L3MON4D3/LuaSnip",
--    --"saadparwaiz1/cmp_luasnip",
--    --"j-hui/fidget.nvim",
  },
--
  config = function()
    require("conform").setup({
      --default_format_opts = { save_cursorpos = true },
      formatters_by_ft = {
        javascript = { "prettier" },
        lua = { "stylua", "vim_indent" },
        python = { "black" },
      },
    })
--    --local cmp = require("cmp")
--    --local cmp_lsp = require("cmp_nvim_lsp")
--    --local capabilities = vim.tbl_deep_extend(
--    --  "force",
--    --  {},
--    --  vim.lsp.protocol.make_client_capabilities(),
--    --  cmp_lsp.default_capabilities()
--    --)
--
--    --require("fidget").setup()
--    --require("mason").setup()
--    --require("mason-nvim-dap").setup({
--    --  ensure_installed = {},
--    --  handlers = {
--    --    function(config)
--    --      -- all sources with no handler passed here
--    --      -- Keep original functionality
--    --      require("mason-nvim-dap").default_setup(config)
--    --    end,
--    --  }
--    --})
--    --require("mason-lspconfig").setup({
--    --  ensure_installed = {
--    --    -- With split configs for termux it is better to not preinstall anything
--    --    -- TODO: Install only when termux is not detected.
--    --    --       Figure out how LSP is setted up in neovim.
--    --    --"lua_ls",
--    --  },
--    --  handlers = {
--    --    function(server_name) -- default handler (optional)
--    --      require("lspconfig")[server_name].setup {
--    --        capabilities = capabilities
--    --      }
--    --    end,
--    --  },
--    --})
--
--    --cmp.setup({
--    --  snippet = {
--    --    expand = function(args)
--    --      require("luasnip").lsp_expand(args.body)
--    --    end,
--    --  },
--    --  mapping = cmp.mapping.preset.insert(remap.lsp.cmpMapping(cmp)),
--    --  sources = cmp.config.sources({
--    --    { name = "nvim_lsp" },
--    --    { name = "luasnip" },
--    --  }, {
--    --    { name = "buffer" },
--    --  }),
--    --})
--
--    --vim.diagnostic.config({
--    --  -- update_in_insert = true,
--    --  float = {
--    --    focusable = false,
--    --    style = "minimal",
--    --    border = "rounded",
--    --    source = "always",
--    --    header = "",
--    --    prefix = "",
--    --  },
--    --})
  end,
}
