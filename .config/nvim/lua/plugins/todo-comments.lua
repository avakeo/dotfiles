return {
  "folke/todo-comments.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    require("todo-comments").setup()
    -- Telescope で TODO 一覧を表示
    vim.keymap.set("n", "<Leader>ft", "<cmd>TodoTelescope<CR>", { desc = "Todo comments" })
    -- 前後の TODO へ移動
    vim.keymap.set("n", "]t", function() require("todo-comments").jump_next() end, { desc = "Next TODO" })
    vim.keymap.set("n", "[t", function() require("todo-comments").jump_prev() end, { desc = "Prev TODO" })
  end,
}
