# ===== ls 系 =====
function ll  { Get-ChildItem -Force @args }
function la  { Get-ChildItem -Force @args }
function l   { Get-ChildItem @args }

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
function gs   { git status @args }
function ga   { git add @args }
function gaa  { git add -A @args }
function gc   { git commit @args }
function gcm  { git commit -m @args }
function gacm { git add -A; git commit -m @args }
function gp   { git push @args }
function gpl  { git pull @args }
function gf   { git fetch @args }
function gd   { git diff @args }
function gds  { git diff --staged @args }
function gl   { git log --oneline --graph --decorate @args }
function gco  { git checkout @args }
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
}

# ===== starship =====
if (Get-Command starship -ErrorAction SilentlyContinue) {
  Invoke-Expression (&starship init powershell)
}
