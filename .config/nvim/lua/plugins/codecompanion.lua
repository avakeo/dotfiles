return {
  "olimorris/codecompanion.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  opts = {
    adapters = {
      anthropic = function()
        return require("codecompanion.adapters").extend("anthropic", {
          env = {
            api_key = "ANTHROPIC_API_KEY", -- 環境変数から読み込む
          },
        })
      end,
    },
    strategies = {
      chat = { adapter = "anthropic" },
      inline = { adapter = "anthropic" },
    },
  },
  keys = {
    { "<Leader>ac", "<cmd>CodeCompanionChat Toggle<CR>",  desc = "CodeCompanion Chat" },
    { "<Leader>aa", "<cmd>CodeCompanionActions<CR>",      desc = "CodeCompanion Actions" },
    { "<Leader>ai", "<cmd>CodeCompanion<CR>",             desc = "CodeCompanion Inline" },
  },
}
