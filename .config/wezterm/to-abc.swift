// 入力ソースを英数 (ABC) に切り替える。WezTerm で新規タブを開いたときに呼ぶ
// ビルド: swiftc -O to-abc.swift -o ~/.local/bin/to-abc (install.sh が行う)
import Carbon

let filter = [kTISPropertyInputSourceID as String: "com.apple.keylayout.ABC"] as CFDictionary
guard let list = TISCreateInputSourceList(filter, false)?.takeRetainedValue() as? [TISInputSource],
      let src = list.first else { exit(1) }
exit(TISSelectInputSource(src) == noErr ? 0 : 1)
