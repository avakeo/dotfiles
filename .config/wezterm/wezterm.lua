--[[
local wezterm = require("wezterm")

local config = {}

if wezterm.config_builder then
	config = wezterm.config_builder()
end

-- カラースキームの設定
config.color_scheme = 'Argonaut (Gogh)'

-- フォントの設定（Cicaを使う場合）
config.font = wezterm.font("Cica")
config.font_size = 14.0

local target = wezterm.target_triple

if target:find("windows") then 
	if os.getenv("WEZTERM_EXECUTING_IN_WSL") == "1" or os.getenv("WSL_DISTRO_NAME") then
		if wezterm.shell_exists("usr/bin/zsh") then
			config.default_prog = {'/usr/bin/zsh'}
		else
			config.default_prog = {'/usr/bin/bash'}
		end
	else
		-- デフォルトのシェルをPowerShellに設定
		-- config.default_prog = {"C:\\Program Files\\PowerShell\\7\\pwsh.exe"}
        -- config.default_prog = {"wsl.exe", "-d", "Ubuntu-24.04"} 
        config.default_prog = { "C:\\Windows\\System32\\wsl.exe", "-d", "Ubuntu-24.04" }


	end
elseif target:find("linux") then
	if wezterm.shell_exists("usr/bin/zsh") then
		config.default_prog = {'/usr/bin/zsh'}
	else
		config.default_prog = {'/usr/bin/bash'}
	end
else
	config.default_prog = {'/usr/bin/bash'}
end
	
-- 背景の透明度を少し設定
config.window_background_opacity = 0.9

-- GUI起動時の設定
local mux = wezterm.mux
wezterm.on("gui-startup", function(cmd)
	local tab, pane, window = mux.spawn_window(cmd or {})
end)

-- key config
config.keys = {
	-- カーソルを一単語後ろに移動
	{
		key = "LeftArrow",
		mods = "CTRL",
		action = wezterm.action.SendKey({
			key = "b",
			mods = "META",
		}),
	},
	-- カーソルを一単語前に移動
	{
		key = "RightArrow",
		mods = "CTRL",
		action = wezterm.action.SendKey({
			key = "f",
			mods = "META",
		}),
	},
	-- カーソルを一単語削除
	{
		key = "Backspace",
		mods = "CTRL", -- mac用
		action = wezterm.action.SendKey({
			key = "w",
			mods = "CTRL",
		}),
	},
	-- Ctrl+T で新しいタブを作成
	{
		key = "t",
		mods = "CTRL",
		action = wezterm.action.SpawnTab("CurrentPaneDomain"),
	},
}

-- タブのタイトルのフォーマット
wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
	local background = "#5c6d74"
	local foreground = "#FFFFFF"

	if tab.is_active then
		background = "#00b5c7"
		foreground = "#FFFFFF"
	end

	local title = "   " .. wezterm.truncate_right(tab.active_pane.title, max_width - 1) .. "   "

	return {
		{ Background = { Color = background } },
		{ Foreground = { Color = foreground } },
		{ Text = title },
	}
end)

return config
]]

local wezterm = require("wezterm")



return {

      default_prog = { "cmd.exe", "/C", "wsl.exe -d Ubuntu-24.04" },

        font = wezterm.font("Cica"),

          font_size = 14.0,

}


