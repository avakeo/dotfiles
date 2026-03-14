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
    "rcarriga/nvim-notify",
  },
}
