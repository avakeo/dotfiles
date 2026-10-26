# ===== dotfiles の更新を 1 日 1 回確認する (PowerShell 版) =====
# update-check.sh と同じ動き。PowerShell のプロファイルから読み込む
#   起動時に、その日まだ確認していなければ裏で git fetch する (起動は待たせない)
#   fetch が終わったあと、次にプロンプトを出すときに結果を 1 回だけ表示する (Show-DotfilesNotice)
#   pull は自動でしない (未コミットの変更があるとコンフリクトするため)
#   dotfiles-check     → 今の状態をすぐ表示する (fetch はしない)
#   dotfiles-check -f  → fetch してから表示する
#   Windows の環境変数 DOTFILES_UPDATE_CHECK を 0 にすると無効になる
# PowerShell 5.1 が日本語を読めるよう、このファイルは BOM 付き UTF-8 で保存する

if ($env:DOTFILES_UPDATE_CHECK -eq '0') { return }
if (-not (Get-Command git -ErrorAction SilentlyContinue)) { return }

$DotfilesRepo = git -C $PSScriptRoot rev-parse --show-toplevel 2>$null
if (-not $DotfilesRepo) { return }
$DotfilesCache = Join-Path $env:LOCALAPPDATA "dotfiles-update-check"

# ローカルの ref だけで状態をまとめる (ネットワークには出ない)
function Get-DotfilesReport {
  $behind = [int](git -C $DotfilesRepo rev-list --count main..origin/main 2>$null)
  if ($behind -gt 0) {
    "dotfiles: main が origin/main より $behind コミット遅れています (cd $DotfilesRepo; git pull --rebase --autostash)"
  }
  $branches = @(git -C $DotfilesRepo branch -r --no-merged origin/main --format='%(refname:lstrip=3)' 2>$null |
    Where-Object { $_ -and $_ -ne 'HEAD' })
  if ($branches.Count -gt 0) {
    $more = if ($branches.Count -gt 3) { ' ...' } else { '' }
    "dotfiles: main にまだ入っていないブランチが $($branches.Count) つあります: $(($branches | Select-Object -First 3) -join ' ')$more"
  }
}

# fetch は別プロセスの PowerShell で動かす。$After は fetch が成功したあとに続けて実行するコード
# 認証を求められても待たずに失敗させる (ssh は BatchMode、https は Git Credential Manager の画面を出さない)
function Start-DotfilesFetch([string]$After = '', [switch]$Background) {
  $ssh = git -C $DotfilesRepo config core.sshCommand
  if (-not $ssh) { $ssh = 'ssh' }
  $code = "`$env:GIT_TERMINAL_PROMPT = '0'; `$env:GCM_INTERACTIVE = 'never'; " +
    "git -C '$($DotfilesRepo.Replace("'", "''"))' -c 'core.sshCommand=$($ssh.Replace("'", "''")) -o BatchMode=yes' fetch --quiet --prune; " +
    "if (`$LASTEXITCODE -ne 0) { exit 1 }; $After"
  $psArgs = @('-NoProfile', '-EncodedCommand', [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($code)))
  $exe = (Get-Process -Id $PID).Path
  if ($Background) {
    Start-Process $exe -WindowStyle Hidden -ArgumentList $psArgs
  } else {
    & $exe @psArgs
    $LASTEXITCODE -eq 0
  }
}

function dotfiles-check([switch]$f) {
  if ($f -and -not (Start-DotfilesFetch)) {
    [Console]::Error.WriteLine("dotfiles: fetch に失敗しました")
  }
  $out = @(Get-DotfilesReport)
  if ($out) { $out } else { "dotfiles: 更新はありません" }
}

# 裏の fetch が終わると fetched ができるので、あれば結果を表示して消す。プロンプトを出す前に毎回呼ぶ
function Show-DotfilesNotice {
  $fetched = Join-Path $DotfilesCache "fetched"
  if (-not (Test-Path -LiteralPath $fetched)) { return }
  Remove-Item -LiteralPath $fetched -Force
  Get-DotfilesReport | ForEach-Object { $host.UI.WriteLine($_) }
}

New-Item -ItemType Directory -Path $DotfilesCache -Force | Out-Null
$lastFetch = Join-Path $DotfilesCache "last-fetch"
$today = Get-Date -Format 'yyyy-MM-dd'
if ((Get-Content -LiteralPath $lastFetch -ErrorAction SilentlyContinue) -ne $today) {
  # 先に日付を書いて、同時に開いた他のシェルが fetch を重ねないようにする
  Set-Content -LiteralPath $lastFetch -Value $today
  $fetched = (Join-Path $DotfilesCache "fetched").Replace("'", "''")
  Start-DotfilesFetch -Background -After "New-Item -ItemType File -Path '$fetched' -Force | Out-Null"
}
Remove-Variable lastFetch, today, fetched -ErrorAction SilentlyContinue
