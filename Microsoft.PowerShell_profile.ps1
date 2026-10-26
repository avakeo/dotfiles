# ===== ls 系 =====
function ll  { Get-ChildItem -Force @args }
function la  { Get-ChildItem -Force @args }
function l   { Get-ChildItem @args }
function .. { Set-Location .. }

# ls の色を .dircolors (Mac/Linux の ls と共通、bluloco 配色) から読む
# $PSStyle.FileInfo は PowerShell 7.2 以降
$dircolors = Join-Path $PSScriptRoot ".dircolors"
if ((Test-Path $dircolors) -and $PSStyle -and $PSStyle.PSObject.Properties['FileInfo']) {
  $esc = [char]27
  $fileInfo = $PSStyle.FileInfo
  $fileInfo.Extension.Clear()
  foreach ($line in Get-Content $dircolors) {
    $line = ($line -replace '#.*$', '').Trim()
    if ($line -notmatch '^(\S+)\s+(\S+)$') { continue }
    $key, $sgr = $Matches[1], "$esc[$($Matches[2])m"
    switch -Regex ($key) {
      '^DIR$'  { $fileInfo.Directory = $sgr }
      '^LINK$' { $fileInfo.SymbolicLink = $sgr }
      '^EXEC$' { $fileInfo.Executable = $sgr }
      '^\.'    { $fileInfo.Extension[$key] = $sgr }
    }
  }
  Remove-Variable esc, fileInfo, line, key, sgr -ErrorAction SilentlyContinue
}
Remove-Variable dircolors

# ===== ファイル操作 =====
function touch {
  foreach ($f in $args) {
    if (Test-Path $f) { (Get-Item $f).LastWriteTime = Get-Date }
    else              { New-Item -ItemType File -Path $f | Out-Null }
  }
}

function mkdirp { New-Item -ItemType Directory -Path @args -Force | Out-Null }

# rm -rf 相当
function rmrf { Remove-Item -Recurse -Force @args }

# ディレクトリを作成して移動する
function mkdirc { param([string]$Path) New-Item -ItemType Directory -Path $Path -Force | Out-Null; Set-Location $Path }

# uv init で Python プロジェクトを作成する (既存プロジェクトがあれば uv がエラーで止める)
function mkdirpy { param([string]$Path) uv init $Path }

# uv init で Python プロジェクトを作成し、そのディレクトリに移動する
function mkdircpy { param([string]$Path) uv init $Path; if ($LASTEXITCODE -eq 0) { Set-Location $Path } }

# ===== テキスト処理 =====
function grep {
  param(
    [Parameter(Mandatory)][string]$Pattern,
    [Parameter(ValueFromRemainingArguments)][string[]]$Path
  )
  if ($Path) { Select-String -Pattern $Pattern -Path $Path }
  else        { $input | Select-String -Pattern $Pattern }
}

function head {
  param([int]$n = 10)
  $input | Select-Object -First $n
}

function tail {
  param([int]$n = 10)
  $input | Select-Object -Last $n
}

function wc {
  $input | Measure-Object -Line -Word -Character
}

# ===== 検索 =====
function which { (Get-Command @args).Source }

function find {
  param([string]$Path = ".", [string]$Name = "*")
  Get-ChildItem -Path $Path -Recurse -Filter $Name -ErrorAction SilentlyContinue
}

# ===== システム情報 =====
function env  { Get-ChildItem Env: | Sort-Object Name }
function df   { Get-PSDrive -PSProvider FileSystem }

# ===== Obsidian で好きなフォルダを一時的に開く =====
# 本体は .config/shell/obs.ps1 (WSL の obs と共通)。使い方はそちらの先頭を参照
$ObsScript = Join-Path $PSScriptRoot ".config\shell\obs.ps1"
function obs       { & $ObsScript @args }
function obs-clean { & $ObsScript -Clean }

# ===== その他 =====
function open { Invoke-Item @args }
function c    { Clear-Host }

# ===== git エイリアス =====
function g    { git @args }
function gs   { git status @args }
function ga   { git add @args }
function gaa  { git add -A @args }
function gc   { git commit @args }
function gcm  { git commit -m @args }
function gca  { git commit --amend @args }
function gacm { git add -A; git commit -m @args }
function gp   { git push @args }
function gpl  { git pull @args }
function gf   { git fetch @args }
function gfa  { git fetch --all --prune @args }
function gd   { git diff @args }
function gds  { git diff --staged @args }
function gl   { git log --oneline --graph --decorate @args }
function gco  { git checkout @args }
function gcb  { git checkout -b @args }
function gb   { git branch @args }
function gba  { git branch -a @args }
function gst  { git stash @args }
function gstp { git stash pop @args }
function grb  { git rebase @args }
function grs  { git restore @args }
function grss { git restore --staged @args }

# ===== PSReadLine: 履歴検索 =====
if (Get-Module -ListAvailable -Name PSReadLine) {
  Set-PSReadLineOption -HistorySearchCursorMovesToEnd
  Set-PSReadLineKeyHandler -Key UpArrow   -Function HistorySearchBackward
  Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
  # mac / Linux のシェルと同じく Ctrl+A で行頭、Ctrl+E で行末へ (Windows 既定の Ctrl+A は全選択)
  Set-PSReadLineKeyHandler -Key Ctrl+a -Function BeginningOfLine
  Set-PSReadLineKeyHandler -Key Ctrl+e -Function EndOfLine
}

# ===== PSReadLine: 配色 =====
# nvim の bluloco (dark) の構文色にそろえる
# 既定の DarkGray (ESC[90m) は透過背景だと -Force / --flag などが見えにくいため 24bit 色で明示指定する
if (Get-Module -ListAvailable -Name PSReadLine) {
  $esc = [char]27
  function rgb([string]$hex) {
    $r = [Convert]::ToInt32($hex.Substring(1, 2), 16)
    $g = [Convert]::ToInt32($hex.Substring(3, 2), 16)
    $b = [Convert]::ToInt32($hex.Substring(5, 2), 16)
    "$esc[38;2;${r};${g};${b}m"
  }
  Set-PSReadLineOption -Colors @{
    Default          = rgb '#ABB2BF'   # fg
    Command          = rgb '#3FC56B'   # method
    Parameter        = rgb '#8BCDEF'   # parameter
    Operator         = rgb '#7A82DA'   # punctuation
    Variable         = rgb '#9F7EFE'   # constant
    String           = rgb '#F9C859'   # string
    Number           = rgb '#FF78F8'   # number
    Keyword          = rgb '#10B1FE'   # keyword
    Type             = rgb '#FF6480'   # type
    Member           = rgb '#CE9887'   # property
    # nvim の comment (#636D83) は透過背景だと沈むので、少し明るい lualine の fg にする
    Comment          = rgb '#8691A3'
    InlinePrediction = rgb '#8691A3'
    Error            = rgb '#FF2E3F'   # error
  }
  Remove-Item Function:\rgb
}

# ===== zoxide (smart cd) =====
if (Get-Command zoxide -ErrorAction SilentlyContinue) {
  Invoke-Expression (& { (zoxide init powershell | Out-String) })
  Set-Alias -Name cd -Value z -Option AllScope
}

# ===== fzf =====
if (Get-Command fzf -ErrorAction SilentlyContinue) {
  if (Get-Module -ListAvailable -Name PSFzf) {
    Import-Module PSFzf
    Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t'
    Set-PsFzfOption -PSReadlineChordReverseHistory 'Ctrl+r'
  }
}

# ===== yazi =====
if (Get-Command yazi -ErrorAction SilentlyContinue) {
  # Windows には file コマンドがないので Git for Windows 同梱のものを使う
  # (git.exe は <Git>\cmd\git.exe にあるので 2 階層上が Git のルート)
  if (-not $env:YAZI_FILE_ONE -and (Get-Command git -ErrorAction SilentlyContinue)) {
    $gitRoot = Split-Path (Split-Path (Get-Command git).Source -Parent) -Parent
    $gitFile = Join-Path $gitRoot "usr\bin\file.exe"
    if (Test-Path $gitFile) { $env:YAZI_FILE_ONE = $gitFile }
  }

  # 終了時に yazi で開いていたディレクトリへ移動する
  function y {
    $tmp = (New-TemporaryFile).FullName
    yazi @args --cwd-file="$tmp"
    $cwd = Get-Content -Path $tmp -Encoding UTF8
    if (-not [string]::IsNullOrEmpty($cwd) -and $cwd -ne $PWD.Path) {
      Set-Location -LiteralPath (Resolve-Path -LiteralPath $cwd).Path
    }
    Remove-Item -Path $tmp
  }
}

# ===== dotfiles の更新チェック =====
# 1 日 1 回裏で fetch し、結果を次のプロンプトで知らせる。本体は .config/shell/update-check.ps1
. (Join-Path $PSScriptRoot ".config\shell\update-check.ps1")

# ===== starship =====
if (Get-Command starship -ErrorAction SilentlyContinue) {
  # プロンプト表示のたびに今のディレクトリを WezTerm へ通知する (OSC 7)。タブ名の更新に使う
  # (pwsh は cd してもプロセスのカレントディレクトリが変わらないため、明示的に送る必要がある)
  function Invoke-Starship-PreCommand {
    if ($PWD.Provider.Name -eq 'FileSystem') {
      $host.UI.Write("`e]7;$([System.Uri]::new($PWD.ProviderPath).AbsoluteUri)`a")
    }
    if (Test-Path Function:\Show-DotfilesNotice) { Show-DotfilesNotice }
  }
  Invoke-Expression (&starship init powershell)
}
