return {
  "akinsho/toggleterm.nvim",
  version = "*",
  cmd = { "ToggleTerm", "TermExec" },
  keys = { "tx", "<C-\\>", "<Leader>r" },
  opts = {
    size = 12,
    open_mapping = [[<C-\>]],
    direction = "float",
    float_opts = {
      border = "curved",
    },
    start_in_insert = true,
    persist_size = true,
    close_on_exit = true,
  },
  config = function(_, opts)
    require("toggleterm").setup(opts)

    local Terminal = require("toggleterm.terminal").Terminal

    vim.keymap.set("n", "tx", "<cmd>ToggleTerm<CR>", { silent = true, desc = "Toggle terminal" })
    vim.keymap.set("t", "tx", "<cmd>ToggleTerm<CR>", { silent = true, desc = "Toggle terminal" })

    -- アルゴリズム学習用: カレントファイルをさっと実行
    local runners = {
      python = "python3 %s",
      cpp = "g++ -std=c++17 -O2 -o /tmp/%s %s && /tmp/%s",
      c = "gcc -O2 -o /tmp/%s %s && /tmp/%s",
      rust = "rustc -O -o /tmp/%s %s && /tmp/%s",
      go = "go run %s",
      javascript = "node %s",
      typescript = "ts-node %s",
      lua = "lua %s",
    }

    local function run_current_file()
      local ft = vim.bo.filetype
      local cmd_tpl = runners[ft]
      if not cmd_tpl then
        vim.notify("toggleterm: '" .. ft .. "' の実行コマンドが未設定です", vim.log.levels.WARN)
        return
      end

      vim.cmd("write")
      local file = vim.fn.expand("%:p")
      local name = vim.fn.expand("%:t:r")

      local count = 0
      for _ in cmd_tpl:gmatch("%%s") do
        count = count + 1
      end
      local args = {}
      for _ = 1, count do
        table.insert(args, count == 3 and name or file)
      end
      local cmd = count == 3 and string.format(cmd_tpl, name, file, name) or string.format(cmd_tpl, file)

      Terminal:new({ cmd = cmd, direction = "float", close_on_exit = false }):toggle()
    end

    vim.keymap.set("n", "<Leader>r", run_current_file, { silent = true, desc = "Run current file" })
  end,
}
