return {
  "OXY2DEV/markview.nvim",
  lazy = false, -- markview 自体が遅延読み込みするので lazy.nvim では遅らせない
  dependencies = { "nvim-tree/nvim-web-devicons" },
  opts = {
    preview = {
      enable = false, -- 普段は素の markdown で編集し、見たいときだけオンにする
      icon_provider = "devicons",
      modes = { "n", "no", "c" },
      hybrid_modes = { "n" }, -- カーソルがある部分だけ素の markdown に戻す
      linewise_hybrid_mode = true, -- 戻す範囲をカーソル行だけにする
    },
  },
  keys = {
    -- markdown プレビューのトグル (:Markview toggle と同じ)
    { "<Leader>md", "<Cmd>Markview toggle<CR>", desc = "Toggle Markdown Preview" },
  },
}
