return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-web-devicons" },
  event = "VimEnter",
  config = function()
    require("lualine").setup({
      options = {
        component_separators = { left = "", right = "" },
        section_separators = { left = "", right = "" },
        theme = "horizon",
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = { "filename", "branch" },
        lualine_c = {
          {
            "diff",
            symbols = { added = " ", modified = " ", removed = " " },
            separator = "  |  ",
          },
          {
            "diagnostics",
            symbols = { error = " ", warn = " ", info = " ", hint = " " },
          },
        },
        lualine_x = { { "encoding", "fileformat" }, { "filetype", "searchcount" } },
        lualine_y = { "location" },
        lualine_z = { os.date("%H:%M") },
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = {},
        lualine_x = {},
        lualine_y = {},
        lualine_z = {},
      },
    })
  end,
}
