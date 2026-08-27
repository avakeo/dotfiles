return {
  "MeanderingProgrammer/render-markdown.nvim",
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  lazy = false,
  config = function()
    require("render-markdown").setup({
      file_types = { "markdown" },
    })

    -- markdown レンダリングのトグル
    vim.keymap.set("n", "<Leader>md", function()
      require("render-markdown").toggle()
    end, { noremap = true, silent = true, desc = "Toggle Markdown Render" })
  end,
}
