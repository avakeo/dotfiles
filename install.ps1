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

  $isDir = (Get-Item $src -Force) -is [System.IO.DirectoryInfo]
  if ($isDir) {
    New-Item -ItemType SymbolicLink -Path $dest -Target $src | Out-Null
  } else {
    New-Item -ItemType SymbolicLink -Path $dest -Target $src | Out-Null
  }
  Write-Success (Split-Path $dest -Leaf)
}

# ===== Link targets =====

function Link-Home {
  Write-Host ""
  Write-Host "Home dotfiles:"

  $files = @(".vimrc", "Microsoft.PowerShell_profile.ps1")
  foreach ($name in $files) {
    New-Symlink (Join-Path $DotDir $name) (Join-Path $HOME $name)
  }
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

function Post-Install {
  Write-Host ""
  Write-Host "Git config:"
  git config --global include.path "~/.gitconfig_shared"
  Write-Success "include.path set to ~/.gitconfig_shared"
}

# ===== Main =====

Write-Host "Platform: Windows (PowerShell $($PSVersionTable.PSVersion))" -ForegroundColor Cyan

Assert-SymlinkPrivilege
Link-Home
Link-Config
Post-Install

Write-Host ""
Write-Host "Install completed!" -ForegroundColor Cyan
