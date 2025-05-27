local remap = CFG_REQ("remap")
return {
  "L3MON4D3/LuaSnip",
  dependencies = { "rafamadriz/friendly-snippets" },
  -- install jsregexp (optional!)
  build = "make install_jsregexp",
  keys = remap.snippets.keys,
  config = function()
    local luasnip = require("luasnip")
    luasnip.filetype_extend("javascript", { "jsdoc" })
    remap.snippets.luasnip = luasnip
  end,
}
