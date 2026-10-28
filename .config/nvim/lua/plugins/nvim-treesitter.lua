return {
  "nvim-treesitter/nvim-treesitter",
  event = "BufReadPost",
  opts = {
    ensure_installed = { "lua", "typescript", "markdown", "markdown_inline" },
    sync_install = false,
    highlight = { enable = true },
  },
}

