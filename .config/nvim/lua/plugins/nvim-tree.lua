-- netrw を無効化 (nvim-tree 推奨設定)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

return {
  "nvim-tree/nvim-tree.lua",
  lazy = false,
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

    -- ディレクトリを引数に起動したとき netrw の代わりに nvim-tree を開く
    local function open_nvim_tree(data)
      if vim.fn.isdirectory(data.file) == 1 then
        vim.cmd.cd(data.file)
        require("nvim-tree.api").tree.open()
      end
    end
    vim.api.nvim_create_autocmd("VimEnter", { callback = open_nvim_tree })
  end,
}
