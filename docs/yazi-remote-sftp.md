# yazi から他の PC (Windows / WSL) を開く

yazi の SFTP (`sftp://`) で、別の PC の Windows と WSL のファイルを開くためのメモ。
今の `gv` (viber) と同じ書き方で、接続先を増やす。

前提:

- 相手の PC で **SSH サーバーが動いていれば**、yazi から開ける。SFTP は SSH の接続の中で動くので、`ssh <相手>` で入れるなら SFTP も使える (詳しくは `2026-09-yazi-shell-setup.md` のネットワーク編)。
- 接続先の IP・ユーザー・鍵は `.config/yazi/vfs.toml` に書く。マシン固有なので git では管理しない。
- 以下の IP やユーザー名は例。実際の値はこのファイルにも書かない。

---

## Tailscale を使う場合 (今の構成)

Windows 本体と WSL の中の両方に Tailscale を入れている。
そのため WSL も独自の 100.x のアドレスを持ち、Tailscale からは別の端末として見える。

```
Mac / viber の yazi
  │  sftp://<名前>-win  → Windows の 100.x : 22 → Windows の OpenSSH Server
  │  sftp://<名前>-wsl  → WSL の 100.x     : 22 → WSL の sshd
```

WSL が独自のアドレスを持つので、Windows の sshd と WSL の sshd はどちらも 22 番のままでぶつからない。

### Windows 側の準備

管理者の PowerShell で実行する。

```powershell
# OpenSSH Server を入れる (入っているかは Get-Service sshd で分かる)
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
# 起動し、Windows の起動時にも自動で立ち上げる
Start-Service sshd
Set-Service sshd -StartupType Automatic
```

- 公開鍵 (`~/.ssh/id_ed25519.pub` の中身) を相手に登録する。
  - 一般ユーザー: `C:\Users\<ユーザー>\.ssh\authorized_keys`
  - 管理者グループのユーザー: `C:\ProgramData\ssh\administrators_authorized_keys` (こちらしか読まれない)
- Tailscale SSH (`tailscale up --ssh`) は、Windows ではサーバーとして使えない。Windows 側は OpenSSH Server を使う。

### WSL 側の準備

```sh
sudo apt install openssh-server
# /etc/wsl.conf の [boot] に systemd=true がある前提
sudo systemctl enable --now ssh
```

- 公開鍵は WSL の `~/.ssh/authorized_keys` に登録する。
- WSL が止まっているとつながらない。Windows にログインして WSL を起動しておく。

### yazi 側の設定 (vfs.toml)

```toml
[sftp.pc-win]
host     = "100.x.x.x"   # Windows の Tailscale IP (tailscale ip -4 で分かる)
user     = "<Windows のユーザー>"
port     = 22
key_file = "~/.ssh/id_ed25519"

[sftp.pc-wsl]
host     = "100.y.y.y"   # WSL の中で tailscale ip -4
user     = "<WSL のユーザー>"
port     = 22
key_file = "~/.ssh/id_ed25519"
```

開くときは `g<Space>` で `sftp://pc-wsl` のように入力する。よく使うなら `keymap.toml` に `gv` と同じ形でキーを足す。
Windows の絶対パスは `sftp://pc-win//C:/Users/<ユーザー>` のような形になるはず (未確認)。

### 先に確認すること

yazi で試す前に、ターミナルから鍵認証が通るかを確かめる。

```sh
ssh -o BatchMode=yes -o ConnectTimeout=6 <ユーザー>@100.x.x.x 'echo connected'
```

---

## Tailscale を使わない場合

どの方法でも、相手の PC で SSH サーバーを動かすところ (上の「Windows 側の準備」「WSL 側の準備」) は同じ。
変わるのは「相手の 22 番ポートまでどう届かせるか」だけ。

| 方法 | 使える場所 | 手間 | 注意 |
|---|---|---|---|
| 1. LAN の IP に直接つなぐ | 同じ家・同じ Wi-Fi の中だけ | 小さい | IP が変わることがある。ルーターで固定する |
| 2. ルーターのポート転送 | どこからでも | 中くらい | SSH をインターネットに公開することになる |
| 3. 踏み台サーバー経由のトンネル | どこからでも | 中くらい | 常に動いている公開サーバーが要る |
| 4. 別の VPN (自前の WireGuard など) | どこからでも | 大きい | やっていることは Tailscale と同じ |
| 5. SMB (Windows のファイル共有) | 同じ LAN の中だけ | 小さい | SSH ではないので yazi の SFTP は使わない |

### 1. LAN の IP に直接つなぐ

`vfs.toml` の `host` に `192.168.x.x` のような LAN の IP を書くだけでよい。

WSL は既定では Windows の裏の NAT にいるので、LAN から WSL の IP には直接届かない。
次のどちらかが必要になる。

- `.wslconfig` に `networkingMode=mirrored` を書き、WSL が Windows と同じ IP を使うようにする。Windows の sshd と 22 番がぶつかるので、WSL の sshd は 2222 番などに変える。
- Windows 側で `netsh interface portproxy` を使い、Windows の 2222 番を WSL の 22 番へ転送する。WSL の IP は起動のたびに変わるので、こちらは手間がかかる。

### 2. ルーターのポート転送

ルーターで「外からの 22 番 (または別の番号) を、相手の PC の 22 番へ」転送する。
SSH をインターネットに公開するので、次を必ず行う。

- パスワード認証を切り、鍵認証だけにする (`sshd_config` の `PasswordAuthentication no`)。
- 外向きのポートを 22 以外にして、ログへの総当たりを減らす。
- 家の回線のグローバル IP が変わるなら、DDNS も要る。

### 3. 踏み台サーバー経由のトンネル

VPS などの公開サーバーがあれば、相手の PC からそのサーバーへ逆向きのトンネルを張る (`ssh -R`)。
yazi の `vfs.toml` には `host` と `port` しか書けず、`~/.ssh/config` の `ProxyJump` が使えるかは未確認。
使えない場合は、先に `ssh -L 2222:<相手>:22 <踏み台>` でローカルにポートを開き、`vfs.toml` には `host = "127.0.0.1"`、`port = 2222` と書く。

### 4. 別の VPN

自前の WireGuard や ZeroTier でも、相手に VPN 内の IP が付けば Tailscale と同じ書き方で使える。
WireGuard を自前で組む場合は、鍵の配布と、どの端末が外から届く場所に立つかを自分で決める必要がある。Tailscale はこれを代わりにやっている。

### 5. SMB (Windows のファイル共有)

同じ LAN の中だけなら、Windows のフォルダを共有し、Mac の Finder で「サーバへ接続」(`smb://192.168.x.x`) からマウントする方法もある。
マウントすると `/Volumes/<共有名>` に出てくるので、yazi からはローカルのフォルダとして開ける。
SSH サーバーは要らないが、家の外からは使えない。WSL のファイルは `\\wsl.localhost` 経由になり、共有の設定がややこしい。

---

## まとめ

- 家の外からも使うなら、Tailscale がいちばん手間が小さい。ポートを外に開けずに済む。
- 家の中だけなら、1 (LAN の IP) か 5 (SMB) で足りる。
