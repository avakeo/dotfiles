require("lazy").setup("plugins",

{

	ui = {

		icons = {

			cmd = "⌘",

			config = "🛠",

			event = "📅",

			ft = "📂",

			init = "⚙",

			keys = "🗝",

			plugin = "🔌",

			runtime = "💻",

			require = "🌙",

			source = "📄",

			start = "🚀",

			task = "📌",

			lazy = "💤 ",

		},

	},

	checker = {

		enabled = true, -- プラグインのアップデートを自動的にチェック

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
