# soramachine-canon

ソラマシンの**唯一の真実**。`canon.yaml` 1ファイルが本体。

## なぜ必要か

`skills/` 配下の5スキルが揃って「唯一の真実は canon.yaml」と宣言している。
つまりこのファイルが無い限り、5スキルは全て土台なしで動くことになる。
キャラの性格・外見・用語の定義がスキルごとにバラけ、記事・画像・声が食い違う。

```
                    canon.yaml
                        │
   ┌────────────┬───────┴───────┬─────────────┬──────────────┐
   │            │               │             │              │
character-  soramachine-    note-article-  yukino-tarot-  ops-kpi-log
voice-spec  visual-spec     factory        engine
   │            │               │             │              │
 声の設計     絵の設計        記事の整形     商品の生成    要決定の流し先
(voices.yaml)(visuals.yaml)
```

## フィールドの消費先

| canon のフィールド | 引くスキル | 使われ方 |
|---|---|---|
| `characters.*.personality` / `speech` / `emotion_range` / `voice_direction` | character-voice-spec | ElevenLabs の stability / style / speed を決める根拠 |
| `characters.*.appearance` / `palette`, `world.palette` | soramachine-visual-spec | `visuals.yaml` の `appearance_lock` / `style_lock` の根拠 |
| `characters.*.revenue_role` | note-article-factory | 記事タイプごとの担い手キャラ選定 |
| `characters.yukino.speech`, `terms.*` | yukino-tarot-engine | ユキノの口調・世界観語彙 |
| `*.spoiler_level`, `spoiler_levels` | note-article-factory / visual-spec / tarot-engine | 公開面に出してよいかの判定 |
| `open_questions` | ops-kpi-log | 日次ログで出た「判断保留」の積み先 |

## 編集ルール（全スキル共通）

1. **値を埋めてよいのは作者本人のみ。** AIは空欄を推測で埋めない。
2. **AIは `status` / `spoiler_level` を独断で上げない。** DRAFT → CANON は作者承認が必要。
3. **記事や画像が canon と食い違ったら、canon を直すのではなく先に報告する。**
   つじつま合わせで canon を書き換えるのが最も危険。
4. **決められない項目は空のまま残す。** 空欄は「未決定」という情報であり、埋めるべき欠陥ではない。
5. **判断保留が出たら `open_questions` に積む。** AIは項目の追加はしてよいが、答えは書かない。

## status

| 値 | 意味 | 公開物への使用 |
|---|---|---|
| `TBD` | 未着手 | 使わない |
| `DRAFT` | 暫定値。変わりうる | 要注意。変更時に作り直しが発生しうる |
| `CANON` | 作者承認済み・確定 | 可 |

## 埋める順序（推奨）

依存関係の下流ほど後回しでよい。**上から3つが埋まれば制作が動き出す。**

1. ~~`open_questions` Q1〜Q3 の解消~~ — **完了（2026-09-15）**
2. **`characters.yukino`** の `speech` / `appearance` — 第一商品（タロット）が直接待っている
3. **`world.logline` / `tone` / `palette`** — 画風ロックと記事トーンの根拠
4. `terms.*` の `definition` と `spoiler_level` — 記事を書き始める前に
5. `characters` の残り — 登場順・使用頻度の高い順に（ネロ → グリム → アロコスアークライド → ゼクス → カイ）
6. `arcs` — 公開範囲が動くたびに更新

## 構文チェック

```bash
python3 -c "import yaml; yaml.safe_load(open('soramachine-canon/canon.yaml')); print('OK')"
```

## 現在の状態（2026-09-15）

**確定（CANON）**
- `naming` … 作品表記は日本語に統一。技術識別子（YAMLキー / ファイル名 / Lovart の display_name / ElevenLabs ラベル）は ASCII
- `spoiler_levels` … F=Free / B=Basic / A=Advanced / S=Secret。重要度ではなく「情報の所在」で判定
- `characters.aro.canonical` … アロコスアークライド

**未着手**
- 全キャラの `personality` / `speech` / `appearance` 等の中身
- `world` / `terms` の定義
- `arcs`

**要決定**：Q4（レイラの役割）/ Q5（ネファの公開可否）/ Q6（音写の確認と主人公の短縮形）
解決済み Q1〜Q3 は履歴として `open_questions` に残してある。
