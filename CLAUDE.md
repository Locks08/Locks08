# Locks08/Locks08

GitHub プロフィール用リポジトリ 兼 **Claude Code プラグインの配布元（marketplace）**。

## このリポジトリは public

`Locks08/Locks08` は **public** リポジトリで、GitHub プロフィールページから見える。
ここに置くものは全世界に公開される前提で扱うこと。

具体的に、**ここにコミットしてはいけないもの**:

- 未公開作品の設定・原稿・プロット（ソラマシンの本編素材など）
- 価格設定、収益計画、KPI の実数値、プラットフォーム別の運用戦略
- Notion / Drive の URL や内部ドキュメントへのリンク
- API キー、voice_id などのアカウント固有の識別子

これらを含むスキルや設定は、**別の private リポジトリ**に置いて、そちらを
marketplace として登録する。判断に迷ったら public に置かない側に倒す。

ルートに `README.md` を作るとプロフィールページにそのまま表示される。意図せず
プロフィールを書き換えないよう、**頼まれていない限り `README.md` は作らない**。

## 構成

```
.claude-plugin/marketplace.json   marketplace の目録。プラグインを増やすときはここに追記
plugins/<name>/
  .claude-plugin/plugin.json      プラグインのメタデータ
  skills/<skill>/SKILL.md         スキル本体（+ references/, templates/）
CLAUDE.md                         このファイル
.claude/settings.json             このリポジトリで作業するときの権限設定
```

## 使い方（利用者側）

```
/plugin marketplace add Locks08/Locks08
/plugin install game-dev@locks08
/reload-plugins
```

Claude Code on the web では `/plugin` が使えない。ローカルの Claude Code CLI から実行する。

## プラグインを追加するときの手順

1. `plugins/<name>/skills/<skill>/SKILL.md` を作る（`description` は「いつ使うか」を具体的に書く。ここが発火精度を決める）
2. `plugins/<name>/.claude-plugin/plugin.json` に `name` とメタデータを書く
3. `.claude-plugin/marketplace.json` の `plugins` 配列に `{"name": ..., "source": "./<name>"}` を追記する
   - `metadata.pluginRoot` が `./plugins` なので `source` は `"./<name>"` でよい
4. 上流プロジェクトから流用したものは `LICENSE.txt` と `NOTICE.md` を同梱し、
   改変点を `NOTICE.md` に明記する（`plugins/game-dev/skills/game-dev/` が実例）

## スキルを書くときの原則

- **環境を偽らない。** 別環境（Manus、WebDev、その他）専用のツール名を、動かない環境向けのスキルに残さない。移植するときは、そのツールがこの環境の何に対応するかを表にして置き換える。
- **確認は実物で。** 「動くはず」ではなく、実際に動かした出力・スクリーンショットで確認する手順をスキル側に書く。
- 外向きの操作（デプロイ、公開、投稿、課金）は、明示的に頼まれたときだけ実行する、とスキル本文に書いておく。
- 参照ファイルは `references/` に分け、SKILL.md からは「そのステージに来たら読む」形で参照する。SKILL.md 本体を短く保つため。

## 言語

このリポジトリのドキュメント（CLAUDE.md, README 等）は日本語。
スキル本文（SKILL.md と references）は英語 — モデルへの指示であり、上流の godogen も英語のため。
