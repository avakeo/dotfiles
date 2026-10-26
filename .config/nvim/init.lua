vim.loader.enable()

-- Leader キーは lazy.nvim より前に設定する必要がある
vim.g.mapleader      = " "
vim.g.maplocalleader = " "

-- Python プロバイダは使わないので無効にする。有効のままだと .py を開くたびに
-- PATH 上の python を起動して pynvim を探し、python が壊れているとエラーになる
vim.g.loaded_python3_provider = 0

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("config.lazy")
require("config.preference")
pcall(require, "config.keymaps")
