
vim.api.nvim_set_keymap("n", "<F3>", ":setlocal relativenumber!<CR>", { noremap = true, silent = true })

vim.api.nvim_set_keymap("i", "jj", "<Esc>", { noremap = true, silent = true })

vim.api.nvim_set_keymap("n", "tt", "<cmd>tabnew<CR><cmd>terminal<CR>", { silent = true })
vim.api.nvim_set_keymap("n", "tx", "<cmd>belowright 10new<CR><cmd>terminal<CR>", { silent = true })



-- terminal mode -- 
-- ターミナルモードで Ctrl+w を通常モードの Ctrl+w に変換
vim.api.nvim_set_keymap("t", "<C-w>", "<C-\\><C-n><C-w>", { noremap = true, silent = true })

-- ウィンドウ移動系
vim.api.nvim_set_keymap("t", "<C-w>h", "<C-\\><C-n><C-w>h", { noremap = true, silent = true })
vim.api.nvim_set_keymap("t", "<C-w>l", "<C-\\><C-n><C-w>l", { noremap = true, silent = true })
vim.api.nvim_set_keymap("t", "<C-w>j", "<C-\\><C-n><C-w>j", { noremap = true, silent = true })
vim.api.nvim_set_keymap("t", "<C-w>k", "<C-\\><C-n><C-w>k", { noremap = true, silent = true })
-- 画面の最上部・最下部へ移動
vim.api.nvim_set_keymap("t", "<C-w>t", "<C-\\><C-n><C-w>t", { noremap = true, silent = true })
vim.api.nvim_set_keymap("t", "<C-w>b", "<C-\\><C-n><C-w>b", { noremap = true, silent = true })
-- ウィンドウ切り替え
vim.api.nvim_set_keymap("t", "<C-w>w", "<C-\\><C-n><C-w>w", { noremap = true, silent = true })
vim.api.nvim_set_keymap("t", "<C-w>W", "<C-\\><C-n><C-w>W", { noremap = true, silent = true })
vim.api.nvim_set_keymap("t", "<C-w>p", "<C-\\><C-n><C-w>p", { noremap = true, silent = true })



vim.api.nvim_create_autocmd("TermOpen", {
  pattern = "*",
  callback = function()
    vim.cmd("startinsert")
    -- vim.cmd("belowright 35split")
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.api.nvim_set_keymap("t", "<Esc>", "<C-\\><C-n>:q!<CR>", { noremap = true, silent = true })
  end,
})


vim.api.nvim_set_keymap('n', 'gt', ':BufferLineCycleNext<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'gT', ':BufferLineCyclePrev<CR>', { noremap = true, silent = true })


-- vim.api.nvim_set_keymap("n", "<C-n>", "<cmd>NvimTreeToggle<CR>")
-- vim.api.nvim_set_keymap("n", "<C-n>", "<cmd>NvimTreeToggle<CR>", { noremap = true, silent = true })


vim.api.nvim_set_keymap("n", "<C-n>", [[<cmd>lua require("nvim-tree.api").tree.focus()<CR>]], { noremap = true, silent = true })



local opts = {silent = true, noremap = true, expr = true, replace_keycodes = false}

vim.keymap.set("i", "<TAB>", 'coc#pum#visible() ? coc#pum#next(1) : "<Tab>"', opts)

vim.keymap.set("i", "<S-TAB>", [[coc#pum#visible() ? coc#pum#prev(1) : "<C-h>"]], opts)

vim.api.nvim_set_keymap("i", "<CR>", 'coc#pum#visible() ? coc#pum#confirm() : "<CR>"', {
  noremap = true,
  silent = true,
  expr = true
})
vim.api.nvim_set_keymap("n", "<C-n>", [[<cmd>lua require("nvim-tree.api").tree.focus()<CR>]], { noremap = true, silent = true })



--[[
local on_attach = function(_, bufnr)
  local { noremap = true, silent = true } = { noremap = true, silent = true, buffer = bufnr }
  -- 定義へジャンプ
  vim.keymap.set("n", "gd", vim.lsp.buf.definition, { noremap = true, silent = true })
  -- 宣言へジャンプ
  vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { noremap = true, silent = true })
  -- 参照を表示
  vim.keymap.set("n", "gr", vim.lsp.buf.references, { noremap = true, silent = true })
  -- ホバードキュメント
  vim.keymap.set("n", "K", vim.lsp.buf.hover, { noremap = true, silent = true })
  -- その他自由に追加
end

]]
