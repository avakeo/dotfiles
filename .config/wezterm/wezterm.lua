local wezterm = require("wezterm")
local act = wezterm.action

local config = {}
if wezterm.config_builder then
	config = wezterm.config_builder()
end

-- ===== 外観 =====
-- nvim の bluloco と色をそろえる (WezTerm 組み込みの配色。以前の Pop Candy は colors/pop-candy.toml に残している)
config.color_scheme = "BlulocoDark"
config.font = wezterm.font("Cica", { weight = "Medium" })
config.font_size = 14.0
config.window_background_opacity = 0.75
-- 透過背景をすりガラス状にぼかして視認性を上げる
config.macos_window_background_blur = 20
if wezterm.target_triple:find("windows") then
	config.window_decorations = "RESIZE"
	config.win32_system_backdrop = "Acrylic"
	-- ConPTY が vim 等のデフォルト背景を明示的な黒に書き換えて透過を殺すため、
	-- 明示的な背景色のセルにも透明度をかける
	-- (window 側と二重にかかって暗くなるため、差を縮めるよう少し高めに)
	config.text_background_opacity = 0.85
elseif wezterm.target_triple:find("darwin") then
	config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"
else
	config.window_decorations = "NONE"
end
config.use_fancy_tab_bar = false
config.show_new_tab_button_in_tab_bar = false

-- ===== ペイン境界 / タブバー色 =====
config.colors = {
	split = "#10B3FE",
	-- BlulocoDark の選択色は明るい灰色で文字が読みにくいので、nvim の Visual と同じ色にする
	selection_bg = "#284671",
	selection_fg = "#ABB2BF",
	-- カーソルは通常時も IME 変換中も BlulocoDark の黄色にそろえる
	-- (compose_cursor を決めておくと、opencode などがカーソル色を白に変えても変換文字が見える)
	cursor_bg = "#FFCC00",
	cursor_border = "#FFCC00",
	cursor_fg = "#282C34",
	compose_cursor = "#FFCC00",
	tab_bar = {
		background = "#21232C",       -- 空白部分（タブのない領域）
		active_tab = {
			bg_color = "#10B3FE",     -- アクティブタブ: 明るい水色で目立たせる
			fg_color = "#21232C",     -- 水色の上で白は読みにくいので暗い色にする
			intensity = "Bold",
		},
		inactive_tab = {
			bg_color = "#2C313A",     -- 非アクティブタブ
			fg_color = "#8F9AAE",
		},
		inactive_tab_hover = {
			bg_color = "#3C495D",
			fg_color = "#FFFFFF",
		},
		new_tab = {
			bg_color = "#21232C",
			fg_color = "#8F9AAE",
		},
		new_tab_hover = {
			bg_color = "#3C495D",
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
	-- local ドメイン (PowerShell) のシェル。Leader+w やランチャーから開く
	config.default_prog = { "C:\\Program Files\\PowerShell\\7\\pwsh.exe", "-NoLogo" }
	local local_domain = { DomainName = "local" }
	config.launch_menu = {
		{ label = "PowerShell 7",           args = { "C:\\Program Files\\PowerShell\\7\\pwsh.exe", "-NoLogo" }, domain = local_domain },
		{ label = "Windows PowerShell 5.1", args = { "C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe" }, domain = local_domain },
	}
	-- Ubuntu (WSL) があれば、起動・新規タブ・分割を Ubuntu で開く
	-- (PowerShell の中で wsl と打ったペインは local 扱いなので、分割すると PowerShell になる)
	local wsl_domains = wezterm.default_wsl_domains()
	for _, dom in ipairs(wsl_domains) do
		dom.default_cwd = "~"
		if dom.name == "WSL:Ubuntu" then
			config.default_domain = dom.name
		end
	end
	config.wsl_domains = wsl_domains
elseif target:find("linux") then
	config.default_prog = file_exists("/usr/bin/zsh")
		and { "/usr/bin/zsh" }
		or  { "/usr/bin/bash" }
else
	-- macOS
	-- ログインシェルで起動し、/etc/zprofile (path_helper の /usr/local/bin) と ~/.zprofile を読ませる
	config.default_prog = { "/bin/zsh", "-l" }
end

-- ===== 新規タブ・ペイン分割・タブやペインの移動の後に英数入力に切り替える =====
-- macOS では install.sh がビルドした ~/.local/bin/to-abc を、
-- Windows では install.ps1 がビルドした %USERPROFILE%\.local\bin\ime-off.exe を呼ぶ
local to_abc = (os.getenv("HOME") or "") .. "/.local/bin/to-abc"
local ime_off = (os.getenv("USERPROFILE") or "") .. "\\.local\\bin\\ime-off.exe"
local function switch_to_abc()
	if wezterm.target_triple:find("darwin") and file_exists(to_abc) then
		wezterm.background_child_process({ to_abc })
	elseif wezterm.target_triple:find("windows") and file_exists(ime_off) then
		wezterm.background_child_process({ ime_off })
	end
end
local function then_abc(action)
	return wezterm.action_callback(function(window, pane)
		window:perform_action(action, pane)
		switch_to_abc()
	end)
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
			switch_to_abc()
		end
	end)
end

-- ===== ペインが複数あればペインだけ、1つならタブごと閉じる =====
local close_pane_or_tab = wezterm.action_callback(function(window, pane)
	local tab = window:active_tab()
	if #tab:panes() > 1 then
		window:perform_action(act.CloseCurrentPane { confirm = true }, pane)
	else
		window:perform_action(act.CloseCurrentTab { confirm = true }, pane)
	end
end)

local spawn_tab = then_abc(act.SpawnTab("CurrentPaneDomain"))
local split_h = then_abc(act.SplitHorizontal { domain = "CurrentPaneDomain" })
local split_v = then_abc(act.SplitVertical { domain = "CurrentPaneDomain" })
local spawn_local_tab = then_abc(act.SpawnCommandInNewTab { domain = { DomainName = "local" } })

-- 他のアプリから WezTerm のウィンドウに戻ったとき
wezterm.on("window-focus-changed", function(window, _)
	if window:is_focused() then
		switch_to_abc()
	end
end)

-- ===== Leader キー =====
-- CTRL+\ をプレフィックスに。1秒以内に次のキーを押す
config.leader = { key = "\\", mods = "CTRL", timeout_milliseconds = 1000 }

-- ===== キーバインド =====
--
--  Leader (CTRL+\) + ...
--    v / % → 左右に分割 (英数入力に切り替える)
--    s / " → 上下に分割 (英数入力に切り替える)
--    z  → ペインをズーム/解除
--    x  → ペインを閉じる
--    < / > → タブを左 / 右に動かす
--    !  → 今のペインを新しいウィンドウに切り離す
--    h/j/k/l → ペイン移動 (英数入力に切り替える)
--    r  → リサイズモード (hjkl連打でリサイズ、Escで抜ける)
--    o  → 透明度モード   (k/l=上げる j/h=下げる、Escで抜ける)
--    f  → フォントサイズモード (k=大きく j=小さく 0=リセット、Escで抜ける)
--    [  → コピーモード (vim風: hjkl移動, v選択, y コピー, Escで抜ける)
--    w  → local ドメインで新規タブ (Windows では PowerShell。既定の Ubuntu ではなく)
--
--  CTRL + h/j/k/l → ペイン移動 (Leader なしで素早く移動。英数入力に切り替える)
--  CTRL + SHIFT + h/j/k/l → ペイン移動 (CTRL+SHIFT+矢印 と同じ。CTRL+SHIFT+L のデバッグオーバーレイは無効化)
--  CTRL + w / CMD + w → ペインを閉じる (分割あり) / タブを閉じる (分割なし)
--  CTRL + Tab     → 次のタブ (英数入力に切り替える)
--  CTRL + t / CMD + t → 新規タブ (英数入力に切り替える)
--  CTRL + ←/→    → 単語単位で移動
--  CTRL + BS      → 単語削除
--
config.keys = {

	-- ===== Shift+Enter: Claude Code 等の TUI で改行として認識させる =====
	{
		key = "Enter", mods = "SHIFT",
		action = act.SendString("\x1b\r"),
	},

	-- ===== ペイン分割 (Leader + v/s または tmux 風の %/") =====
	{
		key = "v", mods = "LEADER",
		action = split_h,
	},
	{
		key = "%", mods = "LEADER|SHIFT",
		action = split_h,
	},
	{
		key = "s", mods = "LEADER",
		action = split_v,
	},
	{
		key = '"', mods = "LEADER|SHIFT",
		action = split_v,
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

	-- ===== タブの並び替え・切り離し (Leader + < / > / !) =====
	{
		key = "<", mods = "LEADER|SHIFT",
		action = act.MoveTabRelative(-1),
	},
	{
		key = ">", mods = "LEADER|SHIFT",
		action = act.MoveTabRelative(1),
	},
	{
		key = "!", mods = "LEADER|SHIFT",
		action = wezterm.action_callback(function(_, pane)
			pane:move_to_new_window()
		end),
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
	{ key = "h", mods = "LEADER", action = then_abc(act.ActivatePaneDirection("Left"))  },
	{ key = "j", mods = "LEADER", action = then_abc(act.ActivatePaneDirection("Down"))  },
	{ key = "k", mods = "LEADER", action = then_abc(act.ActivatePaneDirection("Up"))    },
	{ key = "l", mods = "LEADER", action = then_abc(act.ActivatePaneDirection("Right")) },

	-- ===== ペイン移動 (CTRL+hjkl: vim/nvim 内はウィンドウ移動、それ以外はペイン移動) =====
	{ key = "h", mods = "CTRL", action = smart_move("Left")  },
	{ key = "j", mods = "CTRL", action = smart_move("Down")  },
	{ key = "k", mods = "CTRL", action = smart_move("Up")    },
	{ key = "l", mods = "CTRL", action = smart_move("Right") },

	-- ===== ペイン移動 (CTRL+SHIFT+hjkl: 矢印キー版と同じ) =====
	-- CTRL+SHIFT+L はデフォルトでデバッグオーバーレイが開くが、この割り当てで上書き無効化される
	{ key = "h", mods = "CTRL|SHIFT", action = then_abc(act.ActivatePaneDirection("Left"))  },
	{ key = "j", mods = "CTRL|SHIFT", action = then_abc(act.ActivatePaneDirection("Down"))  },
	{ key = "k", mods = "CTRL|SHIFT", action = then_abc(act.ActivatePaneDirection("Up"))    },
	{ key = "l", mods = "CTRL|SHIFT", action = then_abc(act.ActivatePaneDirection("Right")) },

	-- ===== タブ =====
	{
		key = "c", mods = "LEADER",
		action = spawn_tab,
	},
	{
		key = "t", mods = "CTRL",
		action = spawn_tab,
	},
	{
		key = "t", mods = "CMD",
		action = spawn_tab,
	},
	{
		key = "w", mods = "LEADER",
		action = spawn_local_tab,
	},
	{
		key = "w", mods = "CTRL",
		action = close_pane_or_tab,
	},
	{
		key = "w", mods = "CMD",
		action = close_pane_or_tab,
	},
	{
		key = "Tab", mods = "CTRL",
		action = then_abc(act.ActivateTabRelative(1)),
	},
	{
		key = "Tab", mods = "CTRL|SHIFT",
		action = then_abc(act.ActivateTabRelative(-1)),
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

	-- ===== クリップボード貼り付け =====
	-- OSC52クエリ非対応のため、ローカルのクリップボード内容をキー入力として送る
	-- (CTRL+SHIFT+V は Maccy のショートカットと衝突するため Leader 配下に)
	{
		key = "p", mods = "LEADER",
		action = act.PasteFrom("Clipboard"),
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
	table.insert(elements, { Background = { Color = "#21232C" } })
	table.insert(elements, { Foreground = { Color = "#10B3FE" } })
	table.insert(elements, { Text = " ┃ " })
	table.insert(elements, { Background = { Color = "#21232C" } })
end

-- ===== 左ステータス (INTEGRATED_BUTTONS の右隣) =====
wezterm.on("update-left-status", function(window, _)
	window:set_left_status(wezterm.format({
		{ Background = { Color = "#21232C" } },
		{ Foreground = { Color = "#8F9AAE" } },
		{ Text = "  " .. wezterm.hostname() .. "  " },
	}))
end)

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
		table.insert(elements, { Background = { Color = "#FF2E3F" } })
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
		table.insert(elements, { Background = { Color = "#F9C958" } })
		table.insert(elements, { Foreground = { Color = "#333333" } })
		table.insert(elements, { Attribute = { Intensity = "Bold" } })
		table.insert(elements, { Text = " LEADER " })
		window:set_right_status(wezterm.format(elements))

	else
		-- 通常時: 何も表示しない
		window:set_right_status("")
	end
end)


-- ===== タブタイトル (台形・Chrome 風) =====
-- Nerd Font の斜めキャップ文字でタブを台形に見せる
local TAB_BG      = "#21232C"   -- バー背景（タブ外側）
local ACTIVE_BG   = "#10B3FE"   -- アクティブタブ背景
local ACTIVE_FG   = "#21232C"
local INACTIVE_BG = "#2C313A"   -- 非アクティブタブ背景
local INACTIVE_FG = "#8F9AAE"

-- タブ名は starship の表示 (truncate_to_repo) から、~ やドライブ名を除いた先頭の階層にする
-- 例: ~/dotfiles/.config → dotfiles (リポジトリ名) / C:\Windows\System32 → Windows
local IS_WINDOWS = wezterm.target_triple:find("windows") ~= nil

-- 区切りを "/" に揃え、"/C:/Users" のような URI 由来の形も "C:/Users" にする
local function normalize_path(p)
	p = p:gsub("\\", "/"):gsub("^/(%a:)", "%1")
	if p:match("^%a:/?$") then
		return p:sub(1, 2) .. "/"
	end
	if #p > 1 then
		p = p:gsub("/$", "")
	end
	return p
end

-- path が prefix 配下なら残り（"" か "/..."）を返す。Windows は大文字小文字を区別しない
local function strip_prefix(path, prefix)
	if prefix == "" then
		return nil
	end
	local head = path:sub(1, #prefix)
	local same
	if IS_WINDOWS then
		same = head:lower() == prefix:lower()
	else
		same = head == prefix
	end
	local rest = path:sub(#prefix + 1)
	if same and (rest == "" or rest:sub(1, 1) == "/") then
		return rest
	end
	return nil
end

-- .git を親方向に探してリポジトリのルートを返す（タブ描画のたびに走るのでキャッシュ）
local repo_root_cache = {}
local function find_repo_root(path)
	local cached = repo_root_cache[path]
	if cached ~= nil then
		return cached or nil
	end
	local root = false
	local dir = path
	while true do
		local ok, found = pcall(wezterm.glob, ".git", dir)
		if ok and #found > 0 then
			root = dir
			break
		end
		local parent = dir:match("^(.*)/[^/]+$")
		if not parent then
			break
		end
		if parent == "" then
			parent = "/"
		elseif parent:match("^%a:$") then
			parent = parent .. "/"
		end
		dir = parent
	end
	repo_root_cache[path] = root
	return root or nil
end

local function tab_dir_name(path, check_repo)
	path = normalize_path(path)
	local home = normalize_path(os.getenv("USERPROFILE") or os.getenv("HOME") or "")

	-- リポジトリ内ならリポジトリ名
	local repo = check_repo and find_repo_root(path) or nil
	if repo and repo:lower() ~= home:lower() then
		return repo:match("([^/]+)$") or repo
	end

	-- それ以外は ~ やドライブ名 (C:) を除いた先頭の階層
	local rest = strip_prefix(path, home)
	-- WSL や ssh 先のホーム (/home/<user>, /root) も ~ として扱う
	if not rest then
		local linux_home = path:match("^/home/[^/]+") or path:match("^/root")
		rest = linux_home and strip_prefix(path, linux_home)
	end
	if rest == "" then
		return "~"
	end
	local first = (rest or path):gsub("^%a:", ""):match("^/*([^/]+)")
	if first then
		return first
	end
	-- ルート直下 (C:\ や /) はそのまま出す
	return IS_WINDOWS and (path:gsub("/", "\\")) or path
end

wezterm.on("format-tab-title", function(tab, _, _, _, _, max_width)
	local cwd_uri = tab.active_pane.current_working_dir
	local short

	if cwd_uri then
		local path = cwd_uri.file_path or cwd_uri.path or tostring(cwd_uri)
		-- リモート (ssh 先など) のパスはローカルに .git を探しに行かない
		local host = cwd_uri.host or ""
		-- Mac は $HOST が "xxx.local" になることがあるので、最初の "." より前だけで比べる
		local function short_host(h) return (h:lower():match("^[^.]*")) end
		local is_local = host == "" or host == "localhost" or short_host(host) == short_host(wezterm.hostname())
		short = tab_dir_name(path, is_local)
	else
		short = tab.active_pane.title:match("[/\\]([^/\\]+)%s*$")
			or tab.active_pane.title
	end

	-- 両端のキャップ + 末尾スペース分を差し引いて、はみ出すなら先頭側を削る
	short = wezterm.truncate_left(short, max_width - 3)

	local tab_bg = tab.is_active and ACTIVE_BG or INACTIVE_BG
	local tab_fg = tab.is_active and ACTIVE_FG or INACTIVE_FG
	local intensity = tab.is_active and "Bold" or "Normal"

	return {
		-- 左丸キャップ
		{ Background = { Color = TAB_BG } },
		{ Foreground = { Color = tab_bg } },
		{ Text = "\u{e0b6}" },
		-- タブ本文
		{ Background = { Color = tab_bg } },
		{ Foreground = { Color = tab_fg } },
		{ Attribute = { Intensity = intensity } },
		{ Text = short .. " " },
		-- 右丸キャップ
		{ Background = { Color = TAB_BG } },
		{ Foreground = { Color = tab_bg } },
		{ Text = "\u{e0b4}" },
		-- タブ間スペースなし
	}
end)

return config
