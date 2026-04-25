local map = vim.keymap.set

-- Insert mode
map("i", "jj", "<ESC>", { silent = true })

-- 折り返し行を自然に移動
map("n", "j", "gj")
map("n", "k", "gk")

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
map("t", "<C-h>", "<C-w>h")
map("t", "<C-j>", "<C-w>j")
map("t", "<C-k>", "<C-w>k")
map("t", "<C-l>", "<C-w>l")

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

-- トグルターミナル (tx): 同じセッションを下部に表示/非表示
local term_buf = 0

local function toggle_term()
  if term_buf > 0 and vim.fn.bufwinnr(term_buf) > 0 then
    local win = vim.fn.bufwinnr(term_buf)
    vim.cmd(win .. "wincmd w")
    vim.cmd("hide")
  elseif term_buf > 0 and vim.fn.bufexists(term_buf) == 1 then
    vim.cmd("botright new")
    vim.cmd("resize 12")
    vim.cmd("buffer " .. term_buf)
    vim.cmd("startinsert")
  else
    vim.cmd("botright new")
    vim.cmd("resize 12")
    vim.cmd("terminal")
    term_buf = vim.fn.bufnr("")
  end
end

map("n", "tx", toggle_term, { silent = true })
map("t", "tx", function()
  vim.cmd("stopinsert")
  toggle_term()
end, { silent = true })
