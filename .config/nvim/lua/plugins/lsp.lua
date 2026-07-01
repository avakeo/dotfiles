return {
  {
    "neovim/nvim-lspconfig",
    event = "BufReadPre",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      vim.diagnostic.config({ virtual_text = false, signs = false, underline = true })

      -- 診断の下線を undercurl（波線）に変更（カラースキームの色を流用）
      local function set_diag_undercurl()
        for _, sev in ipairs({ "Error", "Warn", "Info", "Hint" }) do
          local src = vim.api.nvim_get_hl(0, { name = "Diagnostic" .. sev, link = false })
          vim.api.nvim_set_hl(0, "DiagnosticUnderline" .. sev, {
            undercurl = true,
            sp = src.fg and string.format("#%06x", src.fg) or nil,
          })
        end
      end
      vim.api.nvim_create_autocmd("ColorScheme", { callback = set_diag_undercurl })
      set_diag_undercurl()

      local diag_on = true
      vim.api.nvim_create_user_command("DiagToggle", function()
        diag_on = not diag_on
        vim.diagnostic.config({ virtual_text = false, signs = false, underline = diag_on })
        if diag_on then set_diag_undercurl() end
        vim.notify("Diagnostics " .. (diag_on and "ON" or "OFF"))
      end, {})
      vim.keymap.set("n", "<Leader>ud", "<Cmd>DiagToggle<CR>", { desc = "Toggle diagnostics" })

      require("mason").setup()

      local lspconfig = require("lspconfig")
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      require("mason-lspconfig").setup({
        ensure_installed = {
          "pyright",
          "ts_ls",
          "rust_analyzer",
          "jsonls",
          "yamlls",
          "html",
          "cssls",
          "lua_ls",
        },
        handlers = {
          -- デフォルト: 全サーバーに共通設定を適用
          function(server)
            lspconfig[server].setup({ capabilities = capabilities })
          end,
          -- lua_ls: vim グローバルを認識させる
          lua_ls = function()
            lspconfig.lua_ls.setup({
              capabilities = capabilities,
              settings = {
                Lua = {
                  diagnostics = { globals = { "vim" } },
                },
              },
            })
          end,
        },
      })
    end,
  },
}
