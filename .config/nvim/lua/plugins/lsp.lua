return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
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
