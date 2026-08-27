return {
  "L3MON4D3/LuaSnip",
  config = function()
    local luasnip = require("luasnip")

    luasnip.setup({
      -- スニペットから抜けた後も少しの間ジャンプできるようにする
      history = true,
      updateevents = "TextChanged,TextChangedI",
    })

    -- ~/.config/nvim/luasnippets/<filetype>.lua を読み込む
    require("luasnip.loaders.from_lua").lazy_load({
      paths = vim.fn.stdpath("config") .. "/luasnippets",
    })
  end,
}
