-- lua/plugins/lualine.lua

return {
  'nvim-lualine/lualine.nvim',
  dependencies = { 'nvim-web-devicons' },
  event = 'VimEnter',
  config = function()
    local lualine = require('lualine')
    local config = {
      options = {
        component_separators = { left = '', right = '' },
        section_separators = { left = '', right = '' },
        -- theme = 'tokyonight',  -- テーマの指定
        theme = 'horizon',  -- テーマの指定
      },
      sections = {
        lualine_a = {'mode'},  -- ファイル名
        lualine_b = {'filename', 'branch'},  -- Gitブランチ
        -- lualine_a = {'filename'},  -- ファイル名
        -- lualine_b = {'branch'},  -- Gitブランチ
        lualine_c = {
          {
            'diff',
            symbols = {added = ' ', modified = ' ', removed = ' '},
            separator = "  |  ",
          },
          {
            'diagnostics',
            symbols = {error = ' ', warn = ' ', info = ' ', hint = ' '},
          },
        },
        lualine_x = {{'encoding', 'fileformat'}, {'filetype', 'searchcount'}},  -- エンコーディングやファイル形式
        -- lualine_y = {'filetype', 'searchcount'},  -- ファイルタイプや検索結果数
        lualine_y = {'location'},  -- 行番号と列番号
        lualine_z = {os.date("%H:%M")},  -- 行番号と列番号
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = {},
        lualine_x = {},
        lualine_y = {},
        lualine_z = {},
      },
    }
    lualine.setup(config)
  end
}

