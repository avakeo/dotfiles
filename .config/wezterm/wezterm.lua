local wezterm = require("wezterm")

local config = {}

if wezterm.config_builder then
	config = wezterm.config_builder()
end

-- カラースキームの設定
-- config.color_scheme = "Vs Code Dark+ (Gogh)"
-- config.color_scheme = 'Aco (Gogh)'
-- config.color_scheme = 'Afterglow (Gogh)'
config.color_scheme = 'Argonaut (Gogh)'


-- フォントの設定（Cicaを使う場合）
config.font = wezterm.font("Cica")
config.font_size = 14.0

-- 背景の透明度を少し設定
config.window_background_opacity = 0.9

local mux = wezterm.mux
wezterm.on("gui-startup", function(cmd)
	local tab, pane, window = mux.spawn_window(cmd or {})
	window:gui_window():toggle_fullscreen()
end)

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
	-- Ctrl+W でタブを閉じる
	{
		key = "w",
		mods = "CTRL",
		-- action = wezterm.action.CloseCurrentTab({ confirm = false }),
		-- action = wezterm.action.CloseCurrentTab({ confirm = true }),
		-- action = wezterm.action{CloseCurrentPane={confirm=false},
		action = wezterm.action.CloseCurrentPane({confirm=false}),
	},
	-- Ctrl+T で新しいタブを作成
	{
		key = "t",
		mods = "CTRL",
		action = wezterm.action.SpawnTab("CurrentPaneDomain"),
	},
}

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)

   local background = "#5c6d74"
   -- local background = "#00c7db"

   local foreground = "#FFFFFF"


   if tab.is_active then

     -- background = "#ae8b2d"
     background = "#00b5c7"
     -- background = "#00909e"

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
