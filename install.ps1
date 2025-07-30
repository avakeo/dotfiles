$dotfilesDir = "$PSScriptRoot"
$configDir = Join-Path $HOME ".config"

# シンボリックリンク作成関数
function New-Symlink($link, $target) {
    if (Test-Path $link) {
        Write-Host "既存のリンクまたはファイルを削除: $link"
        Remove-Item $link -Force -Recurse
    }

    New-Item -ItemType SymbolicLink -Path $link -Target $target | Out-Null
    Write-Host "✅ Linked: $link → $target"
}

Write-Host "`n📁 dotfiles を $HOME にリンクします (Windows)" -ForegroundColor Cyan

# .config ディレクトリがなければ作成
if (!(Test-Path $configDir)) {
    New-Item -ItemType Directory -Path $configDir | Out-Null
    Write-Host "📂 .config ディレクトリを作成しました"
}

# .config 以下のリンク
$configItems = @("nvim", "scoop", "wezterm", "starship.toml")

foreach ($item in $configItems) {
    $target = Join-Path "$dotfilesDir\.config" $item
    $link = Join-Path $configDir $item
    New-Symlink $link $target
}

# ホーム直下のファイル
$homeFiles = @(
    ".vimrc",
    ".bashrc",
    ".zshrc",
    ".dircolors",
    "Microsoft.PowerShell_profile.ps1"
)

foreach ($file in $homeFiles) {
    $target = Join-Path $dotfilesDir $file
    $link = Join-Path $HOME $file
    New-Symlink $link $target
}

Write-Host "`n✅ すべてのリンクが完了しました！" -ForegroundColor Green

