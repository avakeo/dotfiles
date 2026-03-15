local wezterm = require("wezterm")
local act = wezterm.action

local config = {}
if wezterm.config_builder then
	config = wezterm.config_builder()
end

-- ===== 外観 =====
config.color_scheme = "Argonaut (Gogh)"
config.font = wezterm.font("Cica")
config.font_size = 14.0
config.window_background_opacity = 0.9

-- ===== デフォルトシェル =====
local target = wezterm.target_triple

if target:find("windows") then
	if os.getenv("WEZTERM_EXECUTING_IN_WSL") == "1" or os.getenv("WSL_DISTRO_NAME") then
		config.default_prog = wezterm.shell_exists("/usr/bin/zsh")
			and { "/usr/bin/zsh" }
			or  { "/usr/bin/bash" }
	else
		config.default_prog = { "C:\\Windows\\System32\\wsl.exe", "-d", "Ubuntu-24.04" }
	end
elseif target:find("linux") then
	config.default_prog = wezterm.shell_exists("/usr/bin/zsh")
		and { "/usr/bin/zsh" }
		or  { "/usr/bin/bash" }
else
	-- macOS
	config.default_prog = { "/bin/zsh" }
end

-- ===== 起動時 =====
wezterm.on("gui-startup", function(cmd)
	wezterm.mux.spawn_window(cmd or {})
end)

-- ===== Leader キー =====
-- CTRL+Space をプレフィックスに。1秒以内に次のキーを押す
config.leader = { key = "Space", mods = "CTRL", timeout_milliseconds = 1000 }

-- ===== キーバインド =====
--
--  Leader (CTRL+Space) + ...
--    |  → 左右に分割
--    -  → 上下に分割
--    z  → ペインをズーム/解除
--    x  → ペインを閉じる
--    c  → 新規タブ
--    h/j/k/l → ペイン移動
--    <  → ペインを左へリサイズ
--    >  → ペインを右へリサイズ
--    +  → ペインを上へリサイズ
--    _  → ペインを下へリサイズ
--
--  CTRL + h/j/k/l → ペイン移動 (Leader なしで素早く移動)
--  CTRL + Tab     → 次のタブ
--  CTRL + t       → 新規タブ
--  CTRL + ←/→    → 単語単位で移動
--  CTRL + BS      → 単語削除
--
config.keys = {

	-- ===== ペイン分割 (Leader + 記号) =====
	{
		key = "|", mods = "LEADER|SHIFT",
		action = act.SplitHorizontal { domain = "CurrentPaneDomain" },
	},
	{
		key = "-", mods = "LEADER",
		action = act.SplitVertical { domain = "CurrentPaneDomain" },
	},

	-- ===== ペイン操作 (Leader) =====
	{
		key = "z", mods = "LEADER",
		action = act.TogglePaneZoomState,
	},
	{
		key = "x", mods = "LEADER",
		action = act.CloseCurrentPane { confirm = true },
	},

	-- ===== ペインリサイズ (Leader + 矢印記号) =====
	{ key = "<", mods = "LEADER|SHIFT", action = act.AdjustPaneSize { "Left",  5 } },
	{ key = ">", mods = "LEADER|SHIFT", action = act.AdjustPaneSize { "Right", 5 } },
	{ key = "+", mods = "LEADER|SHIFT", action = act.AdjustPaneSize { "Up",    5 } },
	{ key = "_", mods = "LEADER|SHIFT", action = act.AdjustPaneSize { "Down",  5 } },

	-- ===== ペイン移動 (Leader + hjkl) =====
	{ key = "h", mods = "LEADER", action = act.ActivatePaneDirection("Left")  },
	{ key = "j", mods = "LEADER", action = act.ActivatePaneDirection("Down")  },
	{ key = "k", mods = "LEADER", action = act.ActivatePaneDirection("Up")    },
	{ key = "l", mods = "LEADER", action = act.ActivatePaneDirection("Right") },

	-- ===== ペイン移動 (CTRL+hjkl: Leader なしで素早く) =====
	{ key = "h", mods = "CTRL", action = act.ActivatePaneDirection("Left")  },
	{ key = "j", mods = "CTRL", action = act.ActivatePaneDirection("Down")  },
	{ key = "k", mods = "CTRL", action = act.ActivatePaneDirection("Up")    },
	{ key = "l", mods = "CTRL", action = act.ActivatePaneDirection("Right") },

	-- ===== タブ =====
	{
		key = "c", mods = "LEADER",
		action = act.SpawnTab("CurrentPaneDomain"),
	},
	{
		key = "t", mods = "CTRL",
		action = act.SpawnTab("CurrentPaneDomain"),
	},
	{
		key = "Tab", mods = "CTRL",
		action = act.ActivateTabRelative(1),
	},
	{
		key = "Tab", mods = "CTRL|SHIFT",
		action = act.ActivateTabRelative(-1),
	},

	-- ===== 単語単位の移動・削除 =====
	{
		key = "LeftArrow", mods = "CTRL",
		action = act.SendKey { key = "b", mods = "META" },
	},
	{
		key = "RightArrow", mods = "CTRL",
		action = act.SendKey { key = "f", mods = "META" },
	},
	{
		key = "Backspace", mods = "CTRL",
		action = act.SendKey { key = "w", mods = "CTRL" },
	},
}

-- ===== タブタイトル =====
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
