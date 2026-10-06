# ===== ls 系 =====
function ll  { Get-ChildItem -Force @args }
function la  { Get-ChildItem -Force @args }
function l   { Get-ChildItem @args }
function .. { Set-Location .. }

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

# ===== starship =====
if (Get-Command starship -ErrorAction SilentlyContinue) {
  Invoke-Expression (&starship init powershell)
}
