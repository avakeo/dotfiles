return {
  "uloco/bluloco.nvim",
  lazy = false,
  priority = 1000,
  dependencies = { "rktjmp/lush.nvim" },
  config = function()
    -- WezTerm の背景透過 (window_background_opacity) に合わせる
    require("bluloco").setup({
      transparent = true,
    })
  end,
}
