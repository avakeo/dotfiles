-- init.lua
vim.loader.enable()
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)


vim.api.nvim_set_keymap('n', '<Leader>t', ':NvimTreeToggle<CR>', { noremap = true, silent = true })

-- require("core.nvim_config")
--
require("config.lazy")
require("config.preference")
require("config.keymaps")

--[[
require("mason").setup() -- mason.nvimの初期化
require("mason-lspconfig").setup {
    ensure_installed = { "lua_ls", "rust_analyzer" }, -- 必要なサーバーを指定
    automatic_installation = true, -- 必要なサーバーが自動インストールされる
}
]]


-- Coc の基本設定
--[[
vim.cmd([[
  " 自動補完を有効化
  set completeopt=menuone,noinsert,noselect

  " Coc 設定ファイルを使用
  let g:coc_global_extensions = [
    \ 'coc-json',
    \ 'coc-tsserver',
    \ 'coc-html',
    \ 'coc-css',
    \ 'coc-pyright'
  ]
])
]]

vim.g.coc_global_extensions = {
  'coc-json',
  'coc-tsserver',
  'coc-html',
  'coc-css',
  'coc-pyright',
}

-- フォント設定
vim.opt.guifont = "Cica"  -- "Monaco" フォント、サイズ 14

vim.opt.termguicolors = true

