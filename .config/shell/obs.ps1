#Requires -Version 5.1
# ===== Obsidian で好きなフォルダを一時的に開く (Windows 版) =====
# macOS 版 (os/macos.sh の obs) と同じ動き。PowerShell のプロファイルと WSL の obs から呼ばれる
#   obs.ps1 [パス]  → パス (省略時はカレント) を一時用 vault にリンクして開く。ファイルならそのファイルを新しいタブで開く
#   obs.ps1 -Clean  → 一時用 vault のリンクをすべて消す (リンク先は消さない)
# Obsidian を終了すると、裏で待っているプロセスが -Clean と同じようにリンクを消す
# 一時用 vault は $env:OBS_TMP_VAULT (省略時は ~\work\obsidian\tmp)。最初に一度だけ Obsidian の「フォルダを保管庫として開く」で登録する
# PowerShell 5.1 が日本語を読めるよう、このファイルは BOM 付き UTF-8 で保存する
param(
  [string]$Path = ".",
  [switch]$Clean
)
$ErrorActionPreference = "Stop"
# WSL から呼んだときに日本語のメッセージが文字化けしないようにする
try { [Console]::OutputEncoding = [Text.Encoding]::UTF8 } catch {}

$vault = if ($env:OBS_TMP_VAULT) { $env:OBS_TMP_VAULT } else { Join-Path $HOME "work\obsidian\tmp" }

# vault 直下のリンク (ジャンクション・シンボリックリンク) だけを返す
function Get-VaultLinks {
  if (-not (Test-Path -LiteralPath $vault)) { return }
  Get-ChildItem -LiteralPath $vault -Force |
    Where-Object { $_.Attributes -band [IO.FileAttributes]::ReparsePoint }
}

if ($Clean) {
  # Delete() はリンクそのものだけを消し、リンク先の中身には触れない
  Get-VaultLinks | ForEach-Object { $_.FullName; $_.Delete() }
  exit 0
}

$item = Get-Item -LiteralPath $Path -Force -ErrorAction SilentlyContinue
if (-not $item) {
  [Console]::Error.WriteLine("obs: $Path が見つからない")
  exit 1
}
if ($item.PSIsContainer) {
  $dir = $item.FullName; $file = ""
} else {
  $dir = $item.DirectoryName; $file = $item.Name
}

New-Item -ItemType Directory -Path $vault -Force | Out-Null
$vault = (Get-Item -LiteralPath $vault).FullName.TrimEnd('\')
$registered = $false
$config = Join-Path $env:APPDATA "obsidian\obsidian.json"
if (Test-Path -LiteralPath $config) {
  $vaults = (Get-Content -LiteralPath $config -Raw -Encoding UTF8 | ConvertFrom-Json).vaults
  if ($vaults) {
    $registered = @($vaults.PSObject.Properties.Value.path) -contains $vault
  }
}
if (-not $registered) {
  [Console]::Error.WriteLine("obs: $vault が vault として未登録。Obsidian の「フォルダを保管庫として開く」で一度だけ登録して")
  exit 1
}

# 同じフォルダへのリンクがあれば使い回し、名前だけ重なるなら -2, -3 ... を付ける
$name = Split-Path $dir -Leaf
$link = Join-Path $vault $name
$i = 2
$reuse = $false
while (Test-Path -LiteralPath $link) {
  $existing = Get-Item -LiteralPath $link -Force
  if (($existing.Attributes -band [IO.FileAttributes]::ReparsePoint) -and
      (@($existing.Target)[0].TrimEnd('\') -eq $dir)) {
    $reuse = $true; break
  }
  $link = Join-Path $vault "$name-$i"; $i++
}
if (-not $reuse) {
  # ローカルのドライブはジャンクション (権限不要)。WSL 側 (\\wsl.localhost\...) などの UNC パスは
  # ジャンクションにできないのでシンボリックリンク (開発者モードか管理者権限が要る)
  $type = if ($dir.StartsWith('\\')) { "SymbolicLink" } else { "Junction" }
  try {
    New-Item -ItemType $type -Path $link -Target $dir | Out-Null
  } catch {
    [Console]::Error.WriteLine("obs: リンクを作れなかった ($type): $($_.Exception.Message)")
    if ($type -eq "SymbolicLink") {
      [Console]::Error.WriteLine("obs: 設定 > システム > 開発者向け で開発者モードを有効にして")
    }
    exit 1
  }
}

# ファイルは path で指定して新しいタブで開く。フォルダを path で渡すと「見つかりません」になるので vault 名だけで開く
if ($file) {
  $uri = "obsidian://open?path=$([uri]::EscapeDataString((Join-Path $link $file)))&paneType=tab"
} else {
  $uri = "obsidian://open?vault=$([uri]::EscapeDataString((Split-Path $vault -Leaf)))"
}
Start-Process $uri

# Obsidian の終了を待ってリンクを消すプロセスを1つだけ起動する (起動を待つため最初に 10 秒置く)
# 起動済みかを見分けるため、コマンドラインに obs-tmp-watcher という文字列を入れておく
$running = Get-CimInstance Win32_Process -Filter "Name = 'powershell.exe' OR Name = 'pwsh.exe'" |
  Where-Object { $_.CommandLine -like '*obs-tmp-watcher*' }
if (-not $running) {
  $quoted = $vault.Replace("'", "''")
  $watcher = "'obs-tmp-watcher' | Out-Null; " +
    "Start-Sleep 10; while (Get-Process Obsidian -ErrorAction SilentlyContinue) { Start-Sleep 5 }; " +
    "Get-ChildItem -LiteralPath '$quoted' -Force | " +
    "Where-Object { `$_.Attributes -band [IO.FileAttributes]::ReparsePoint } | ForEach-Object { `$_.Delete() }"
  Start-Process (Get-Process -Id $PID).Path -WindowStyle Hidden `
    -ArgumentList "-NoProfile -Command `"$watcher`""
}
