# ターミナルから Obsidian にメモを取る案 (未実装)

ターミナルから nvim で Obsidian のノートを書き、閉じたら Remotely Save で同期する `memo` 関数の案。
2026-10-06 時点で検討だけして、プロファイルにはまだ入れていない。

## やりたいこと

```powershell
memo           # 今日のデイリーノートを nvim で開く → 閉じたら同期
memo アイデア  # 「アイデア」ノートを nvim で開く → 閉じたら同期
```

git のコミットメッセージのように、エディタで書いて閉じたら終わり、という使い勝手にしたい。

## 前提 (確認済み)

- Obsidian の公式 CLI (`obsidian` コマンド) は設定で有効化済み。ユーザーの PATH にも `%LOCALAPPDATA%\Programs\Obsidian` が入っている
- CLI は起動中の Obsidian アプリに処理を頼む仕組み。アプリが起動していなければ立ち上がる
- vault を指定しないと、開いている vault (`~/work/obsidian/vault`) が対象になる。別の vault は `vault=yomu` のように指定する
- `obsidian daily:path` で今日のデイリーノートの vault 内パスが取れる (例: `01_Daily/2026/10/2026-10-06.md`)
- `obsidian commands filter=remotely-save` で、Remotely Save のコマンドが登録されていることは確認した
  - `remotely-save:start-sync`: 同期
  - `remotely-save:start-sync-dry-run`: 何が同期されるかを計算するだけで、ファイルは動かさない
- インストーラーが古い (1.8.10、アプリ本体は 1.14.4) と CLI 実行のたびに警告が出る。https://obsidian.md/download から入れ直すとよい

## 未確認

- `obsidian command id=remotely-save:start-sync` で、実際に同期が走るか。まず `start-sync-dry-run` で試す
- Remotely Save の定期自動同期が有効になっているか (設定ファイルの中身は読み取れなかった)

## 仕組み

フォルダを監視するのではなく、**nvim が終わるのを待ってから同期コマンドを実行する**だけ。

```powershell
nvim $path                                     # ① nvim を閉じるまで、ここで止まる
obsidian command id=remotely-save:start-sync   # ② 閉じたら実行される
```

- シェルは前のコマンドが終わってから次を実行するので、`:wq` で閉じた瞬間に ② が走る。`git commit` がエディタの終了を待つのと同じ
- ② は「同期して」と Obsidian に頼むだけですぐ返る。同期そのものは Obsidian の中で裏で進む
- Obsidian は vault 内のファイル変更を自分で検知するので、nvim で保存した内容はアプリ側にも反映される

### フォルダ監視にしない理由

- Remotely Save は Obsidian のプラグインなので、監視しても結局 Obsidian の起動は必要
- 編集中に保存するたびに同期が走り、競合の原因になりやすい

## 決めたこと・注意点

- **デイリーノートがまだない日は、先に `obsidian daily` で作らせる。** nvim で直接作ると Templater のテンプレートが適用されないため
- **変更がなければ同期しない。** 開く前と後でファイルの更新時刻を比べ、変わったときだけ ② を実行する
- 保険として、Remotely Save の定期自動同期も有効にしておく

## 実装イメージ

`Microsoft.PowerShell_profile.ps1` に足す想定。未テスト。

```powershell
# ===== Obsidian =====
# nvim でノートを書き、閉じたら Remotely Save で同期する (引数なしなら今日のデイリーノート)
function memo {
  param([string]$Name)
  $vault = (obsidian vault info=path).Trim()
  if ($Name) {
    $file = Join-Path $vault "$Name.md"
  } else {
    obsidian daily | Out-Null   # テンプレート込みで作らせる (なければ作成、あれば開くだけ)
    $file = Join-Path $vault (obsidian daily:path).Trim()
  }
  $before = if (Test-Path $file) { (Get-Item $file).LastWriteTime } else { $null }
  nvim $file
  $after = if (Test-Path $file) { (Get-Item $file).LastWriteTime } else { $null }
  if ($after -and $after -ne $before) {
    obsidian command id=remotely-save:start-sync | Out-Null
  }
}
```

実装時に確かめること:

- CLI の出力に「インストーラーが古い」警告やログが混ざると、`vault info=path` や `daily:path` の結果をそのままパスとして使えない。インストーラーを更新するか、最後の行だけ取り出す
- `memo アイデア` のノートを vault 直下に置くか、受信箱用のフォルダに置くか
- `obsidian daily` を実行すると、Obsidian 側でもデイリーノートが開く。邪魔なら別の方法を考える
