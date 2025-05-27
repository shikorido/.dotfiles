-- The plugin requires a lot of work
-- to be compared with tmux-thumbs or
-- wezterm's implementation.
-- 1. It cannot combine labels and only uses 1 label for each match
--    from the given alphabet,
--    if there are more matches than labels -> fails silently.
-- 2. Using lua patters is not a right thing for very smart patterns.
return {
  "ausgefuchster/quickselect.nvim",
  -- Make it even more lazy by using keys.
  -- This implies lazy=true which makes Lazy to
  -- load the plugin if one its modules is require'd.
  -- However, with keys (and cmd, event, ft) Lazy will load the plugin
  -- anyway even if there are no require's of plugin modules.
  -- Note: if lazy=false is specified, Lazy will load
  -- the plugin on startup and will anyway set the specified keymaps.
  keys = {
    {
      '<leader>qs',
      function()
        require('quickselect').quick_select()
      end,
      desc = 'Quick select',
    },
    {
      '<leader>qy',
      function()
        require('quickselect').quick_yank()
      end,
      desc = 'Quick yank',
    },
  },
  opts = {
    use_default_patterns = false,
    labels = "asdfqwerzxcvjklmiuopghtybn",
    select_match = true,
    patterns = {
      -- Add your patterns here
      --DEFAULTS
      -- Hex color
      ----"#%x%x%x%x%x%x",
      -- Short-Hex color
      ----"#%x%x%x",
      -- RGB color
      ----"rgb(%d+,%d+,%d+)",
      -- IP Address
      --"%d+%.%d+%.%d+%.%d+",
      -- Email
      --"%w+@%w+%.%w+",
      -- URL
      --"https?://[%w-_%.%?%.:/%+=&]+",
      -- 4+ digit number
      --"%d%d%d%d+",
      -- File path
      --"~/[%w-_%.%?%.:/%+=&]+",
      --!DEFAULTS

      -- Lua pattern matching reference.
      -- https://www.lua.org/pil/20.2.html
      -- The plugin cannot handle labels exhaustion. We are restricted to 26 labels only.
      -- Should I extend its features one day?
      -- Idk how lua handles multiple %x?%x? or something but %x+ should be enough.

      --WezTerm
      -- markdown_url: [text](url)
      ---[=[\[[^]]*\]\(([^)]+)\)]=],
      --"%[[^]]*%]%(([^)]+)%)",
      -- url: http(s), git, ssh, ftp, file. http://something.com git@github.com ssh://git@github.com
      ---[=[(https?://|git@|git://|ssh://|ftp://|file://)%S+]=],
      --"https?://[%w-_%.%?%.:/%+=&]+",
      --"git://[%w-_%.%?%.:/%+=&]+",
      --"git@[%w-_%.%?%.:/%+=&]+",
      --"ssh://[%w-_%.%?%.:/%+=&@]+",
      --"ftp://[%w-_%.%?%.:/%+=&]+",
      --"file://[%w-_%.%?%.:/%+=&]+",
      -- diff_a: --- a/some.txt
      ---[=[--- a/(\S+)]=],
      --"--- a/(%S+)",
      -- diff_b: +++ b/some.txt
      ---[=[\+\+\+ b/(\S+)]=],
      --"%+%+%+ b/(%S+)",
      -- docker: sha256:05af05af05af05af05af05af05af05af05af05af05af05af05af05af05af05af
      ---[=[sha256:([0-9a-f]{64})]=],
      --"sha256:%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x",
      -- path: ~/.zshrc /usr/lib
      ---[=[(?:[.\w\-@~]+)?(?:/+[.\w\-@]+)+]=],
      --"([.%w%-@~]+)?(/+[.%w%-@]+)+",
      -- color: #ababab #aaa rgb(120,90,60)
      ---[=[#[0-9a-fA-F]{6}]=],
      "#%x%x%x%x%x%x",
      --"#%x%x%x",
      --"rgb%(%d+,%d+,%d+%)",
      --"rgb%(%d%d?%d?,%d%d?%d?,%d%d?%d?%)",
      -- uuid: 12345678-0000-1234-0987-0123456789ab
      ---[=[[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}]=],
      --"%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x",
      -- ipfs: Qmabcdefghijklmnopqrstyvwxyz0123456789abcdefyy
      ---[=[Qm[0-9a-zA-Z]{44}]=],
      --"Qm%w%w%w%w%w%w%w%w%w%w%w%w%w%w%w%w%w%w%w%w%w%w%w%w%w%w%w%w%w%w%w%w%w%w%w%w%w%w%w%w%w%w%w%w",
      -- sha: 051abce 051a2cefeb92a1b53
      ---[=[[0-9a-f]{7,40}]=],
      --"%x%x%x%x%x%x%x%x?%x?%x?%x?%x?%x?%x?%x?%x?%x?%x?%x?%x?%x?%x?%x?%x?%x?%x?%x?%x?%x?%x?%x?%x?%x?%x?%x?%x?%x?%x?%x?%x?",
      "%x%x%x%x%x%x%x+",
      -- ip: 1.23.233.0
      ---[=[\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}]=],
      "%d+%.%d+%.%d+%.%d+",
      --"%d%d?%d?%.%d%d?%d?%.%d%d?%d?%.%d%d?%d?",
      -- ipv6: ::1 2002::64/64 2002:abcd::1/32
      ---[=[[A-f0-9:]+:+[A-f0-9:]+[%\w\d]+]=],
      --"[%x:]+:[%x:]+",
      --"[%x:]+:[%x:]+[/%d]*",
      -- address: 0xDEAD0000
      ---[=[0x[0-9a-fA-F]+]=],
      --"0x%x+",
      -- number: 1234678
      ---[=[[0-9]{4,}]=]
      --"%d%d%d%d%d*"
      --!WezTerm
    },
    --keymap = {
    --  {
    --    mode = { 'n' },
    --    '<leader>qs',
    --    function()
    --      require('quickselect').quick_select()
    --    end,
    --    desc = 'Quick select'
    --  }
    --}
  },
}
