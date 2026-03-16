return {
  "nvim-tree/nvim-tree.lua",
  keys = {
    { "<C-n>",    "<cmd>NvimTreeFocus<CR>",  desc = "NvimTree Focus" },
    { "<Leader>t", "<cmd>NvimTreeToggle<CR>", desc = "NvimTree Toggle" },
  },
  config = function()
    require("nvim-tree").setup({
      renderer = {
        group_empty = true,
      },
      view = {
        -- 画面幅に応じてサイドバー幅をレスポンシブに調整
        width = function()
          local w = vim.o.columns
          if w < 75 then
            return w
          elseif w < 120 then
            return math.floor(w * 0.25)
          else
            return math.floor(w * 0.1)
          end
        end,
        side = "left",
      },
      actions = {
        open_file = {
          quit_on_open = false,
        },
      },
    })
  end,
}
