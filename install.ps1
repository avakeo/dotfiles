#Requires -Version 5.1
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$DotDir = $PSScriptRoot
$BackupDir = Join-Path $HOME ".dotbackup\$(Get-Date -Format 'yyyyMMdd_HHmmss')"

# ===== Helpers =====

function Write-Success($msg) { Write-Host "  v $msg" -ForegroundColor Green }
function Write-Info($msg)    { Write-Host "  - $msg" -ForegroundColor Gray }
function Write-Warn($msg)    { Write-Host "  ! $msg" -ForegroundColor Yellow }

function Assert-SymlinkPrivilege {
  # Developer Mode が有効か、管理者権限があるかチェック
  $devMode = Get-ItemProperty `
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" `
    -Name AllowDevelopmentWithoutDevLicense -ErrorAction SilentlyContinue
  $isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator
  )

  if (-not $isAdmin -and ($devMode.AllowDevelopmentWithoutDevLicense -ne 1)) {
    Write-Warn "Symlinks require either:"
    Write-Warn "  - Run as Administrator, OR"
    Write-Warn "  - Enable Developer Mode (Settings > Privacy & Security > For developers)"
    exit 1
  }
}

function New-Symlink($src, $dest) {
  if (-not (Test-Path $src)) {
    Write-Warn "skip (not found): $src"
    return
  }

  $isDir = (Get-Item $src -Force) -is [System.IO.DirectoryInfo]

  if ($isDir) {
    # ディレクトリ: 既存のディレクトリシンボリックリンクを削除して実ディレクトリを作成し再帰処理
    if (Test-Path $dest) {
      $item = Get-Item $dest -Force
      if ($item.LinkType -eq "SymbolicLink") {
        Remove-Item $dest -Force
      }
    }
    New-Item -ItemType Directory -Path $dest -Force | Out-Null
    Get-ChildItem $src -Force | ForEach-Object {
      New-Symlink $_.FullName (Join-Path $dest $_.Name)
    }
  } else {
    # ファイル: シンボリックリンクを作成
    if (Test-Path $dest) {
      $item = Get-Item $dest -Force
      if ($item.LinkType -eq "SymbolicLink") {
        Remove-Item $dest -Force
      } else {
        New-Item -ItemType Directory -Path $BackupDir -Force | Out-Null
        Move-Item $dest $BackupDir -Force
        Write-Info "backed up: $(Split-Path $dest -Leaf)"
      }
    }
    New-Item -ItemType SymbolicLink -Path $dest -Target $src | Out-Null
    Write-Success (Split-Path $dest -Leaf)
  }
}

# ===== Link targets =====

function Link-Home {
  Write-Host ""
  Write-Host "Home dotfiles:"

  New-Symlink (Join-Path $DotDir ".vimrc")            (Join-Path $HOME ".vimrc")
  New-Symlink (Join-Path $DotDir ".gitconfig_shared") (Join-Path $HOME ".gitconfig_shared")

  # lightline カラースキーム
  $lcDir = Join-Path $HOME ".vim\autoload\lightline\colorscheme"
  New-Item -ItemType Directory -Path $lcDir -Force | Out-Null
  New-Symlink (Join-Path $DotDir ".vim\autoload\lightline\colorscheme\dotfiles.vim") (Join-Path $lcDir "dotfiles.vim")

  # PowerShell プロファイル: $PROFILE からドットソース (シンボリックリンク不要)
  $profileDir = Split-Path $PROFILE -Parent
  New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
  $dotfilesProfile = Join-Path $DotDir "Microsoft.PowerShell_profile.ps1"
  Set-Content -Path $PROFILE -Value ". `"$dotfilesProfile`"" -Encoding UTF8
  Write-Success "PowerShell profile -> $dotfilesProfile"
}

function Link-Config {
  Write-Host ""
  Write-Host ".config entries:"

  $configDir = Join-Path $HOME ".config"
  New-Item -ItemType Directory -Path $configDir -Force | Out-Null

  # Windows で使う設定のみ
  $entries = @("nvim", "scoop", "wezterm", "fish", "starship.toml")
  foreach ($name in $entries) {
    $src  = Join-Path $DotDir ".config\$name"
    $dest = Join-Path $configDir $name
    New-Symlink $src $dest
  }
}

function Install-Scoop {
  Write-Host ""
  Write-Host "Scoop:"

  if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
    Write-Info "installing scoop..."
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
    Invoke-RestMethod -Uri "https://get.scoop.sh" | Invoke-Expression
    Write-Success "scoop installed"
  } else {
    Write-Info "scoop already installed"
  }

  $packages = @("7zip", "neovim", "vim", "starship", "fzf", "zoxide")
  foreach ($pkg in $packages) {
    $installed = scoop list $pkg 2>$null | Select-String $pkg
    if ($installed) {
      Write-Info "already installed: $pkg"
    } else {
      Write-Info "installing $pkg..."
      scoop install $pkg
      Write-Success $pkg
    }
  }
}

function Post-Install {
  Write-Host ""
  Write-Host "Git config:"
  git config --global include.path "~/.gitconfig_shared"
  Write-Success "include.path set to ~/.gitconfig_shared"

  Write-Host ""
  Write-Host "WezTerm:"
  $weztermConfig = Join-Path $DotDir ".config\wezterm\wezterm.lua"
  [System.Environment]::SetEnvironmentVariable("WEZTERM_CONFIG_FILE", $weztermConfig, "User")
  Write-Success "WEZTERM_CONFIG_FILE=$weztermConfig"
}

# ===== Main =====

Write-Host "Platform: Windows (PowerShell $($PSVersionTable.PSVersion))" -ForegroundColor Cyan

Assert-SymlinkPrivilege
Install-Scoop
Link-Home
Link-Config
Post-Install

Write-Host ""
Write-Host "Install completed!" -ForegroundColor Cyan
