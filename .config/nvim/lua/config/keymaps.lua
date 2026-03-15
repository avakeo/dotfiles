local map = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }

-- 編集
map("i", "jj", "<Esc>", opts)

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

-- bufferline タブ切り替え
map("n", "gt", ":BufferLineCycleNext<CR>", opts)
map("n", "gT", ":BufferLineCyclePrev<CR>", opts)

-- nvim-tree
map("n", "<C-n>",    [[<cmd>lua require("nvim-tree.api").tree.focus()<CR>]],  opts)
map("n", "<Leader>t", [[<cmd>lua require("nvim-tree.api").tree.toggle()<CR>]], opts)

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
