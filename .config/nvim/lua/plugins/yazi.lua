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
      -- WezTerm が先に消費する (CTRL+t: 新規タブ) ので無効化
      open_file_in_tab = false,
      -- cwd の変更は yazi 側の C で行う (下の nvim-cd)。デフォルトの <c-\> は WezTerm の Leader なので無効化
      change_working_directory = false,
    },
    -- yazi の keymap.toml で C を押すと送られるメッセージを nvim に転送する
    forwarded_dds_events = { "nvim-cd" },
  },
  init = function()
    -- open_for_directories を使うため netrw を読み込ませない
    vim.g.loaded_netrwPlugin = 1

    -- yazi で C を押したら、そのディレクトリを nvim の作業ディレクトリにする
    vim.api.nvim_create_autocmd("User", {
      pattern = "YaziDDSCustom",
      callback = function(ev)
        if ev.data.type ~= "nvim-cd" then return end
        local ok, dir = pcall(vim.json.decode, ev.data.raw_data)
        if ok and type(dir) == "string" and vim.fn.isdirectory(dir) == 1 then
          vim.cmd.cd(dir)
          vim.notify("cwd: " .. vim.fn.fnamemodify(dir, ":~"))
        end
      end,
    })

    -- ターミナルモードの tx (toggleterm) が yazi の t (新規タブ) を待たせるので、yazi 内では t をそのまま送る
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "yazi",
      callback = function(ev)
        vim.keymap.set("t", "t", "t", { buffer = ev.buf, nowait = true })
      end,
    })
  end,
}
