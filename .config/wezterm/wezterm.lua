local wezterm = require("wezterm")

local config = {}
if wezterm.config_builder then
	config = wezterm.config_builder()
end

-- カラースキーム・フォント
config.color_scheme = "Argonaut (Gogh)"
config.font = wezterm.font("Cica")
config.font_size = 14.0

-- 背景透明度
config.window_background_opacity = 0.9

-- デフォルトシェル
local target = wezterm.target_triple

if target:find("windows") then
	if os.getenv("WEZTERM_EXECUTING_IN_WSL") == "1" or os.getenv("WSL_DISTRO_NAME") then
		if wezterm.shell_exists("/usr/bin/zsh") then
			config.default_prog = { "/usr/bin/zsh" }
		else
			config.default_prog = { "/usr/bin/bash" }
		end
	else
		config.default_prog = { "C:\\Windows\\System32\\wsl.exe", "-d", "Ubuntu-24.04" }
	end
elseif target:find("linux") then
	if wezterm.shell_exists("/usr/bin/zsh") then
		config.default_prog = { "/usr/bin/zsh" }
	else
		config.default_prog = { "/usr/bin/bash" }
	end
else
	-- macOS
	config.default_prog = { "/bin/zsh" }
end

-- 起動時にウィンドウを生成
wezterm.on("gui-startup", function(cmd)
	mux.spawn_window(cmd or {})
end)

-- キーバインド
config.keys = {
	-- ペイン分割
	{
		key = "v",
		mods = "CTRL|ALT",
		action = wezterm.action.SplitVertical { domain = "CurrentPaneDomain" },
	},
	{
		key = "s",
		mods = "CTRL|ALT",
		action = wezterm.action.SplitHorizontal { domain = "CurrentPaneDomain" },
	},

	-- ペイン移動
	{
		key = "h",
		mods = "CTRL",
		action = wezterm.action.ActivatePaneDirection("Left"),
	},
	{
		key = "j",
		mods = "CTRL",
		action = wezterm.action.ActivatePaneDirection("Down"),
	},
	{
		key = "k",
		mods = "CTRL",
		action = wezterm.action.ActivatePaneDirection("Up"),
	},
	{
		key = "l",
		mods = "CTRL",
		action = wezterm.action.ActivatePaneDirection("Right"),
	},

	-- 単語単位のカーソル移動
	{
		key = "LeftArrow",
		mods = "CTRL",
		action = wezterm.action.SendKey { key = "b", mods = "META" },
	},
	{
		key = "RightArrow",
		mods = "CTRL",
		action = wezterm.action.SendKey { key = "f", mods = "META" },
	},

	-- 単語削除
	{
		key = "Backspace",
		mods = "CTRL",
		action = wezterm.action.SendKey { key = "w", mods = "CTRL" },
	},

	-- 新規タブ
	{
		key = "t",
		mods = "CTRL",
		action = wezterm.action.SpawnTab("CurrentPaneDomain"),
	},
}

-- タブタイトルのフォーマット
wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
	local bg = tab.is_active and "#00b5c7" or "#5c6d74"
	local title = "   " .. wezterm.truncate_right(tab.active_pane.title, max_width - 1) .. "   "

	return {
		{ Background = { Color = bg } },
		{ Foreground = { Color = "#FFFFFF" } },
		{ Text = title },
	}
end)

return config
