require("lazy").setup("plugins", {
  ui = {
    icons = {
      cmd     = "⌘",
      config  = "🛠",
      event   = "📅",
      ft      = "📂",
      init    = "⚙",
      keys    = "🗝",
      plugin  = "🔌",
      runtime = "💻",
      require = "🌙",
      source  = "📄",
      start   = "🚀",
      task    = "📌",
      lazy    = "💤 ",
    },
  },
  checker = {
    enabled = true,
    -- 起動のたびに更新通知が出て yazi 等のポップアップと重なるので、確認は :Lazy で行う
    notify = false,
  },
  diff = {
    cmd = "delta",
  },
  rtp = {
    disabled_plugins = {
      "gzip",
      "matchit",
      "matchparen",
      "netrwPlugin",
      "tarPlugin",
      "tohtml",
      "tutor",
      "zipPlugin",
    },
  },
})
