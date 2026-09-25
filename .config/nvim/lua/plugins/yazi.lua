return {
  "mikavilpas/yazi.nvim",
  version = "*",
  event = "VeryLazy",
  dependencies = { { "nvim-lua/plenary.nvim", lazy = true } },
  keys = {
    { "<Leader>t", "<cmd>Yazi<CR>",        mode = { "n", "v" }, desc = "Yazi (current file)" },
    { "<C-n>",     "<cmd>Yazi toggle<CR>", desc = "Yazi (resume last session)" },
  },
  opts = {
    -- nvim <dir> で起動したとき netrw の代わりに yazi を開く
    open_for_directories = true,
    keymaps = {
      -- WezTerm が先に消費する (CTRL+t: 新規タブ / CTRL+\: Leader) ので無効化
      open_file_in_tab = false,
      change_working_directory = false,
    },
  },
  init = function()
    -- open_for_directories を使うため netrw を読み込ませない
    vim.g.loaded_netrwPlugin = 1

    -- ターミナルモードの tx (toggleterm) が yazi の t (新規タブ) を待たせるので、yazi 内では t をそのまま送る
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "yazi",
      callback = function(ev)
        vim.keymap.set("t", "t", "t", { buffer = ev.buf, nowait = true })
      end,
    })
  end,
}
