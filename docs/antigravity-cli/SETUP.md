# Google Antigravity CLI（`agy`）導入・運用ガイド

## 1. 結論

- Google 公式の Antigravity CLI は実在し、公式リポジトリは
  [google-antigravity/antigravity-cli](https://github.com/google-antigravity/antigravity-cli)、
  コマンド名は **`agy`**、インストールは 1 行のスクリプトで完了する。
- 本リポジトリに **導入スクリプト `scripts/setup-antigravity-cli.sh`** と
  **ヘッドレス実行ラッパ `scripts/agy-run.sh`** を用意した。ローカル環境ではこの 2 本で
  「導入 → サインイン → CI/自動実行」まで通せる。
- ただし **Claude Code on the web（本リモートコンテナ）では実インストール不可**。
  egress プロキシが `antigravity.google` を 403 で遮断するため、バイナリを取得できない。
  → 実インストールは**手元のマシン**で行う。リモートからは
  `--remote-control` または `GEMINI_API_KEY` ヘッドレスで使う。

## 2. 確認済みの事実（一次情報）

出典: 公式 README と CHANGELOG（`google-antigravity/antigravity-cli`、CHANGELOG 先頭は **1.2.7**）。

| 項目 | 内容 |
| --- | --- |
| コマンド | `agy` |
| macOS / Linux | `curl -fsSL https://antigravity.google/cli/install.sh \| bash` |
| Windows PowerShell | `irm https://antigravity.google/cli/install.ps1 \| iex` |
| Windows CMD | `curl -fsSL https://antigravity.google/cli/install.cmd -o install.cmd && install.cmd && del install.cmd` |
| 認証 | システムキーリング優先、無ければ Google Sign-In。ローカルはブラウザ自動起動、SSH 時は認可 URL を表示 |
| サインアウト | `/logout` |
| Enterprise | オンボーディング時に GCP プロジェクトを接続。起動バナーに Project ID と plan tier を表示（1.2.7） |
| ヘッドレス | `-p` / `--prompt`（実行して終了）、`--print-timeout` で上限指定 |
| ヘッドレス既定タイムアウト | 1.2.6 で 5 分 → **無制限**に変更（明示的に `--print-timeout` を渡した場合のみ上限） |
| ヘッドレス失敗時 | stderr に `AGY_ERROR: {...}`（canonical status / HTTP・gRPC code / retryability / error ID）を 1 行出力し、**終了コード 3** |
| API キー実行 | `GEMINI_API_KEY` セッションでヘッドレス実行可（バックグラウンド常駐コマンドもターン終了後まで維持） |
| リモート操作 | `--remote-control` 起動フラグ / `/remote-control` スラッシュコマンド（別デバイスから追従・操作、`off` またはセッション終了で自動切断） |
| 主なスラッシュコマンド | `/login` `/logout` `/model` `/usage` `/plugin` `/skills reload` `/resume` `/rewind` `/hooks` `/copy` `/btw` |
| 拡張性 | plugins、MCP サーバ（`mcp_config.json`）、skills、workflows、custom subagents、`hooks.json` |
| リスク表記 | README に「自律コード実行・データ持ち出し・prompt injection・サプライチェーン」のリスク警告あり。全アクションの監視・検証が前提 |
| データ利用 | 利用により Interactions データの収集・利用に同意したことになる。設定からオプトアウト可 |

## 3. 推測・未確認（二次情報。導入前に自分の環境で要確認）

- インストール先は `~/.config/Antigravity/bin`（Issue #354 の報告。XDG 違反として指摘されており**将来変わりうる**）。
  `scripts/setup-antigravity-cli.sh` はこのパスを既定にしつつ、`AGY_BIN_DIR` で上書きできる。
- 設定ファイル `~/.gemini/antigravity-cli/settings.json`、
  MCP は `~/.gemini/antigravity-cli/mcp_config.json`（グローバル）/ `.agents/mcp_config.json`（ワークスペース）。
- `AGENTS.md` をワークスペースのコンテキストとして読む（`GEMINI.md` 同様の扱い）。
- `--output-format json` / `stream-json`。**未検証のため `agy-run.sh` では既定で渡していない**。
  `agy --help` で存在を確認してから付けること。
- Issue #548: ヘッドレス（`-p`）が `permissions.allow` を参照せず承認待ちで停止する報告あり。
  完全無人実行は現状 `--dangerously-skip-permissions` が必要になりうる。

## 4. 導入手順（手元のマシン）

```bash
# 1. 導入（プリフライト・PATH 修復・検証込み）
./scripts/setup-antigravity-cli.sh          # 対話確認あり
./scripts/setup-antigravity-cli.sh --yes    # CI 用
./scripts/setup-antigravity-cli.sh --force  # 再実行＝アップグレード

# 2. 初回サインイン（マシンごとに 1 回）
agy            # 起動後 /login。SSH 経由なら表示された URL を手元ブラウザで開く

# 3. 動作確認
agy --version
./scripts/agy-run.sh "このリポジトリの構成を3行で要約して"
```

素の公式コマンドだけで入れたい場合は上表のワンライナーで足りる。本スクリプトの追加価値は
**ネットワーク遮断の早期検出・冪等性・PATH 自動追記・`AGY_ERROR` 検出**の 4 点。

## 5. ヘッドレス／CI での使い方

```bash
# 対話セッションの資格情報を使う（サインイン済みマシン）
./scripts/agy-run.sh --timeout 30m "テストを実行し、失敗があれば原因を要約して"

# CI：API キー＋無人承認
export GEMINI_API_KEY=...            # シークレットストア経由で注入する
AGY_ALLOW_DANGEROUS=1 ./scripts/agy-run.sh --timeout 30m "$(cat spec.md)"

# 仕様書をパイプで渡す
cat docs/spec.md | ./scripts/agy-run.sh --timeout 30m
```

終了コード: `0` 正常 / `2` 使用方法・セットアップ不備 / `3` agy 側のエージェント・モデル失敗
（`AGY_ERROR` 検出時を含む）/ それ以外は `agy` の終了コードをそのまま返す。
ログは `.agy-logs/<timestamp>.out.txt` と `.err.txt`。

## 6. リスクと代替案

| リスク | 内容 | 対策 |
| --- | --- | --- |
| `curl \| bash` 実行 | 公式ドメインとはいえ任意コード実行 | 本スクリプトは一旦ファイルへ落として空レスポンスを弾いてから実行。中身を読みたい場合は `curl -fsSL <URL> -o install.sh` して確認後に `bash install.sh` |
| `--dangerously-skip-permissions` | エージェントが自分でツール実行を承認する | 使い捨てコンテナ／専用ワークツリー限定。既定は OFF、`AGY_ALLOW_DANGEROUS=1` を明示した時だけ有効 |
| データ送信 | 既定で Interactions データが Google に送られる | 設定からオプトアウト。機密リポジトリでは事前に方針確認 |
| インストールパス変更 | `~/.config/Antigravity/bin` は upstream で議論中 | `AGY_BIN_DIR` で上書き可能にしてある |
| 本コンテナで導入不可 | egress ブロック | 手元マシンに導入し、`--remote-control` か `GEMINI_API_KEY` ヘッドレスで連携 |

代替案: 同じ委譲を Gemini CLI / Codex CLI で行う構成にも切り替えられる。`agy-run.sh` の呼び出し部分
（`agy "${args[@]}"`）を差し替えれば、上位の運用手順はそのまま流用できる。

## 7. 次アクション

1. 手元マシンで `./scripts/setup-antigravity-cli.sh` を実行し、`agy --version` を控える。
2. `agy --help` を貼ってもらえれば、`--output-format` などの未確認フラグを確定させ、
   `agy-run.sh` を実測に合わせて更新する。
3. 委譲したい作業があれば `skills/antigravity-cli/templates/AGENTS.md` を
   リポジトリ直下にコピーして埋める（Claude が仕様、`agy` が実装、という分担）。
