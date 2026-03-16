return {
  "akinsho/bufferline.nvim",
  event = "VeryLazy",
  version = "*",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    require("bufferline").setup({
      options = {
        numbers = "none",
        diagnostics = "nvim_lsp",
        show_buffer_icons = true,
      },
    })
  end,
}
