-- lua/plugins/nvim-treesitter.lua
return {
    "nvim-treesitter/nvim-treesitter",
    opts = {
	ensure_instralled = {"lua", "typescript"},
	sync_install = true,
    },
}

