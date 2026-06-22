local map = vim.keymap.set

-- Insert mode
map("i", "jj", "<ESC>", { silent = true })

-- 折り返し行を自然に移動
map("n", "j", "gj")
map("n", "k", "gk")

-- バッファ切り替え (gt/gT でタブ移動と同じ感覚)
map("n", "gt", ":BufferLineCycleNext<CR>", { silent = true })
map("n", "gT", ":BufferLineCyclePrev<CR>", { silent = true })
map("n", "<Leader>q", ":bp | bd #<CR>",    { silent = true })

-- 検索ハイライト解除
map("n", "<Esc><Esc>", ":nohlsearch<CR>", { silent = true })

-- 画面分割
map("n", "<Leader>v", ":vsplit<CR>")
map("n", "<Leader>s", ":split<CR>")
map("n", "<Leader>x", ":close<CR>")

-- ウィンドウ移動 (WezTerm Ctrl+hjkl と統一)
map("n", "<C-h>", "<C-w>h")
map("n", "<C-j>", "<C-w>j")
map("n", "<C-k>", "<C-w>k")
map("n", "<C-l>", "<C-w>l")
map("t", "<C-h>", "<C-\\><C-n><C-w>h", { silent = true })
map("t", "<C-j>", "<C-\\><C-n><C-w>j", { silent = true })
map("t", "<C-k>", "<C-\\><C-n><C-w>k", { silent = true })
map("t", "<C-l>", "<C-\\><C-n><C-w>l", { silent = true })

-- ウィンドウリサイズ (Ctrl+矢印)
map("n", "<C-Left>",  ":vertical resize -5<CR>", { silent = true })
map("n", "<C-Right>", ":vertical resize +5<CR>", { silent = true })
map("n", "<C-Up>",    ":resize +5<CR>",           { silent = true })
map("n", "<C-Down>",  ":resize -5<CR>",           { silent = true })
map("t", "<C-Left>",  "<C-w>:vertical resize -5<CR>", { silent = true })
map("t", "<C-Right>", "<C-w>:vertical resize +5<CR>", { silent = true })
map("t", "<C-Up>",    "<C-w>:resize +5<CR>",          { silent = true })
map("t", "<C-Down>",  "<C-w>:resize -5<CR>",          { silent = true })

-- ターミナル: 新規タブで開く
map("n", "tt", ":tab terminal<CR>")

-- トグルターミナル (tx) とファイル実行 (<Leader>r) は toggleterm.nvim 側で定義 (plugins/toggleterm.lua)

-- ターミナル内: Esc でエディターに戻る（ターミナルは閉じない）
map("t", "<Esc>", "<C-\\><C-n><C-w>p", { silent = true })

-- ターミナルウィンドウにフォーカスが戻ったとき自動でinsertモードに
vim.api.nvim_create_autocmd("WinEnter", {
  pattern = "*",
  callback = function()
    if vim.bo.buftype == "terminal" then vim.cmd("startinsert") end
  end,
})
