return {
  "dhruvasagar/vim-table-mode",
  ft = "markdown",
  init = function()
    vim.g.table_mode_corner = "|" -- 区切り行を |---|---| にする (既定の + は markdown の表にならない)
    vim.g.table_mode_map_prefix = "<Leader>T" -- 既定の <Leader>t は yazi と重なるので T にする
  end,
  config = function()
    -- markdown を開いたら table mode をオンにし、| を打つたびに列をそろえる
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "markdown",
      command = "silent TableModeEnable",
    })
    if vim.bo.filetype == "markdown" then
      vim.cmd("silent TableModeEnable")
    end
  end,
  keys = {
    { "<Leader>Tm", "<Cmd>TableModeToggle<CR>", ft = "markdown", desc = "Toggle Table Mode" },
  },
}
