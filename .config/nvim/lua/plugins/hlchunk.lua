return 
  {
    "shellRaining/hlchunk.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("hlchunk").setup({
        chunk = { enable = false },
        indent = { enable = true },
      })

      local indent_on = true
      vim.api.nvim_create_user_command("IndentToggle", function()
        indent_on = not indent_on
        vim.cmd(indent_on and "EnableHLIndent" or "DisableHLIndent")
        vim.notify("Indent highlight " .. (indent_on and "ON" or "OFF"))
      end, {})
      vim.keymap.set("n", "<Leader>ui", "<Cmd>IndentToggle<CR>", { desc = "Toggle indent highlight" })
    end
  }
