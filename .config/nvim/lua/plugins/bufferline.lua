return {
  -- bufferline.nvim 設定
  {
    'akinsho/bufferline.nvim',
    version = "*",
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      require("bufferline").setup({
        options = {
          numbers = "none",  -- バッファ番号を非表示
          diagnostics = "nvim_lsp",  -- LSP の診断を表示
          show_buffer_icons = true,  -- アイコンを表示
        },
      })
    end,
  },

  {
  "nvim-tree/nvim-tree.lua",
  config = function()
    require("nvim-tree").setup({
      -- view セクションの設定
      renderer = {
        -- グループ化や表示オプションを設定
        group_empty = true,
      },
      -- 画面取得 フル画面なら左4割 フル未満なら固定{}px
      view = {
        width = function()
            local width = vim.o.columns
            if width < 75 then
              return width
            elseif width < 120 then
              return math.floor(width * 0.25)
            else
              return math.floor(width * 0.1)
            end
        end,
        side = 'left',  -- 左側に配置
      },
      -- ファイル選択時にタブで開く
      actions = {
        open_file = {
          -- quit_on_open = true,  -- ファイルを開いた後も NvimTree を閉じない
          quit_on_open = function()
            if vim.o.columns < 75 then
              return false
            end
            return true
          end,
          focus_file = true, 
        },
      },
      -- キーマッピング設定
      actions = {
        open_file = {
          quit_on_open = false,  -- ファイルを開いた後に NvimTree を閉じない
        },
      },
    })
  end,
},

--[[
  -- nvim-tree 設定
  {
    "nvim-tree/nvim-tree.lua",
    config = function()
      require("nvim-tree").setup({
        view = {
          width = function()
            return math.floor(vim.o.columns * 0.25)
          end,  -- 左側の幅を設定
          side = 'left',  -- 左側に配置
          auto_resize = true,  -- 自動的にリサイズ
        },
        mappings = {
          list = {
            -- ファイル選択時にタブで開く
            { key = "<CR>", action = "edit", action_cb = function(node)
                vim.cmd("tabnew " .. node.absolute_path)  -- タブで開く
              end,
            },
          },
        },
      })
    end,
  },
  ]]
}

