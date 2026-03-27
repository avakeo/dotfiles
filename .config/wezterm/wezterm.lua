local wezterm = require("wezterm")
local act = wezterm.action

local config = {}
if wezterm.config_builder then
	config = wezterm.config_builder()
end

-- ===== 外観 =====
config.color_scheme = "Pop Candy"
config.font = wezterm.font("Cica", { weight = "Medium" })
config.font_size = 14.0
config.window_background_opacity = 0.75
config.window_decorations = "RESIZE"

-- ===== ペイン境界 =====
-- 境界線の色を目立たせる (Pop Candy に合わせたアクセントカラー)
config.colors = {
	split = "#FF6B6B",
}

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
--    r  → リサイズモード (hjkl連打でリサイズ、Escで抜ける)
--    o  → 透明度モード   (k/l=上げる j/h=下げる、Escで抜ける)
--    f  → フォントサイズモード (k=大きく j=小さく 0=リセット、Escで抜ける)
--    [  → コピーモード (vim風: hjkl移動, v選択, y コピー, Escで抜ける)
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

	-- ===== リサイズモード (Leader + r → hjkl連打) =====
	{
		key = "r", mods = "LEADER",
		action = act.ActivateKeyTable { name = "resize_pane", one_shot = false },
	},

	-- ===== 透明度モード (Leader + o → hjkl連打) =====
	{
		key = "o", mods = "LEADER",
		action = act.ActivateKeyTable { name = "adjust_opacity", one_shot = false },
	},

	-- ===== フォントサイズモード (Leader + f → jk連打) =====
	{
		key = "f", mods = "LEADER",
		action = act.ActivateKeyTable { name = "adjust_font", one_shot = false },
	},

	-- ===== コピーモード (Leader + [) =====
	{
		key = "[", mods = "LEADER",
		action = act.ActivateCopyMode,
	},

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

-- ===== キーテーブル (モード) =====
config.key_tables = {
	resize_pane = {
		{ key = "h", action = act.AdjustPaneSize { "Left",  10 } },
		{ key = "j", action = act.AdjustPaneSize { "Down",  10 } },
		{ key = "k", action = act.AdjustPaneSize { "Up",    10 } },
		{ key = "l", action = act.AdjustPaneSize { "Right", 10 } },
		{ key = "Escape", action = "PopKeyTable" },
		{ key = "q",      action = "PopKeyTable" },
	},
	adjust_opacity = {
		{
			key = "k",
			action = wezterm.action_callback(function(window, _)
				local overrides = window:get_config_overrides() or {}
				local opacity = overrides.window_background_opacity or 0.75
				overrides.window_background_opacity = math.min(opacity + 0.15, 1.0)
				window:set_config_overrides(overrides)
			end),
		},
		{
			key = "j",
			action = wezterm.action_callback(function(window, _)
				local overrides = window:get_config_overrides() or {}
				local opacity = overrides.window_background_opacity or 0.75
				overrides.window_background_opacity = math.max(opacity - 0.15, 0.1)
				window:set_config_overrides(overrides)
			end),
		},
		{ key = "Escape", action = "PopKeyTable" },
		{ key = "q",      action = "PopKeyTable" },
	},
	adjust_font = {
		{
			key = "k",
			action = wezterm.action_callback(function(window, _)
				local overrides = window:get_config_overrides() or {}
				local size = overrides.font_size or 14.0
				overrides.font_size = size + 1.0
				window:set_config_overrides(overrides)
			end),
		},
		{
			key = "j",
			action = wezterm.action_callback(function(window, _)
				local overrides = window:get_config_overrides() or {}
				local size = overrides.font_size or 14.0
				overrides.font_size = math.max(size - 1.0, 6.0)
				window:set_config_overrides(overrides)
			end),
		},
		{
			key = "0",
			action = wezterm.action_callback(function(window, _)
				local overrides = window:get_config_overrides() or {}
				overrides.font_size = nil
				window:set_config_overrides(overrides)
			end),
		},
		{ key = "Escape", action = "PopKeyTable" },
		{ key = "q",      action = "PopKeyTable" },
	},
}

-- ===== モード表示 (タブバー右側) =====
local mode_info = {
	resize_pane    = { label = "RESIZE",  hints = {
		{ key = "h/j/k/l", desc = "resize" }, { key = "Esc", desc = "quit" },
	}},
	adjust_opacity = { label = "OPACITY", hints = {
		{ key = "j", desc = "down" }, { key = "k", desc = "up" }, { key = "Esc", desc = "quit" },
	}},
	adjust_font    = { label = "FONT",    hints = {
		{ key = "j", desc = "smaller" }, { key = "k", desc = "bigger" }, { key = "0", desc = "reset" }, { key = "Esc", desc = "quit" },
	}},
	copy_mode      = { label = "COPY",    hints = {
		{ key = "hjkl", desc = "move" }, { key = "v", desc = "select" }, { key = "y", desc = "yank" }, { key = "Esc", desc = "quit" },
	}},
	search_mode    = { label = "SEARCH",  hints = {
		{ key = "type", desc = "search" }, { key = "Esc", desc = "quit" },
	}},
}

local function format_hints(hints)
	local elements = {}
	for i, h in ipairs(hints) do
		if i > 1 then
			table.insert(elements, { Text = "  " })
		end
		table.insert(elements, { Foreground = { Color = "#FFFFFF" } })
		table.insert(elements, { Attribute = { Intensity = "Bold" } })
		table.insert(elements, { Text = h.key })
		table.insert(elements, { Attribute = { Intensity = "Normal" } })
		table.insert(elements, { Foreground = { Color = "#AAAAAA" } })
		table.insert(elements, { Text = ":" .. h.desc })
	end
	return elements
end

wezterm.on("update-right-status", function(window, _)
	local table_name = window:active_key_table()
	local info = mode_info[table_name]
	if info then
		local elements = format_hints(info.hints)
		table.insert(elements, { Text = "  " })
		table.insert(elements, { Background = { Color = "#FF6B6B" } })
		table.insert(elements, { Foreground = { Color = "#FFFFFF" } })
		table.insert(elements, { Attribute = { Intensity = "Bold" } })
		table.insert(elements, { Text = "  " .. info.label .. "  " })
		window:set_right_status(wezterm.format(elements))
	else
		window:set_right_status(wezterm.format({
			{ Foreground = { Color = "#FFFFFF" } },
			{ Attribute = { Intensity = "Bold" } },
			{ Text = "r" },
			{ Attribute = { Intensity = "Normal" } },
			{ Foreground = { Color = "#AAAAAA" } },
			{ Text = ":resize  " },
			{ Foreground = { Color = "#FFFFFF" } },
			{ Attribute = { Intensity = "Bold" } },
			{ Text = "o" },
			{ Attribute = { Intensity = "Normal" } },
			{ Foreground = { Color = "#AAAAAA" } },
			{ Text = ":opacity  " },
			{ Foreground = { Color = "#FFFFFF" } },
			{ Attribute = { Intensity = "Bold" } },
			{ Text = "f" },
			{ Attribute = { Intensity = "Normal" } },
			{ Foreground = { Color = "#AAAAAA" } },
			{ Text = ":font  " },
			{ Foreground = { Color = "#FFFFFF" } },
			{ Attribute = { Intensity = "Bold" } },
			{ Text = "[" },
			{ Attribute = { Intensity = "Normal" } },
			{ Foreground = { Color = "#AAAAAA" } },
			{ Text = ":copy  " },
			{ Background = { Color = "#FF6B6B" } },
			{ Foreground = { Color = "#FFFFFF" } },
			{ Attribute = { Intensity = "Bold" } },
			{ Text = "  NORMAL  " },
		}))
	end
end)

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
