#!/bin/bash

set -e  # エラーが発生したら即終了

# ライブラリスクリプトを配置するディレクトリ
LIB_DIR="$(dirname "$0")/libraries"

# ライブラリスクリプトが存在するかチェック
if [ ! -d "$LIB_DIR" ]; then
  echo "❌ Error: Libraries directory '$LIB_DIR' not found!"
  exit 1
fi

# すべてのライブラリスクリプトを実行
for script in "$LIB_DIR"/*.sh; do
  if [ -f "$script" ]; then  # .sh ファイルがある場合のみ実行
    echo "▶ Installing $(basename "$script")..."
    bash "$script"
  fi
done

echo "✅ All libraries installed!"

