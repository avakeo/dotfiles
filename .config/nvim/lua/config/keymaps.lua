
vim.api.nvim_set_keymap("n", "<F3>", ":setlocal relativenumber!<CR>", { noremap = true, silent = true })

vim.api.nvim_set_keymap("i", "jj", "<Esc>", { noremap = true, silent = true })



vim.api.nvim_set_keymap('n', 'gt', ':BufferLineCycleNext<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'gT', ':BufferLineCyclePrev<CR>', { noremap = true, silent = true })


-- vim.api.nvim_set_keymap("n", "<C-n>", "<cmd>NvimTreeToggle<CR>")

-- vim.api.nvim_set_keymap("n", "<C-n>", "<cmd>NvimTreeToggle<CR>", { noremap = true, silent = true })


local opts = {silent = true, noremap = true, expr = true, 
  replace_keycodes = false}

  vim.keymap.set("i", "<TAB>", 'coc#pum#visible() ? coc#pum#next(1) : "<Tab>"', opts)

  vim.keymap.set("i", "<S-TAB>", [[coc#pum#visible() ? coc#pum#prev(1) : "<C-h>"]], opts)


vim.api.nvim_set_keymap("n", "<C-n>", [[<cmd>lua require("nvim-tree.api").tree.focus()<CR>]], { noremap = true, silent = true })

local on_attach = function(_, bufnr)
    local opts = { noremap = true, silent = true, buffer = bufnr }
    -- 定義へジャンプ
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    -- 宣言へジャンプ
    vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
    -- 参照を表示
    vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
    -- ホバードキュメント
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
    -- その他自由に追加
end

