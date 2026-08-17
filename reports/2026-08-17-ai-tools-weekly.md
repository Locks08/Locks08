# 🛠️ ソラマシン制作 AIツール調査レポート（2026-08-17・週次差分）

> 調査日: 2026-08-17 ／ 比較基準: 2026-08-10 週次差分（直近レビュー） ／ 方針: 公式ソース最優先・**この1週間（08-10〜08-17）の差分**に集中・未検証は **UNCONFIRMED** 明記 ／ 価格は原則USD（1USD≒150円目安、多くは第三者集計＝各公式で最終確認）。
> ※注記: 今回の調査では Anthropic / ByteDance / Google / 各SaaS の一次ページの多くが調査環境のegress制限で直接取得できず、公式pricing docs・公式changelog・複数の二次ソースの一致で確度を判定している。数値の本番採用前は各公式コンソールで最終照合すること。

## 今週の結論（3行）
1. **スタックに実害のある変更が1件：Dashtoon Studio がサービス終了（2026-08-15）。** 「漫画/ウェブトゥーンのラフ下書き量産」枠（既存 score 79）が消滅。代替の即時選定が必要＝今週唯一の"強制対応"。
2. **先週のUNCONFIRMEDが2件、公式で確定。** ①Seedance 2.5 の料金がトークン課金として確定（＋「2.5に4Kは無い＝4Kは2.0」という前提訂正）②Claude Opus 5＝\$5/\$25・Fable 5＝\$10/\$50 が公式pricing docsで確定。動くログ自動化と司令塔移行のコスト前提が固まった。
3. **新規の便利機能が複数（吹替・音楽・Web）。** ElevenLabs **Dubbing v2**（音声保持の多言語吹替）、Suno **Studio 2.0**（MIDI対応DAW）、Vercel **v0 API GA**。いずれも即時の必須ではないが、多言語展開・OP/ED制作・LP量産の効率を押し上げる。**Fable 5.1 は今週も公式発表なし（噂の再拡散のみ）。**

## この1週間で対応すべき Top3
1. **【強制】Dashtoon 代替の即時選定** — 8/15終了。ラフ下書き工程を恒久的に別ツールへ移管。第一候補＝**NovelAI V4.5（キャラ配置グリッド）＋Seedream 4.5（低コスト量産）でCSP仕上げ**の既存ラインに吸収。Dashverse系の後継 Frameo（AIショートドラマ寄り）は用途がズレるため様子見。過去にDashtoonへ保存したラフ資産があれば回収可否を確認。
2. **Seedance 2.5 の本番予算化（UNCONFIRMED解消）** — 公式トークン課金が判明：BytePlus（国際）**動画入力なし \$10.70／動画入力あり \$6.40（per 100万トークン）**、公式例 5秒720p≈¥7.56。**重要訂正：2.5の公開ティアは480p/720pのみで4Kは非対応**（4Kが要るカットは Seedance 2.0 を併用）。先週始めた「Mode A手動→API化＋n8nバッチ」をトークン課金前提で実測1本→本番組込みへ。
3. **ElevenLabs Dubbing v2 の評価導入** — 8/10提供開始。**speech-to-speech（音声→音声）**で話者の声・トーン・ペースを保持したまま90言語以上へ吹替。翻訳を編集可能JSONで保持し変更区間だけ再生成。Webtoon/TikTokの海外展開でキャラ声を保った多言語化に直結（character-voice-spec と親和）。Fish Audio S2.1 のクロスリンガルと役割が競合/補完＝要比較。

## 様子見（Defer）※先週から据え置き＋今週分
- **Fable 5.1**（8月中との噂・**UNCONFIRMED**／今週も公式発表なし。8/13の"Sonnet 5.5 Fennec + Opus 6"リーク動画は年初リークの焼き直しで根拠薄弱）。
- **Suno v6**（未確定・v5.5継続。ただしBMGライセンス提携8/12・**9/3から月間DL上限導入**は運用監視）。
- **Suno Studio 2.0**（8/13・MIDI/シンセ/chat bar）＝Premier限定・VST非対応。OP/EDでMIDI持込み生成の価値はあるが必須ではない＝試験。
- **Vercel v0 API GA**（8/13）／**Framer AI**（8/12・推論選択＋Fast mode）＝LP量産自動化の候補、PoC止まりで様子見。
- Gemini Omni・Veo後継（API解禁待ち）／GPT-5.6・Runway Gen-4.5・Hailuo・Wan・Udio・Lyria 3.5・Hume Octave 2・FLUX.2/FLUX 3・Firefly・Bolt.new・Wix/Webflow AI・Gumroad・Patreon・World Anvil・Campfire。

## 置換候補（Replacement）※今週の新規/更新分
| 既存 | 置換/更新先 | 理由 |
|---|---|---|
| **Dashtoon Studio（ラフ下書き・score 79）** | NovelAI V4.5＋Seedream 4.5 → CSP仕上げ（Frameoは様子見） | 2026-08-15サービス終了。下書き量産枠を既存ラインへ恒久移管 |
| **Seedance：4K想定を2.5に紐付け** | 4Kは Seedance 2.0 を併用 | 2.5は480p/720pのみ。4Kは2.0側の機能（広く混同）。用途で使い分け |
| **Claude Sonnet 5 のコスト前提（暫定）** | \$2/\$10 で恒久確定（9/1値上げ中止） | 脚本の低コスト下書き/大量処理・フォールバックに正式採用可 |
| CapCut（据え置き） | Descript＋Opus Clip | 先週から変更なし（永続ライセンス条項リスク継続） |

---
# 工程別・差分（14工程）
凡例: 優先度＝最優先/高/中/低 ・ スコア＝100点満点 ・ 推奨＝今すぐ/試験/様子見/不要

## 1. 企画・構成（Planning）— ⚠️ 更新あり（価格確定）
- **Claude Opus 5**｜最優先｜94｜継続（司令塔）— 先週UNCONFIRMEDだった公式料金が **\$5/百万入力・\$25/百万出力（Opus 4.8と同額）／Fast mode \$10/\$50** で公式pricing docsに確定。スコア・方針は据え置き妥当。
- Claude Opus 4.8（既）｜高｜90｜継続（フォールバック）— 変更なし。
- Gemini 3.1 Pro（既）｜高｜83｜変更なし（公式doc更新は記載のみ）。
- Notion AI Business（既）｜高｜84｜変更なし。

## 2. 脚本（Scriptwriting）— ⚠️ 更新あり（価格確定・監視継続）
- **Claude Fable 5（既）**｜最優先｜95｜継続（本編執筆の第一線）。公式料金 **\$10/\$50** 確定。安全分類器の誤検知→Opus系フォールバック経路の確保は**引き続き必須**。
- **Claude Sonnet 5**｜中〜高｜（試験）— **導入価格 \$2/百万入力・\$10/百万出力が恒久化**。当初9/1予定の \$3/\$15 値上げは**実施されない**ことが公式pricing docsで確定（バッチ \$1/\$5）。脚本の低コスト下書き・大量処理・フォールバック層に正式採用可。
- 🔭 **Fable 5.1**：8月中リリースの噂＝**今週も公式発表なし・UNCONFIRMED**。8/13のリーク再拡散は根拠薄弱。WATCH継続。
- Sudowrite / AIのべりすと：今週変更なし。

## 3. 世界観設計（World-building）— 変更なし（要名称修正）
- NotebookLM｜最優先｜90｜今すぐ。**※2026-07-16に「Gemini Notebook」へ改称済み（今週ではない既往変更・UNCONFIRMED寄り）**＝レジストリの名称更新を推奨。World Anvil / Obsidian 二層運用は据え置き。

## 4. ナレッジ管理（Knowledge management）— 小幅更新あり
- Notion AI Business（既）｜高｜84 ／ NotebookLM（→Gemini Notebook）｜最優先｜90。
- **Notion Developer Platform（Workers／External Agents API）**：無料ベータが **2026-08-11で終了→Notion creditsで課金開始**。NotionにClaudeエージェントを常駐させる構成を使う場合はcredit消費を試算。機能自体は新規ではないため緊急対応は不要。

## 5. キャラクターデザイン（Character design）— 変更なし
- Nano Banana Pro｜最優先｜93 ／ NovelAI Diffusion V4.5｜最優先｜90。両者とも今週変更なし。

## 6. 画像生成（Image generation）— 変更なし（次回精査項目あり）
- Nano Banana Pro｜93 ／ NovelAI V4.5｜90 ／ Seedream 4.5｜84 ／ FLUX.2｜80。順位・推奨とも据え置き。
- 次回精査：**Seedream 5.0 Pro（7/23発表・週外）** が登場＝低コスト量産枠の見直し候補。**FLUX 3 Video GA（8/5・週外）** は動画寄りで画像枠への即時影響は限定的。

## 7. 漫画・ウェブトゥーン（Manga/Webtoon）— ⚠️ 重大更新あり（ツール終了）
- Clip Studio Paint｜最優先｜92（最終制作の母艦）｜据え置き。**※5.1.2（Windows・8/6・週外）** リリース済み＝次回ベースラインでバージョン反映。
- **Dashtoon Studio（既→終了）**｜—｜**不要（サービス終了）**｜**至急対応** — **2026-08-15にシャットダウン**（新規作成は無効化済み）。親会社はAIショートドラマ（Dashverse/Frameo）へ事業転換。ラフ下書き量産枠を **NovelAI V4.5＋Seedream 4.5 → CSP仕上げ** の既存ラインへ恒久移管。過去ラフ資産の回収可否を確認。

## 8. 動画生成（Video generation）— ⚠️ 更新あり（価格確定・前提訂正）
- **Seedance 2.5（既）**｜最優先｜92｜今すぐ（API本番移行を継続）— **API本稼働化を確認**（BytePlus ModelArk公式doc最終更新 8/13）。**公式トークン課金が判明：BytePlus 動画入力なし \$10.70／あり \$6.40（per 100万トークン）**、Volcano Engine ¥70/¥42、公式例 5秒720p≈¥7.56。**訂正：2.5は480p/720pのみで4K非対応（4Kは2.0）**。先週の「秒単価/4K UNCONFIRMED」は**解消**。トークン課金で見積り再計算し公式コンソールで実測1回→本番組込み。
- Kling 3.0｜最優先｜92｜今すぐ（据え置き。今週変更なし）。
- Google Veo 3.1｜高｜85 ／ Higgsfield（既）｜高｜82 ／ HeyGen（既）｜中〜高｜78 — いずれも今週変更なし（Veo 4は非存在／後継はGemini Omni Flash系、API解禁待ち）。
- **OpenAI Sora 2**｜低｜40｜**不要**（退役スケジュール不変：App終了済み／API 2026-09-24終了予定）。

## 9. 音声（Voice）— ⚠️ 更新あり（新API）
- **ElevenLabs v3（既）**｜最優先｜92｜今すぐ（基盤）。**新規：Dubbing v2（8/10）** — speech-to-speechアーキテクチャで声・トーン・ペースを保持し90言語以上へ吹替、翻訳は編集可能JSONで区間再生成、地域アクセント/BGM/複数話者処理を改善（SDK v2.62.0）。多言語展開の吹替に評価導入。先週のVoice Design/Agent Workflowsは大きな追加なし（VAD/検索フィルタ程度）。
- **Fish Audio S2.1 Pro**｜高｜85｜据え置き。**※ベースライン表記は「S2 Pro」だが実体は S2.1 Pro。無料API（`s2.1-pro-free`）が 8/31まで延長中**＝表記更新推奨。Dubbing v2 との日本語クロスリンガル比較を推奨。
- Gemini Flash TTS / Hume Octave 2：今週変更なし。

## 10. 音楽（Music）— ⚠️ 更新あり（制作環境の刷新）
- **Suno v5.5（既）**｜最優先｜90（anime OP/ED専用タグ）｜据え置き。**新規：Suno Studio 2.0（8/13）** — ブラウザ版DAWの大型刷新。**MIDI対応**（インポート/録音/タイムライン、MIDIクリップをプロンプト化）、wavetableシンセ、chat bar(beta)、オーディオエフェクト、高精度ステム分離。**Premier限定・VST/AU非対応**。OP/EDでMIDI持込み→生成を試験。
- 運用注意：**Suno–BMGライセンス提携（8/12）**、**9/3から月間DL上限導入（Studioは対象外）**＝制作ペースに影響しうるため監視。**Suno v6は今週も未リリース（UNCONFIRMED）**。
- ElevenLabs Music｜高｜82 ／ Lyria｜今週変更なし（直近3.5は7/29・週外）。

## 11. 編集（Editing）— 変更なし
- Descript｜高｜83（最新changelog 8/5・週外）／ Opus Clip｜高｜86 ／ Canva（既）継続。CapCut｜中｜62｜脱却検討（永続ライセンス条項リスク継続）。今週いずれも変更なし。

## 12. LP・Web制作（LP/Website）— 小幅更新あり
- Lovable（既）｜最優先｜88（公式サイト/会員/決済）＋Stripe｜83。**注意：2026-09-09以降、Free/ProプランのデータがAIモデル学習に使われる可能性→Privacy設定でオプトアウト可（Business/Enterpriseは既定で対象外）。9/9前に要否判断。** 週内に障害2件（8/10・8/14）ありいずれも復旧済み。
- **Vercel v0｜高｜82** — **v0 API がGA（8/13）**。プロンプト→アプリ生成/改修→Sandbox実行→プレビューURLを自社UI/n8nから叩ける。LP量産自動化のPoC候補。
- **Framer AI｜高｜80** — AI Agentに**推論量選択（Light/高推論）＋Fast mode**追加（8/12）。LP微修正はLight/Fast、構成作成は高推論とコスト配分をルール化。

## 13. 自動化（Automation）— 更新あり（バージョンUP・期限対応）
- **n8n｜最優先｜87** — 週内に **2.35.0（8/11）／2.35.3（8/14）** リリース。AIエージェントの応答漏れ・認証情報不一致・過大なツール結果の修正、MCPスキーマ改善、Teams OAuth修正等。**セルフホストを2.35.3へ更新推奨（更新前にバックアップ）**。Seedance 2.5 APIバッチの組込みは継続課題。
- **Zapier（併用時）** — OpenAI Assistants APIステップ廃止、既存Zapは**2026-08-26まで**。併用しているなら今週中に洗い出し→Responses APIへ差替え。
- Make.com｜今週変更なし。

## 14. 販売・収益化（Sales/Monetization）— 変更なし（＝重要な"無風"）
- note（既）｜最優先｜85 ／ BOOTH｜高｜78 ／ Stripe｜高｜83 ／ Ko-fi｜79 ／ pixivFANBOX｜72。
- **監視対象プラットフォームのAIコンテンツ規約は今週いずれも変更なし**（pixivFANBOX＝AI生成禁止継続／note＝AI+人間協働可・冒頭開示／BOOTH＝人間主体ならAI補助可／Ko-fi・DLsite・TikTok・Webtoon・Gumroad・Patreon も週内変更なし）。**販売先の使い分け設計は先週のまま維持でよい＝今週の最重要結論の一つ。**
- 横断監視（週外だが恒常）：**EU AI Act 第50条（AI生成物の機械可読な開示義務）が 2026-08-02 施行**。EU向け配信では来歴表示（C2PA等）が論点。note/TikTok等のAI開示運用と併せて恒常的に留意。

---
# 対応期限カレンダー（今週判明分）
| 期限 | 項目 | アクション |
|---|---|---|
| 2026-08-15（済） | Dashtoon Studio 終了 | 過去ラフ資産の回収可否確認・下書き工程を代替へ移管 |
| 2026-08-26 | Zapier OpenAI Assistants ステップ廃止 | 併用Zapを Responses API へ差替え |
| 2026-08-31 | Fish Audio S2.1 Pro 無料API終了 | 無料枠で日本語クロスリンガル比較を前倒し |
| 2026-09-03 | Suno 月間DL上限導入 | DL運用の見直し（Studioは対象外） |
| 2026-09-09 | Lovable データAI学習利用開始 | Privacy設定でオプトアウト要否を判断 |

---
# まとめ
**今週対応すべきTop3**：① Dashtoon終了への代替即時選定（強制）② Seedance 2.5 の本番予算化（公式料金確定・4Kは2.0併用）③ ElevenLabs Dubbing v2 の評価導入（音声保持の多言語吹替）。
**様子見**：Fable 5.1（今週も発表なし）・Suno v6・Suno Studio 2.0・Vercel v0 API/Framer・Gemini Omni/Veo後継。
**置換候補**：Dashtoon→NovelAI V4.5＋Seedream 4.5（CSP仕上げ）／Seedance 4K用途→2.0併用／Sonnet 5コスト前提→\$2/\$10恒久確定。
**総評：地殻変動はなくスタックは安定。ただし今週は"実害1件（Dashtoon終了）"と"UNCONFIRMED2件の公式確定（Seedance料金・Opus5/Fable5料金）"で、実務アクションは「①下書き工程の移管 ②Seedance本番化 ③吹替v2評価」の3点、加えて上表の対応期限の管理に集約される。販売系AI規約が全プラットフォーム無風＝販売設計は現状維持でよい。**

---
# 未確定・要公式確認（UNCONFIRMED）
- **Fable 5.1**（8月中リリースの噂・今週も公式発表なし）、Suno v6の名称/日付。
- Seedance 2.5 のトークン課金レートは第三者集約経由確認（BytePlus/Volcengine公式コンソールで本番前に最終照合）。Vercel v0 API・Framer更新の日付は公式ページ本体未取得（確定寄り）。
- NotebookLM→「Gemini Notebook」改称（7/16・二次ソース中心＝UNCONFIRMED寄り）。
- 要ベースライン修正（今週発ではないが未反映）：Fish Audio「S2 Pro」→実体は S2.1 Pro／「ElevenLabs Creative Studio 3.0」は実在未確認のため削除／Clip Studio Paint 5.1.2（8/6）／Seedream 5.0 Pro（7/23）・FLUX 3 Video GA（8/5）。
- LLM/画像モデル料金の多くは公式pricing docsまたは第三者集計由来。導入前に各公式で最終確認を。

*※本差分は2026-08-17のWeb調査に基づく。確度は各項の注記のとおり。一次ページの多くがegress制限で直接取得できず、公式docs/changelog＋複数二次ソースの一致で判定している。*
