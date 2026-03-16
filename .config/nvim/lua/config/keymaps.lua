local map = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }

-- 編集
map("i", "jj", "<Esc>", opts)

-- j/k を視覚行移動に (折り返し行も自然に移動)
map("n", "j", "gj", opts)
map("n", "k", "gk", opts)

-- 検索ハイライトを消去
map("n", "<Esc><Esc>", ":nohlsearch<CR>", opts)

-- 診断エラー移動 (vim の [d/]d と統一)
map("n", "[d", "<cmd>lua vim.diagnostic.goto_prev()<CR>", opts)
map("n", "]d", "<cmd>lua vim.diagnostic.goto_next()<CR>", opts)

-- 相対行番号トグル
map("n", "<F3>", ":setlocal relativenumber!<CR>", opts)

-- ターミナル起動
map("n", "tt", "<cmd>tabnew<CR><cmd>terminal<CR>", { silent = true })
map("n", "tx", "<cmd>belowright 10new<CR><cmd>terminal<CR>", { silent = true })

-- ターミナルモード: ウィンドウ操作を通常モード経由で行う
map("t", "<C-w>",  "<C-\\><C-n><C-w>",   opts)
map("t", "<C-w>h", "<C-\\><C-n><C-w>h",  opts)
map("t", "<C-w>l", "<C-\\><C-n><C-w>l",  opts)
map("t", "<C-w>j", "<C-\\><C-n><C-w>j",  opts)
map("t", "<C-w>k", "<C-\\><C-n><C-w>k",  opts)
map("t", "<C-w>t", "<C-\\><C-n><C-w>t",  opts)
map("t", "<C-w>b", "<C-\\><C-n><C-w>b",  opts)
map("t", "<C-w>w", "<C-\\><C-n><C-w>w",  opts)
map("t", "<C-w>W", "<C-\\><C-n><C-w>W",  opts)
map("t", "<C-w>p", "<C-\\><C-n><C-w>p",  opts)

-- ターミナルを開いたら自動でインサートモード & 行番号非表示
vim.api.nvim_create_autocmd("TermOpen", {
  pattern = "*",
  callback = function()
    vim.cmd("startinsert")
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    map("t", "<Esc>", "<C-\\><C-n>:q!<CR>", opts)
  end,
})

-- ===== 画面分割 (WezTerm の Leader+v / Leader+s と統一) =====
map("n", "<Leader>v", ":vsplit<CR>", opts)   -- 左右に分割
map("n", "<Leader>s", ":split<CR>",  opts)   -- 上下に分割
map("n", "<Leader>x", ":close<CR>",  opts)   -- 分割を閉じる

-- ウィンドウ移動 (WezTerm の Ctrl+hjkl と統一)
map("n", "<C-h>", "<C-w>h", opts)
map("n", "<C-j>", "<C-w>j", opts)
map("n", "<C-k>", "<C-w>k", opts)
map("n", "<C-l>", "<C-w>l", opts)

-- ウィンドウリサイズ (WezTerm の Leader+<>/+/_ と統一)
map("n", "<Leader><", ":vertical resize -5<CR>", opts)
map("n", "<Leader>>", ":vertical resize +5<CR>", opts)
map("n", "<Leader>+", ":resize +5<CR>",          opts)
map("n", "<Leader>_", ":resize -5<CR>",          opts)

-- bufferline タブ切り替え
map("n", "gt", ":BufferLineCycleNext<CR>", opts)
map("n", "gT", ":BufferLineCyclePrev<CR>", opts)

-- LSP: バッファにアタッチされたときのキーマップ
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local bufopts = { noremap = true, silent = true, buffer = args.buf }
    vim.keymap.set("n", "gd",         vim.lsp.buf.definition,   bufopts)
    vim.keymap.set("n", "gD",         vim.lsp.buf.declaration,  bufopts)
    vim.keymap.set("n", "gr",         vim.lsp.buf.references,   bufopts)
    vim.keymap.set("n", "K",          vim.lsp.buf.hover,        bufopts)
    vim.keymap.set("n", "<Leader>rn", vim.lsp.buf.rename,       bufopts)
    vim.keymap.set("n", "<Leader>ca", vim.lsp.buf.code_action,  bufopts)
    vim.keymap.set("n", "<Leader>f",  function() vim.lsp.buf.format({ async = true }) end, bufopts)
  end,
})
