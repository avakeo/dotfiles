local wezterm = require("wezterm")
local act = wezterm.action

local config = {}
if wezterm.config_builder then
	config = wezterm.config_builder()
end

-- ===== 外観 =====
config.color_scheme = "Pop Candy"
config.font = wezterm.font("Cica")
config.font_size = 14.0
config.window_background_opacity = 0.9

-- ===== デフォルトシェル =====
local function file_exists(path)
	local f = io.open(path, "r")
	if f then f:close() return true end
	return false
end

local target = wezterm.target_triple

if target:find("windows") then
	config.default_prog = { "C:\\Program Files\\PowerShell\\7\\pwsh.exe", "-NoLogo" }
	config.launch_menu = {
		{ label = "PowerShell 7",           args = { "C:\\Program Files\\PowerShell\\7\\pwsh.exe", "-NoLogo" } },
		{ label = "Windows PowerShell 5.1", args = { "C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe" } },
	}
elseif target:find("linux") then
	config.default_prog = file_exists("/usr/bin/zsh")
		and { "/usr/bin/zsh" }
		or  { "/usr/bin/bash" }
else
	-- macOS
	config.default_prog = { "/bin/zsh" }
end

-- ===== スマートナビゲーション (vim/nvim ↔ WezTerm ペイン) =====
-- vim/nvim が動いているときは CTRL+hjkl をそのまま渡し、
-- それ以外のときは WezTerm のペイン移動として扱う
local function is_vim(pane)
	local proc = pane:get_foreground_process_name()
	return proc:find("[nv]?vim") ~= nil
end

local function smart_move(direction)
	local keys = { Left = "h", Down = "j", Up = "k", Right = "l" }
	return wezterm.action_callback(function(window, pane)
		if is_vim(pane) then
			window:perform_action(act.SendKey({ key = keys[direction], mods = "CTRL" }), pane)
		else
			window:perform_action(act.ActivatePaneDirection(direction), pane)
		end
	end)
end

-- ===== Leader キー =====
-- CTRL+B をプレフィックスに。1秒以内に次のキーを押す
config.leader = { key = "b", mods = "CTRL", timeout_milliseconds = 1000 }

-- ===== キーバインド =====
--
--  Leader (CTRL+B) + ...
--    v  → 左右に分割
--    s  → 上下に分割
--    z  → ペインをズーム/解除
--    x  → ペインを閉じる
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

	-- ===== ペイン分割 (Leader + v/s) =====
	{
		key = "v", mods = "LEADER",
		action = act.SplitHorizontal { domain = "CurrentPaneDomain" },
	},
	{
		key = "s", mods = "LEADER",
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

	-- ===== ペイン移動 (CTRL+hjkl: vim/nvim 内はウィンドウ移動、それ以外はペイン移動) =====
	{ key = "h", mods = "CTRL", action = smart_move("Left")  },
	{ key = "j", mods = "CTRL", action = smart_move("Down")  },
	{ key = "k", mods = "CTRL", action = smart_move("Up")    },
	{ key = "l", mods = "CTRL", action = smart_move("Right") },

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
		key = "w", mods = "CTRL",
		action = act.CloseCurrentTab { confirm = true },
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
	local bg = tab.is_active and "#FF6B6B" or "#3D3E5C"
	local title = "   " .. wezterm.truncate_right(tab.active_pane.title, max_width - 1) .. "   "
	return {
		{ Background = { Color = bg } },
		{ Foreground = { Color = "#FFFFFF" } },
		{ Text = title },
	}
end)

return config
