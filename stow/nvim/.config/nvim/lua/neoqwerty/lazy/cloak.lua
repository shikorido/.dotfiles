local file_patterns = {
  "wrangler.toml",
  ".dev.vars",
  -- Match any file starting with ".env".
  ".env*",
  -- Shows how to include files with a comma,
  -- otherwise comma acts as a separator.
  --"comma\\,file"
}

return {
  "laytan/cloak.nvim",
  event = {
    {
      event = "BufEnter",
      pattern = file_patterns,
    },
  },
  opts = {
    enabled = true,
    cloak_character = "*",
    highlight_group = "Comment",
    patterns = {
      {
        -- This can be a table to match multiple file patterns.
        file_pattern = file_patterns,
        -- Match an equals sign and any character after it.
        -- This can also be a table of patterns to cloak.
        -- example: cloak_pattern = { ":.+", "-.+" } for yaml files.
        cloak_pattern = "=.+",
        -- The cloak_pattern can also be a table of inner_patterns:
        --cloak_pattern = {
        --  "(a=).+",
        --  { "(b=).+" },
        --  { "(c=).+", replace = "[inner] %1" },
        --  -- The outer `replace` could also be specified here instead
        --},
        --replace = "[outer] %1",
        -- A function, table or string to generate the replacement.
        -- The actual replacement will contain the 'cloak_character'
        -- where it doesn't cover the original text.
        -- If left empty the legacy behavior of keeping the first character is retained.
        replace = nil,
        -- This would result in a cloaking of text like this:
        -- [outer] a=**
        -- b***********
        -- [inner] c=**
        -- The original file was:
        -- a=1234567890
        -- b=1234567890
        -- c=1234567890
      },
    },
  },
}
