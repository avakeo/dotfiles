return {
  "folke/trouble.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    require("trouble").setup()
    vim.keymap.set("n", "<Leader>xx", "<cmd>Trouble diagnostics toggle<CR>",              { desc = "Diagnostics (all)" })
    vim.keymap.set("n", "<Leader>xb", "<cmd>Trouble diagnostics toggle filter.buf=0<CR>", { desc = "Diagnostics (buffer)" })
    vim.keymap.set("n", "<Leader>xl", "<cmd>Trouble loclist toggle<CR>",                  { desc = "Location list" })
    vim.keymap.set("n", "<Leader>xq", "<cmd>Trouble qflist toggle<CR>",                   { desc = "Quickfix list" })
  end,
}
