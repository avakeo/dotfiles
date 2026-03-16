local opt = vim.opt

opt.number = true
opt.title = true
opt.cmdheight = 1
opt.updatetime = 100
opt.textwidth = 0
opt.signcolumn = "auto"
opt.background = "dark"
opt.clipboard = { "unnamed", "unnamedplus" }

-- タブ
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.autoindent = true
opt.smartindent = true

-- 検索
opt.ignorecase = true
opt.smartcase = true
opt.incsearch = true
opt.wrapscan = true
opt.hlsearch = true
opt.inccommand = "split"

-- 表示
opt.showmatch = true
opt.matchtime = 1
opt.list = true
opt.listchars = { tab = "▸ ", trail = "·" }
opt.linebreak = true
opt.virtualedit = "onemore"
opt.display = "lastline"
opt.wrap = true
opt.visualbell = true
opt.laststatus = 2

-- ファイル
opt.fileencoding = "utf-8"
opt.fileformats = { "unix", "dos", "mac" }
opt.modifiable = true

-- その他
opt.mouse = "a"
opt.spelllang = "en_us"
opt.completeopt = { "menu", "menuone", "noselect" }
opt.timeout = true
opt.timeoutlen = 300
opt.ttimeoutlen = 1
opt.whichwrap = "b,s,h,l,[,],<,>,~"
opt.wildignore =
  ".git,.hg,.svn,*.pyc,*.o,*.out,*.jpg,*.jpeg,*.png,*.gif,*.zip,**/tmp/**,*.DS_Store,**/node_modules/**,**/bower_modules/**"
opt.helplang = { "ja", "en" }
opt.shadafile = "NONE"

-- undo の永続化
opt.undodir = vim.fn.stdpath("state")
opt.undofile = true

-- fillchars (eob: ファイル末尾の ~ を非表示, fold: fold行の埋め文字)
opt.fillchars = { fold = " ", eob = " " }

-- fold
opt.foldmethod = "expr"
opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
opt.foldenable = false
opt.foldlevel = 99

-- Windows: ターミナルを PowerShell に変更
if vim.fn.has("win32") == 1 then
  vim.opt.shell      = "pwsh.exe"
  vim.opt.shellcmdflag = "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command"
  vim.opt.shellxquote  = ""
  vim.opt.shellquote   = ""
  vim.opt.shellpipe    = "| Out-File -Encoding UTF8 %s"
  vim.opt.shellredir   = "| Out-File -Encoding UTF8 %s"
end

-- termguicolors / colorscheme
opt.termguicolors = true
vim.cmd("colorscheme bluloco")

-- ポップアップメニューの不要な項目を削除
vim.cmd.aunmenu({ "PopUp.How-to\\ disable\\ mouse" })
vim.cmd.aunmenu({ "PopUp.-1-" })

-- ヤンク時に範囲をハイライト
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    vim.highlight.on_yank({ higroup = "IncSearch", timeout = 200 })
  end,
})
