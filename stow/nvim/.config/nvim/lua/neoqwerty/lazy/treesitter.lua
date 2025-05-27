return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter.configs").setup({
      -- A list of parser names, or "all"
      -- "gitcommit" was added due to false-positive internal logic
      -- that tries to install "tree-sitter-gitcommit" which does not exist.
      ensure_installed = {
        "vimdoc", "javascript", "c", "lua",
        "jsdoc", "bash", "gitcommit"
      },

      -- Install parsers synchronously (only applied to `ensure_installed`)
      sync_install = false,

      -- Automatically install missing parsers when entering buffer
      -- Recommendation: set to false if you dont have `tree-sitter` CLI installed locally
      auto_install = true,

      indent = {
        enable = true
      },

      highlight = {
        -- `false` will disable the whole extension
        enable = true,
        disable = function(lang, buf)
          if lang == "html" then
            print("ts highlight disabled for html")
            return true
          end

          -- Some files in linux kernel sources exceed the 100KB limit
          -- Because of that the limit was increased up to 250KB
          -- UPD. Increased to 1MB.
          local max_filesize = 1000 * 1024  -- 1MB
          local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
          if ok and stats and stats.size > max_filesize then
            vim.notify(
              "File larger than 1MB treesitter disabled for perfomance",
              vim.log.levels.WARN,
              { title = "Treesitter" }
            )
            return true
          end
        end,

        -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
        -- Set this to `true` if you depend on "syntax" being enabled (like for indentation).
        -- Using this option may slow down your editor, and you may see some duplicate highlights.
        -- Instead of true it can also be a list of languages.
        additional_vim_regex_highlighting = { "markdown" },
      },
    })

    local treesitter_parser_config = require("nvim-treesitter.parsers").get_parser_configs()
    treesitter_parser_config.templ = {
      install_info = {
        url = "https://github.com/vrischmann/tree-sitter-templ.git",
        files = { "src/parser.c", "src/scanner.c" },
        branch = "master",
      },
    }

    vim.treesitter.language.register("templ", "templ")
  end,
}
