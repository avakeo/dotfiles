# 共通の作業ルール

正本は `dotfiles/claude/CLAUDE.md`。install スクリプトが `~/.claude/CLAUDE.md` にリンクする。

## 文章の書き方

日本語で文章を書くとき (会話の返答、コミットメッセージ、PR 説明文、ドキュメント) は、常に以下の yomiyasu スキルのルールに従う。

@~/.claude/plugins/marketplaces/yomiyasu/SKILL.md

## Python

- パッケージ管理・実行は **uv** に統一する。pip / poetry / venv / conda は使わない。
- 依存追加は `uv add <pkg>`（開発依存は `uv add --dev <pkg>`）、実行は `uv run <cmd>`。
- 新規プロジェクトは `uv init`。Python バージョンは `uv python pin` で固定する。
- 正は `pyproject.toml` + `uv.lock`。`requirements.txt` は作らない。lock はコミットする。
- lint / format は ruff（`uv run ruff check --fix` / `uv run ruff format`）、テストは pytest。
- 単発スクリプトは PEP 723 のインラインメタデータ + `uv run script.py` を使う。

## Git

- 作業前にブランチを切る。main / master へ直接コミット・push しない。
- ブランチ名は `<type>/<短い説明>`（例: `feat/uv-migration`, `fix/login-redirect`）。
- コミットメッセージは Conventional Commits の prefix + 日本語本文（例: `feat: 記事の下書き保存に対応`）。
- 1コミット1論点。無関係な整形・リネーム・依存更新を混ぜない。
- commit / push は指示されたときだけ行う。頼まれていないのに勝手にやらない。
- PR は `gh pr create`。本文には「何を・なぜ」を書く（どう実装したかは diff でわかる）。
- `git push --force` は使わない。必要なら `--force-with-lease` を提案して確認を取る。
- `.env`・認証情報・大きなバイナリ・生成物はコミットしない。迷ったら `.gitignore` を確認する。
- `git reset --hard` / `git clean -fd` など破棄を伴う操作は、実行前に必ず確認を取る。
