return {
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      require("copilot").setup({
        suggestion = { enabled = false }, -- cmp 経由で使うので無効化
        panel = { enabled = false },
      })
    end,
  },
  {
    "zbirenbaum/copilot-cmp",
    dependencies = { "zbirenbaum/copilot.lua" },
    config = function()
      require("copilot_cmp").setup()
    end,
  },
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    dependencies = { "zbirenbaum/copilot.lua" },
    build = "make tiktoken",
    opts = {
      model = "claude-3.7-sonnet", -- GPT-4o や claude-3.7-sonnet 等から選択可
      window = {
        layout = "vertical",       -- 右側にチャットウィンドウ
        width = 0.35,
      },
    },
    keys = {
      { "<Leader>cc", "<cmd>CopilotChatToggle<CR>",  desc = "Copilot Chat 開閉" },
      { "<Leader>ce", "<cmd>CopilotChatExplain<CR>",  mode = "v", desc = "コード説明" },
      { "<Leader>cf", "<cmd>CopilotChatFix<CR>",      mode = "v", desc = "バグ修正提案" },
      { "<Leader>cr", "<cmd>CopilotChatReview<CR>",   mode = "v", desc = "コードレビュー" },
      { "<Leader>co", "<cmd>CopilotChatOptimize<CR>", mode = "v", desc = "最適化提案" },
      { "<Leader>ct", "<cmd>CopilotChatTests<CR>",    mode = "v", desc = "テスト生成" },
    },
  },
}
