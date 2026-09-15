# 用途別パイプライン（具体手順）

`{S}` = `~/.claude/skills/lovart-api/scripts/agent_skill.py`
全コマンドは `lovart-api` skill 経由。API を直接叩かない。

## 共通：セッション開始時に必ず1回

```bash
python3 {S} config  --json     # active_project の確認（無ければユーザーに確認）
python3 {S} threads --json     # 再利用するスレッドの確認
```

探索フェーズはクレジットを使わない：

```bash
python3 {S} set-mode --unlimited   # 無料・キュー待ち。確定生成時のみ --fast へ
```

---

## Pipeline 1｜キャラ確定（立ち絵 / 設定画）— キャラ1体につき1回

これが全ての土台。ここが決まらないと他の全パイプラインが走らない。

**Step 1. 候補生成（3〜4案）**

```bash
python3 {S} chat \
  --prompt "<appearance_lock>。全身立ち絵、正面、無背景。<style_lock>。<negative>を含めない" \
  --json --download
```

**Step 2. ユーザーが1枚選定** — ここは必ず人間が決める。AI が勝手に確定しない。

**Step 3. 選定画像を asset library へ登録し、`asset_id` と library URL を取得**

```bash
python3 {S} upload --file <選定画像のパス>
```

**Step 4. `visuals.yaml` に記入 → ユーザー承認で `status: CANON`**

**Step 5. 表情差分・角度差分**（確定 subject を参照して派生させる）

```bash
python3 {S} chat --thread-id <ref_thread> \
  --subjects '[{"url":"<url>","asset_id":"<asset_id>","display_name":"Yukino"}]' \
  --prompt "同一キャラの表情差分4種（平静 / 微笑 / 憂い / 驚き）。構図と衣装は変えない" \
  --json --download
```

**Step 6.（必要な場合）lipsync 用素材**

```bash
python3 {S} chat --thread-id <ref_thread> \
  --subjects '[{...}]' \
  --prompt "同一キャラのバストアップ、正面、口元がはっきり見える、背景透過PNG" \
  --json --download
```
→ 生成後、**正面・口元クリア・透過** の3条件を目視確認してから `character-voice-spec` へ渡す。

---

## Pipeline 2｜note / BOOTH アイキャッチ（16:9）

`note-article-factory` が記事を出力したら、そのタイトルとテーマを受けてここへ繋ぐ。

```bash
python3 {S} chat --thread-id <eyecatch_thread> \
  --subjects '[{"url":"<url>","asset_id":"<asset_id>","display_name":"<キャラ>"}]' \
  --prompt "16:9 横長のアイキャッチ。<キャラ>が<記事テーマの情景>。<style_lock>。文字は入れない" \
  --json --download
```

- **文字は画像に焼き込まない。** note のタイトルと重なるため。文字入れが必要なら別レイヤーで後乗せ。
- 記事の spoiler level を確認し、**無料記事のアイキャッチは F/B のみ**。
- 担い手キャラは `note-article-factory` のロール表に合わせる（入口=Nero / 解析=Grim / 深掘り=Zeks / 商品=Yukino）。
- TikTok 用に 9:16 が要るときは、同スレッドで比率だけ変えて追加生成する（世界観が揃う）。

---

## Pipeline 3｜Webtoon コマ

最も破綻しやすい。**1コマ1生成**で積み、まとめて1枚に生成させない。

```bash
# 単独キャラのコマ
python3 {S} chat --thread-id <webtoon_thread> \
  --subjects '[{"url":"<A_url>","asset_id":"<A_id>","display_name":"Aro"}]' \
  --prompt "<コマの情景>。<variants.webtoon.style_lock>。セリフ・吹き出しは入れない" \
  --json --download

# 複数キャラが映るコマ（subject を複数渡す）
python3 {S} chat --thread-id <webtoon_thread> \
  --subjects '[{"url":"<A_url>","asset_id":"<A_id>","display_name":"Aro"},
               {"url":"<B_url>","asset_id":"<B_id>","display_name":"Yukino"}]' \
  --prompt "AroとYukinoが向かい合って会話している。<variants.webtoon.style_lock>" \
  --json --download
```

- **セリフ・吹き出しは画像に焼かない。** 後工程で乗せる（修正コストが段違い）。
- 同一スレッドを使い続けることで、Agent が直前のコマを記憶し画風が揃う。
- コマ間で光源・時間帯・場所が変わる場合はプロンプトに明示する。
- `failures` が非空 = subject が落ちた可能性 → **そのコマはキャラの顔が違う**。破棄して再生成する。

---

## Pipeline 4｜タロットカード絵（2:3）

`yukino-tarot-engine` の商品用。**既存デッキの絵柄を複製しない**（オリジナル解釈のみ）。

```bash
python3 {S} chat --thread-id <tarot_thread> \
  --subjects '[{"url":"<yukino_url>","asset_id":"<yukino_id>","display_name":"Yukino"}]' \
  --prompt "2:3 縦、カード絵。<カードの象徴をソラマシンの語彙で再解釈した情景>。<variants.tarot.style_lock>" \
  --json --download
```

- カード名・既存デッキ名をプロンプトに書かず、**象徴を自分の言葉で**記述する。
- 無料1枚引き用の絵は F/B のみ。有料/FANBOX 用は A まで可（要ユーザー判断）。
- 12ヶ月分をFANBOXへ転用する前提なので、**同一スレッドで通して作る**と画風が揃う。

---

## 動画（動くログ / TikTok）

1. 静止画をこのスキルで確定
2. 動画化は `pending_confirmation` で必ず停止 → **クレジット確認をユーザーに取ってから** `confirm`
3. 音声は `character-voice-spec` の voices.yaml に従って ElevenLabs 側で生成し、Seedance へ reference 入力（Mode A）

```bash
python3 {S} confirm --thread-id <thread_id> --json --download   # ユーザーが yes と答えた後にのみ実行
```

---

## トラブル対応早見表

| 症状 | 原因 | 対応 |
|---|---|---|
| `failures` が非空 | 参照が弾かれた / モデル差し替え | 成功扱いにしない。ユーザーに報告し再生成 |
| `generation_succeeded: false` | モデレーション / 長すぎるプロンプト | `warning` と `agent_message` を提示。プロンプトを短く割る |
| 顔が違う | `--subjects` を渡していない / 落ちた | subject を確認して再生成 |
| 画風がバラつく | スレッドを分散させた | 用途スレッドに統一して積む |
| HTTP 409 | 同スレッドで別タスク実行中 | `status` で完了を待つ |
| HTTP 402 | クレジット / 課金 | `AgentSkillError.message` をそのまま提示 |
