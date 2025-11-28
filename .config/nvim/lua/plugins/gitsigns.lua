return  {
  "lewis6991/gitsigns.nvim",
  config = function()
    require("gitsigns").setup({
      signs = {
        add          = { text = '│' },
        change       = { text = '│' },
        delete       = { text = '_' },
        topdelete    = { text = '‾' },
        changedelete = { text = '~' },
        untracked    = { text = '┆' },
      },
      signcolumn = true,
      numhl      = false,
      linehl     = false,
      word_diff  = false,
      watch_gitdir = {
        interval = 1000,
        follow_files = true
      },
      attach_to_untracked = true,
      current_line_blame = false,
      current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = 'eol',
        delay = 1000,
        ignore_whitespace = false,
      },
      current_line_blame_formatter = '<author>, <author_time:%Y-%m-%d> - <summary>',
      sign_priority = 6,
      update_debounce = 100,
      status_formatter = nil,
      max_file_length = 40000,
      preview_config = {
        border = 'single',
        style = 'minimal',
        relative = 'cursor',
        row = 0,
        col = 1
      },
    })

    -- 新しいハイライト指定 (公式推奨)
    vim.api.nvim_set_hl(0, 'GitSignsAdd', { link = 'DiffAdd' })
    vim.api.nvim_set_hl(0, 'GitSignsChange', { link = 'DiffChange' })
    vim.api.nvim_set_hl(0, 'GitSignsDelete', { link = 'DiffDelete' })
    vim.api.nvim_set_hl(0, 'GitSignsTopdelete', { link = 'GitSignsDelete' })
    vim.api.nvim_set_hl(0, 'GitSignsChangedelete', { link = 'GitSignsChange' })
    vim.api.nvim_set_hl(0, 'GitSignsUntracked', { link = 'GitSignsAdd' })
  end
}

