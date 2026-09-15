---
name: soramachine-visual-spec
description: >-
  ソラマシンのビジュアル資産（キャラ立ち絵・note/BOOTHのアイキャッチ・Webtoonコマ・タロットアート）を
  Lovart経由で生成し、キャラの見た目とアートスタイルの一貫性をレジストリで固定するスキル。
  「立ち絵」「キャラデザ」「アイキャッチ」「サムネ」「Webtoon」「コマ」「表紙」「カード絵」「画像作って」
  「ビジュアル」「同じキャラで」などソラマシン文脈の画像生成要求が出たら必ず使う。
  キャラごとに Lovart asset library の subject（asset_id + library URL）を一度確定して visuals.yaml に登録し、
  以降の全生成は --subjects でそれを引くことで顔と衣装のブレを防ぐ。character-voice-spec の画像版。
---

# Soramachine Visual Spec

キャラの声がブレるとIPの信頼が落ちるのと同じで、**顔と画風がブレると資産にならない**。
このスキルは `character-voice-spec` と同じ構造を画像側に適用する。

| 系統 | レジストリ | 実行エンジン | 管理スキル |
|---|---|---|---|
| 声 | `voices.yaml` | ElevenLabs | character-voice-spec |
| **絵** | **`visuals.yaml`** | **Lovart (`lovart-api` skill)** | **このスキル** |

生成そのものは `lovart-api` skill が行う。このスキルは**何を・どの参照で・どの命名で作るか**を決める層であり、
Lovart API を直接叩かない（`lovart-api` の RULE #0 に従い、必ずそのコマンド経由）。

## 前提：唯一の真実は canon.yaml

キャラの外見・衣装・色・世界観のビジュアル語彙は `soramachine-canon/canon.yaml` から導く。
**ここで新しい設定を発明しない。** canon が TBD のキャラは暫定値に `DRAFT` を付け、確定はユーザー承認を待つ。
canon と食い違う既存アセットを見つけたら、直す前に**ユーザーへ矛盾を報告**する。

> ⚠️ 現状 `canon.yaml` は未作成。作成されるまで、このスキルが生成するものは全て `DRAFT` 扱いとし、
> CANON 昇格（= `visuals.yaml` への確定登録）はユーザー承認を必須とする。

## ネタバレ管理（必須ガード）

`note-article-factory` / `yukino-tarot-engine` と同じ基準を画像にも適用する。

- **公開画像（note無料 / TikTok / X / Threads / BOOTH商品ページ）に出してよいのは spoiler level F / B まで。**
- A は注意書き付きで限定的に（FANBOX等のクローズド面）、**S は公開画像に一切出さない**。
- 未登場キャラ・未公開ガジェット・終盤の情景は、無料面のアイキャッチに使わない。
- AI が独断で spoiler level や canon status を上げない。迷うものは外してユーザーに確認。

## 絶対ガード｜アート権利

- 使用アートは**オリジナル / AI生成 / 商用ライセンス済み**のみ。
- 既存作家・既存作品の画風を名指しで模倣するプロンプトを書かない（"in the style of ○○" 禁止）。
  画風は `visuals.yaml` の `style_lock` に**自分の言葉で記述した語彙**で固定する。
- 既存タロットデッキの絵柄を複製しない（`yukino-tarot-engine` と同じ制約）。
- 実在人物の顔を参照に使わない。

---

## レジストリ｜visuals.yaml（このスキルが管理する成果物）

キャラ・画風ごとに一度だけ確定し、以降の全生成はこの値を引く。雛形は `templates/visuals.yaml`。

一貫性の技術的な核は Lovart の **`--subjects`**（asset library の承認済み参照）。
`--attachments` は毎回モデレーション再審査が走る使い捨て入力なので、**確定キャラには使わない**。

```yaml
style:
  global:
    style_lock: "（画風を自分の言葉で。作家名を使わない）"
    negative: "（毎回除外したい要素）"
    palette: ["#______", "#______"]   # canon の色設計に従う
    status: DRAFT

characters:
  yukino:
    display: "Yukino"
    role: "夢・妖精の欠片／占い導線"
    subject:
      asset_id: ""        # Lovart asset library の ID（確定後に1度だけ記入）
      url: ""             # 同 library URL
      display_name: "Yukino"
      channel: ""
    appearance_lock: "（canon準拠の外見記述。ここで発明しない）"
    spoiler_level: F
    status: DRAFT         # DRAFT → CANON はユーザー承認後
```

### 確定までの手順（キャラ1体につき1回だけ）

1. `lovart-api` で候補を複数生成（この時点では `--attachments` でも可）
2. ユーザーが1枚を選定
3. 選定画像を Lovart の asset library に登録し、`asset_id` と library URL を取得
4. `visuals.yaml` に記入し、ユーザー承認で `status: CANON`
5. **以降そのキャラの生成は必ず `--subjects` でこの asset を渡す**

確定後に `visuals.yaml` の subject を無断で差し替えない。差し替えはキャラの顔が変わることと同義。

---

## 用途別パイプライン

3系統の具体手順・アスペクト比・命名は `references/pipelines.md` を参照。要点のみ以下。

| 用途 | 比率 | subject | 置き場 |
|---|---|---|---|
| キャラ立ち絵 / 設定画 | 1:1 or 3:4 | 確定元（これ自体が subject になる） | 資料・FANBOX |
| note / BOOTH アイキャッチ | 16:9 | 必須 | note・BOOTH・X |
| TikTok 縦 | 9:16 | 必須 | TikTok・Threads |
| Webtoon コマ | 縦長連結 | 必須（複数キャラは複数 subject） | Webtoon |
| タロットカード絵 | 2:3 | ユキノのみ必須 | BOOTH・FANBOX |
| lipsync 用 立ち絵 | 1:1 | 必須 | 動くログ（下記） |

### character-voice-spec との接続（重要）

`character-voice-spec` は lipsync 用に**正面・口元クリア・透過PNG**を要求する。
このスキルで lipsync 素材を作るときは、その3条件をプロンプトに明示し、
生成後に条件を満たしているか目視確認してから声側へ渡す。満たさない絵を渡すと lipsync が破綻する。

---

## 実行ルール（lovart-api への委譲）

`lovart-api` skill のルールに全面的に従う。特に：

1. **初回は必ず `config --json` → `threads --json`** を先に実行。既存プロジェクト・スレッドを再利用する。
   ソラマシン用プロジェクトは1つに固定し、用途ごとにスレッドを分ける（立ち絵 / アイキャッチ / Webtoon）。
2. **`failures` を必ず確認。** 空でなければ「参照が落とされた／モデルが差し替わった」可能性がある。
   subject が弾かれた生成は**キャラの顔が変わっている**ので、成功として扱わずユーザーに報告して作り直す。
3. **`generation_succeeded: false`** のときは `warning` と `agent_message` をそのままユーザーに見せる。
   長く複雑なプロンプトはモデレーションに引っかかりやすいので、短く割って再試行する。
4. **動画・高コスト生成は `pending_confirmation` で必ず停止**し、クレジット消費前にユーザーへ確認する。自動承認しない。
5. コスト方針：探索フェーズは `set-mode --unlimited`（無料・キュー待ち）、
   締切のある確定生成のみ `--fast`（クレジット消費）。切り替えはアカウント全体に効く永続設定なので、変更したら必ず伝える。

## 命名規約（生成物のファイル名）

```
sora_{用途}_{キャラ}_{内容}_{YYYYMMDD}_{連番}.{ext}
例) sora_eyecatch_yukino_tarot-jan_20260915_01.png
    sora_ref_grim_front-lipsync_20260915_01.png
```

用途キー：`ref`(設定画) / `eyecatch` / `vertical` / `webtoon` / `tarot` / `cover`

## 品質チェック（納品前に必ず）

- [ ] canon と矛盾していないか（矛盾は修正前に報告）
- [ ] spoiler level は置き場に対して適正か（公開面は F/B のみ）
- [ ] `--subjects` を渡したか（確定キャラの場合）
- [ ] `failures` は空か／空でなければ報告したか
- [ ] 作家名・既存作品名をプロンプトに使っていないか
- [ ] lipsync 用なら 正面・口元クリア・透過PNG を満たすか
- [ ] 命名規約に沿っているか

## ログ連携

生成で詰まった点・モデレーションで弾かれたプロンプト傾向は、`ops-kpi-log` の日次3行ログへ流す。
ただし**日次ログに整形要件を足さない**（摩擦ゼロを死守）。1行でよい。
