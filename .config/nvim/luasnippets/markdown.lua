-- Obsidian のプロパティ (YAML フロントマター) 用スニペット
-- 使い方: 挿入モードでトリガーを打って <Tab> (nvim-cmp / LuaSnip)

local date = function(fmt)
  return f(function()
    return os.date(fmt)
  end)
end

local today = function() return date("%Y-%m-%d") end
local now   = function() return date("%Y-%m-%d %H:%M") end

-- LuaSnip は既定で「展開した行のインデント」をスニペットの全行に付ける。
-- YAML フロントマターは行頭にないと無効なので、トリガーの前が空白だけなら
-- その空白ごと消す範囲を返して、必ず桁 0 から展開されるようにする。
local function no_indent(_, line_to_cursor, matched_trigger, _)
  local before = line_to_cursor:sub(1, #line_to_cursor - #matched_trigger)
  if before == "" or before:match("^%s+$") then
    local row = vim.api.nvim_win_get_cursor(0)[1] - 1
    return {
      clear_region = {
        from = { row, 0 },
        to   = { row, #line_to_cursor },
      },
    }
  end
  return {}
end

-- プロパティ系スニペット用の共通オプション
local function prop(trig, desc)
  return { trig = trig, desc = desc, resolveExpandParams = no_indent }
end

return {
  -- ===== フロントマター一式 =====
  s(prop("prop", "Obsidian プロパティ一式"), {
    t({ "---", "title: " }), i(1, "タイトル"),
    t({ "", "aliases: [" }), i(2), t({ "]", "tags: [" }), i(3, "note"),
    t({ "]", "created: " }), today(),
    t({ "", "updated: " }), today(),
    t({ "", "status: " }), i(4, "draft"),
    t({ "", "---", "", "" }), i(0),
  }),

  s(prop("fm", "最小フロントマター"), {
    t({ "---", "tags: [" }), i(1, "note"),
    t({ "]", "created: " }), today(),
    t({ "", "---", "", "" }), i(0),
  }),

  -- ===== 個別プロパティ =====
  s(prop("tags", "tags プロパティ"),
    { t("tags: ["), i(1, "note"), t("]") }),

  s(prop("tagl", "tags プロパティ (リスト形式)"),
    { t({ "tags:", "  - " }), i(1, "note"), t({ "", "  - " }), i(2) }),

  s(prop("alias", "aliases プロパティ"),
    { t("aliases: ["), i(1), t("]") }),

  s(prop("css", "cssclasses プロパティ"),
    { t("cssclasses: ["), i(1), t("]") }),

  s(prop("created", "created (今日)"),
    { t("created: "), today() }),

  s(prop("updated", "updated (現在時刻)"),
    { t("updated: "), now() }),

  s(prop("status", "status プロパティ"),
    { t("status: "), i(1, "draft") }),

  s(prop("source", "source (参照 URL)"),
    { t("source: "), i(1, "https://") }),

  s(prop("pub", "publish プロパティ"),
    { t("publish: "), i(1, "false") }),

  -- ===== 本文でよく使うもの =====
  -- こちらはインデントを引き継ぐ (ネストした箇条書きの中で使うため)
  s({ trig = "date", desc = "今日の日付" }, { today() }),
  s({ trig = "time", desc = "現在日時" }, { now() }),
  s({ trig = "cb", desc = "チェックボックス" }, { t("- [ ] "), i(0) }),
}
