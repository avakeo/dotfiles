return {
  "folke/noice.nvim",
  event = "VeryLazy",
  opts = {
    message = {
      view = "notify",
      timeout = 700,
    },
  },
  dependencies = {
    "MunifTanjim/nui.nvim",
    {
      "rcarriga/nvim-notify",
      -- 透過テーマで NotifyBackground に背景色が無いと毎回警告が出るので明示する
      opts = {
        background_colour = "#000000",
        -- yazi.nvim などのフロート (zindex 50) より手前に通知を出す
        on_open = function(win)
          vim.api.nvim_win_set_config(win, { zindex = 100 })
        end,
      },
    },
  },
}
