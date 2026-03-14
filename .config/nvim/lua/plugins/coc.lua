return {
  "neoclide/coc.nvim",
  branch = "release",
  init = function()
    vim.g.coc_global_extensions = {
      "coc-json",
      "coc-tsserver",
      "coc-html",
      "coc-css",
      "coc-pyright",
    }
  end,
}
