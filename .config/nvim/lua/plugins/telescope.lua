return {
  "nvim-telescope/telescope.nvim",
  tag = "0.1.8",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    local builtin = require("telescope.builtin")
    -- ファイル検索
    vim.keymap.set("n", "<Leader>ff", builtin.find_files,  { desc = "Find files" })
    -- テキスト検索 (grep)
    vim.keymap.set("n", "<Leader>fg", builtin.live_grep,   { desc = "Live grep" })
    -- 開いているバッファ一覧
    vim.keymap.set("n", "<Leader>fb", builtin.buffers,     { desc = "Buffers" })
    -- ヘルプ検索
    vim.keymap.set("n", "<Leader>fh", builtin.help_tags,   { desc = "Help tags" })
    -- 最近開いたファイル
    vim.keymap.set("n", "<Leader>fr", builtin.oldfiles,    { desc = "Recent files" })
    -- カーソル下の単語を grep
    vim.keymap.set("n", "<Leader>fw", builtin.grep_string, { desc = "Grep word" })
  end,
}
