# TODO: Windows で新規タブを開いたら英数入力にする

macOS では対応済み。Windows 環境で作業するときに同じことをする。

## macOS 版 (対応済み)

- `.config/wezterm/to-abc.swift`: 入力ソースを ABC に切り替える
- `install.sh` の `build_to_abc`: `~/.local/bin/to-abc` にビルドする
- `wezterm.lua` の `spawn_tab`: タブを開いた後に `to-abc` を呼ぶ (`Leader+c` / `CTRL+t` / `CMD+t`)

## Windows 版の方針

Windows では入力ソースを切り替えるのではなく、IME をオフにして英数入力にする。
vim 向けの `zenhan` と同じ処理。

1. `GetForegroundWindow` で前面の WezTerm ウィンドウを取る
2. `ImmGetDefaultIMEWnd` でそのウィンドウの IME ウィンドウを取る
3. `SendMessage(IMEウィンドウ, WM_IME_CONTROL (0x283), IMC_SETOPENSTATUS (0x6), 0)` で IME をオフにする

## やること

- [ ] 上の処理を C# で書く (例: `.config/wezterm/ime-off.cs`)
- [ ] `install.ps1` で `csc.exe` を使ってビルドする
  - `csc.exe` は .NET Framework に付いてくる: `C:\Windows\Microsoft.NET\Framework64\v4.0.30319\csc.exe`
  - PowerShell の `Add-Type` でその場で実行すると、タブを開くたびに1秒ほど遅れるため、ビルド済みの exe にする
- [ ] `wezterm.lua` の `spawn_tab` で、Windows のときはその exe を呼ぶ
- [ ] Windows で `CTRL+t` を押し、IME がオフになるか確かめる

## 注意

Windows の IME の状態はウィンドウ単位で持っている。
同じ WezTerm ウィンドウの中では、どのタブでも IME のオン・オフを共有する。
