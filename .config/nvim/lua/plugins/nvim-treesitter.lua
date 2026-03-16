return {
  "nvim-treesitter/nvim-treesitter",
  event = "BufReadPost",
  opts = {
    ensure_installed = { "lua", "typescript" },
    sync_install = false,
    highlight = { enable = true },
  },
}

