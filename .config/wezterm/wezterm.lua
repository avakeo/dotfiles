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
config.use_fancy_tab_bar = false
config.show_new_tab_button_in_tab_bar = false

-- ===== ペイン境界 / タブバー色 =====
config.colors = {
	split = "#FF6B6B",
	tab_bar = {
		background = "#A0522D",       -- 空白部分（タブのない領域）
		active_tab = {
			bg_color = "#FF8C00",     -- アクティブタブ: 明るいオレンジで目立たせる
			fg_color = "#FFFFFF",
			intensity = "Bold",
		},
		inactive_tab = {
			bg_color = "#A0522D",     -- 非アクティブタブ: 背景と同化させて沈める
			fg_color = "#CCCCCC",
		},
		inactive_tab_hover = {
			bg_color = "#C46A28",
			fg_color = "#FFFFFF",
		},
		new_tab = {
			bg_color = "#A0522D",
			fg_color = "#CCCCCC",
		},
		new_tab_hover = {
			bg_color = "#C46A28",
			fg_color = "#FFFFFF",
		},
	},
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
	-- vim が t_ti/t_te で設定する UserVar を優先チェック
	-- (vim の :terminal 内では前景プロセスが pwsh/bash になるため)
	if pane:get_user_vars().IS_VIM == "true" then
		return true
	end
	-- フォールバック: プロセス名チェック (vim, nvim, /usr/bin/vim など)
	local proc = pane:get_foreground_process_name() or ""
	return proc:find("n?vim") ~= nil
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
--  CTRL + w       → ペインを閉じる (分割あり) / タブを閉じる (分割なし)
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
		action = wezterm.action_callback(function(window, pane)
			local tab = window:active_tab()
			if #tab:panes() > 1 then
				window:perform_action(act.CloseCurrentPane { confirm = true }, pane)
			else
				window:perform_action(act.CloseCurrentTab { confirm = true }, pane)
			end
		end),
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
			table.insert(elements, { Foreground = { Color = "#555555" } })
			table.insert(elements, { Text = " · " })
		end
		table.insert(elements, { Foreground = { Color = "#FFFFFF" } })
		table.insert(elements, { Attribute = { Intensity = "Bold" } })
		table.insert(elements, { Text = h.key })
		table.insert(elements, { Attribute = { Intensity = "Normal" } })
		table.insert(elements, { Foreground = { Color = "#888888" } })
		table.insert(elements, { Text = ":" .. h.desc })
	end
	return elements
end

-- Leader キーが押されたときに表示するヒント
local leader_hints = {
	{ key = "r", desc = "resize" },
	{ key = "o", desc = "opacity" },
	{ key = "f", desc = "font" },
	{ key = "[", desc = "copy" },
}

local function separator(elements)
	table.insert(elements, { Background = { Color = "#A0522D" } })
	table.insert(elements, { Foreground = { Color = "#E07B39" } })
	table.insert(elements, { Text = " ┃ " })
	table.insert(elements, { Background = { Color = "#A0522D" } })
end

wezterm.on("update-right-status", function(window, _)
	local table_name = window:active_key_table()
	local info = mode_info[table_name]

	if info then
		-- モード中: ヒント + モード名バッジ
		local elements = {}
		separator(elements)
		for _, e in ipairs(format_hints(info.hints)) do
			table.insert(elements, e)
		end
		table.insert(elements, { Text = " " })
		table.insert(elements, { Background = { Color = "#FF6B6B" } })
		table.insert(elements, { Foreground = { Color = "#FFFFFF" } })
		table.insert(elements, { Attribute = { Intensity = "Bold" } })
		table.insert(elements, { Text = " " .. info.label .. " " })
		window:set_right_status(wezterm.format(elements))

	elseif window:leader_is_active() then
		-- Leader 押下中: 使えるキー一覧を表示
		local elements = {}
		separator(elements)
		for _, e in ipairs(format_hints(leader_hints)) do
			table.insert(elements, e)
		end
		table.insert(elements, { Text = " " })
		table.insert(elements, { Background = { Color = "#FFD93D" } })
		table.insert(elements, { Foreground = { Color = "#333333" } })
		table.insert(elements, { Attribute = { Intensity = "Bold" } })
		table.insert(elements, { Text = " LEADER " })
		window:set_right_status(wezterm.format(elements))

	else
		-- 通常時: 何も表示しない
		window:set_right_status("")
	end
end)


-- ===== タブタイトル (starship の directory 表示に合わせる) =====
-- starship: [ $path ] 形式 / truncation_length=10, truncate_to_repo=true
wezterm.on("format-tab-title", function(tab, _, _, _, _, _)
	local cwd_uri = tab.active_pane.current_working_dir
	local short

	if cwd_uri then
		-- "file://host/path" → パス部分だけ取り出す
		local path = cwd_uri.file_path or cwd_uri.path or tostring(cwd_uri)
		-- ホームディレクトリを ~ に置換
		local home = os.getenv("HOME") or os.getenv("USERPROFILE") or ""
		path = path:gsub("^" .. home:gsub("([\\^$()%.%[%]*+?|])", "%%%1"), "~")
		-- 末尾スラッシュ除去
		path = path:gsub("[/\\]$", "")
		-- 末尾のディレクトリ名だけ取る（starship の truncation と同様）
		short = path:match("[/\\]([^/\\]+)$") or path
	else
		-- fallback: タイトルから取る
		short = tab.active_pane.title:match("[/\\]([^/\\]+)%s*$")
			or tab.active_pane.title
	end

	-- 16文字超えは切り捨て（starship の truncation_symbol "…/" に合わせる）
	if #short > 16 then
		short = "…" .. short:sub(-15)
	end

	return string.format("  %s  ", short)
end)

return config
