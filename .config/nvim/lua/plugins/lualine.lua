return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-web-devicons" },
  event = "VimEnter",
  config = function()
    -- モード別カラー (bluloco テーマに合わせた配色)
    local mode_colors = {
      n  = "#569cd6", -- Normal  : 青
      i  = "#f44747", -- Insert  : 赤
      v  = "#ce9178", -- Visual  : オレンジ
      V  = "#ce9178", -- V-Line  : オレンジ
      ["\22"] = "#ce9178", -- V-Block: オレンジ
      c  = "#ff79c6", -- Command : ピンク
      R  = "#f44747", -- Replace : 赤
      s  = "#ce9178", -- Select  : オレンジ
      S  = "#ce9178", -- S-Line  : オレンジ
    }
    local function mode_color()
      return { bg = mode_colors[vim.fn.mode()] or "#569cd6", fg = "#1e1e1e", gui = "bold" }
    end

    require("lualine").setup({
      options = {
        component_separators = { left = "", right = "" },
        section_separators = { left = "", right = "" },
        theme = "horizon",
      },
      sections = {
        lualine_a = { { "mode", color = mode_color } },
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
