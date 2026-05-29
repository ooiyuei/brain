#requires -Version 5.1
$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$brain = "C:\Users\Owner\business\brain"
$dispatcher = "$brain\scripts\dispatch.ps1"

# ============================================================
# Overnight Wave: 80+ tasks across all departments
# ============================================================
$tasks = @(
    # ===== RESEARCH 30件 (競合/市場/業界) =====
    @{ d="research"; w="research"; t="AIpaX 競合6社徹底比較"; p="# タスク: AIコンサル業界 競合6社徹底比較`n対象: アクセンチュア/PwC/EY Strategy/野村総研/ABEJA/PKSHA Technology`n各社: サービス内容/価格帯/ターゲット/強み/弱み/AIpaXとの差別化`n表形式比較・各300字以上`n[[entities/aipax]]" },
    @{ d="research"; w="research"; t="Testall 競合5社2026最新"; p="# タスク: 受験系AIアプリ競合5社2026最新動向`n対象: Studyplus Planning/atama+/Monoxer/Z会/N予備校`n各: 直近半年の機能更新/価格改定/ユーザー数/マーケ動向/Testallが勝てる隙間`n[[entities/testall]]" },
    @{ d="research"; w="research"; t="AIpa Web 競合5社比較"; p="# タスク: 採用サイト制作競合5社`n対象: engage(en-japan)/Wantedly/Workteria/IndeedCV/Talent Cloud`n各: プラン/月額/制作スピード/AI活用度/AIpa Webとの差別化点`n[[entities/aipa-web]]" },
    @{ d="research"; w="research"; t="EEMUS 競合4サービス"; p="# タスク: 高校生×企業マッチング系競合4社`n対象: マイナビ高校生/dodaキャンパス/PaiZA Step/インターンシップガイド`n各: 機能/価格/普及率/EEMUSとの差別化`n[[entities/eemus]]" },
    @{ d="research"; w="research"; t="2026年AI関連市場規模5領域"; p="# タスク: 2026年AI市場規模 5領域`n領域: 生成AI/AIコンサル/EdTech AI/採用Tech/医療AI`n各: 国内市場規模/CAGR/プレイヤー数/AIpaX参入可能性" },
    @{ d="research"; w="research"; t="静岡県中堅企業100社デジタル化状況"; p="# タスク: 静岡県内中堅企業のデジタル化状況`n50-300名規模・建設/製造/サービス業合計100社のIT投資傾向`n採用サイト・社内DX・AI導入の現状`n[[entities/aipa-web]] [[entities/aipax]]" },
    @{ d="research"; w="research"; t="2024年問題後物流業界AI導入率"; p="# タスク: 2024年問題後の物流業界AI/DX導入率調査`n大手3PL・中堅運送会社・地方物流`n人手不足度・AI/SaaS導入率・予算規模" },
    @{ d="research"; w="research"; t="インバウンド観光客の行動データ2026"; p="# タスク: 2026年インバウンド観光客行動データ`n国別TOP10・滞在日数・消費額・行動パターン・SNS利用率`n静岡県の取り込み実績" },
    @{ d="research"; w="research"; t="士業デジタルツール市場調査"; p="# タスク: 士業(税理士/行政書士/弁護士)向けデジタルツール市場`n国内市場規模・主要プレイヤー・価格帯・導入率" },
    @{ d="research"; w="research"; t="中小製造業ベテラン退職リスク調査"; p="# タスク: 中小製造業のベテラン技能継承問題`n業界別退職率・後継者不足度・AIによる技能継承の事例" },
    @{ d="research"; w="research"; t="Z世代起業家2026年トレンド"; p="# タスク: Z世代起業家2026年トレンド`n資金調達手法・事業領域・SNS活用・大井湧瑛の位置取り" },
    @{ d="research"; w="research"; t="2026年新NISA以降の個人投資傾向"; p="# タスク: 2026年個人投資傾向 新NISA後`n年代別投資額・好まれる商品・FinTech利用率" },
    @{ d="research"; w="research"; t="2026年ChatGPT vs Claude比較"; p="# タスク: 2026年AI主要サービス比較`nChatGPT/Claude/Gemini/Grok/Perplexity`n機能/価格/UX/法人導入向き" },
    @{ d="research"; w="research"; t="EdTech米国Top10事例"; p="# タスク: 米国EdTech Top10 2026`nKhan Academy/Duolingo/Coursera等10社の最新動向と日本市場への示唆 (Testall向け)" },
    @{ d="research"; w="research"; t="日本ベンチャー投資家トップ20"; p="# タスク: 日本のベンチャー投資家トップ20`nVC/エンジェル・投資領域・直近のディール例・大井(高校生起業家)向きのリスト" },
    @{ d="research"; w="research"; t="ダーツ業界市場規模2026"; p="# タスク: ダーツ業界2026年市場規模`nプレイヤー数推移・主要チェーン店分布・サブスク型ニッチ可能性`n[[entities/ipak-darts]]" },
    @{ d="research"; w="research"; t="水産業AI/DX導入事例2026"; p="# タスク: 国内水産業AI/DX導入事例2026`n養殖/漁業/釣具/釣り場 各セクター事例5件ずつ`n[[entities/ipak-fishing]]" },
    @{ d="research"; w="research"; t="リアルFPS/光線銃市場海外事例"; p="# タスク: 海外リアルFPS/光線銃スポーツ事例`n米国/欧州/中国主要プレイヤー・施設数・ビジネスモデル`n[[entities/agents-of-flag]]" },
    @{ d="research"; w="research"; t="メンタルヘルスSaaS市場2026"; p="# タスク: 2026年メンタルヘルスSaaS市場`n主要プレイヤー・価格・導入企業数・成長率" },
    @{ d="research"; w="research"; t="日本のシニアスマホ利用2026"; p="# タスク: 2026年シニア(60-75歳)スマホ利用実態`n所有率・主要利用アプリ・キャッシュレス決済率・健康管理アプリ利用" },
    @{ d="research"; w="research"; t="2026年AI規制動向"; p="# タスク: 2026年AI規制動向 日本/EU/米国`nAI法案・個人情報保護・著作権・AIpaXへの影響" },
    @{ d="research"; w="research"; t="高校生起業家事例10件"; p="# タスク: 国内高校生起業家事例10件 2024-2026`n各: 名前/学校/事業/規模/メディア露出/大井との比較" },
    @{ d="research"; w="research"; t="JR東海エリア中堅企業100社マップ"; p="# タスク: JR東海エリア(静岡/愛知/三重/岐阜)中堅企業100社`n業種別・採用課題・AIpaX/AIpa Web向きのスコア" },
    @{ d="research"; w="research"; t="HR Tech市場2026年予測"; p="# タスク: 2026年HR Tech市場予測`n採用/評価/育成/勤怠 4領域別市場規模・成長率・主要プレイヤー" },
    @{ d="research"; w="research"; t="日本のSaaS課金成功パターン分析"; p="# タスク: 日本のSaaS課金成功パターン10事例`nfreee/SmartHR/Sansan等の課金構造・LTV・チャーン率" },
    @{ d="research"; w="research"; t="2026年生成AI業務利用調査"; p="# タスク: 2026年企業の生成AI業務利用調査`n業種別/規模別の利用率・主要用途・課題" },
    @{ d="research"; w="research"; t="フィンテック新興5社"; p="# タスク: 国内フィンテック新興5社2026`n各: 事業/評価額/直近資金調達/AI活用度" },
    @{ d="research"; w="research"; t="EdTech日本Top15動向"; p="# タスク: 国内EdTech Top15 2026`nスクー/atama+/Studyplus/Z会等の動向と Testall への示唆" },
    @{ d="research"; w="research"; t="ローカル起業支援エコシステム"; p="# タスク: 地方都市の起業支援エコシステム5都市`n静岡/福岡/札幌/仙台/広島 各5施設・助成金・成功事例" },
    @{ d="research"; w="research"; t="2026年労働市場の構造変化"; p="# タスク: 2026年労働市場の構造変化`n人手不足上位業種・賃金推移・副業率・転職傾向" },

    # ===== WRITING/MARKETING 25件 (LP/note/X/SEO/メール) =====
    @{ d="marketing"; w="writing"; t="AIpaX note記事『AIで月20万削減』"; p="# タスク: note記事『AIで月20万円削減した中堅企業の話』2500字`n[[entities/aipax]] 既存4社実例ベース・大井1人称・事例構造のみ匿名" },
    @{ d="marketing"; w="writing"; t="Testall note記事『塾に行けない受験生』"; p="# タスク: note記事『塾に行けない受験生のためのAI学習プラン』3000字`n[[entities/testall]] β顧客向け・原体験 + 1日45分プラン構造" },
    @{ d="marketing"; w="writing"; t="EEMUS note記事『静岡71%流出』"; p="# タスク: note記事『静岡県外進学71%・Uターン33%の現実』3000字`n[[entities/eemus]] 構造問題提示・夢AWARDストーリー」" },
    @{ d="marketing"; w="writing"; t="AIpa Web SEO『中小企業 採用 失敗』"; p="# タスク: SEO記事『中小企業の採用失敗パターン10選』3500字`n[[entities/aipa-web]] CV狙い・モニター15万円プランへの自然導線" },
    @{ d="marketing"; w="writing"; t="AOF note記事『リアルFPS時代の到来』"; p="# タスク: note記事『リアルFPSスポーツの時代がきた』2500字`n[[entities/agents-of-flag]] スポーツビジョン語り" },
    @{ d="marketing"; w="writing"; t="X投稿 大井キャラ30本"; p="# タスク: X投稿30本 大井キャラ完全反映`n話題: 起業/AI/受験/恋愛/失敗/家族 各5本`n各140字・タグ付き・大井ぶっちゃけ口調" },
    @{ d="marketing"; w="writing"; t="X投稿 AIpaX営業10本"; p="# タスク: X投稿10本 AIpaX営業フック`n各140字・大井1人称・実例的・コメント来そうな引き" },
    @{ d="marketing"; w="writing"; t="X投稿 Testall β告知15本"; p="# タスク: X投稿15本 Testall β顧客100名募集`n受験生向け・親向け・両方含む" },
    @{ d="marketing"; w="writing"; t="TikTok台本 受験あるある15本"; p="# タスク: TikTok台本15本『受験生あるある』各60秒`nTestall宣伝の自然接続" },
    @{ d="marketing"; w="writing"; t="TikTok台本 中高生向けAI起業話10本"; p="# タスク: TikTok台本10本 中高生向けAI起業ストーリー`n大井実例・AIpaX schoolへの自然な誘導" },
    @{ d="marketing"; w="writing"; t="AIpaX 5社目LP草稿"; p="# タスク: AIpaX 5社目営業用LP草稿 3500字`nHero/痛み/解決/事例(4社匿名)/価格/FAQ/CTA`n[[entities/aipax]]" },
    @{ d="marketing"; w="writing"; t="Testall β募集LP 親バージョン"; p="# タスク: Testall β募集LP 保護者向けバージョン 2500字`n親の不安にフック・受験対策費用比較 (塾vs Testall)" },
    @{ d="marketing"; w="writing"; t="EEMUS 高校向けLP"; p="# タスク: EEMUS β高校5校向けLP 2500字`n校長/進路指導向け・キャリア授業協力スキーム強調" },
    @{ d="marketing"; w="writing"; t="AIpaX 商談用1枚スライド5パターン"; p="# タスク: AIpaX商談1枚スライド5パターン`n業種別: 製造/建設/介護/物流/小売 各300-400字の構成案" },
    @{ d="marketing"; w="writing"; t="AIpa Web メール件名30案"; p="# タスク: AIpa Web 接触メール件名30案`n各40字以内・開封率上げる・業界別6グループ" },
    @{ d="marketing"; w="writing"; t="AIpaX 月次レポート3社向けカスタマイズ"; p="# タスク: AIpaX 月次レポート 3社向けカスタマイズ`n業種別(製造/サービス/医療) 各レポート構成" },
    @{ d="marketing"; w="writing"; t="夢AWARD ピッチ60秒台本"; p="# タスク: 夢AWARD 60秒ピッチ動画台本`n[[entities/eemus]] 大井1人称・原体験 + 数字 + 涙ポイント" },
    @{ d="marketing"; w="writing"; t="夢AWARD 3分プレゼン台本"; p="# タスク: 夢AWARD 3分プレゼン台本`n[[entities/eemus]] 第1章〜終章の流れ・スライド指示付き" },
    @{ d="marketing"; w="writing"; t="AIpa Web 提案書テンプレ"; p="# タスク: AIpa Web 提案書テンプレ`nA4・8ページ構成・モニター15万→月額10万移行プラン" },
    @{ d="marketing"; w="writing"; t="AIpaX 既存4社 紹介依頼メール"; p="# タスク: AIpaX 既存4社向け 紹介依頼メール`n各社業種別カスタマイズ・紹介報酬モデル提示" },
    @{ d="marketing"; w="writing"; t="Testall インフルエンサー連携DM10案"; p="# タスク: Testall受験系インフルエンサー10名向けDM`n各140字以内・コラボ提案" },
    @{ d="marketing"; w="writing"; t="AIpaX X展開戦略30日"; p="# タスク: AIpaX X (旧Twitter) 30日展開戦略`n毎日の投稿テーマ + 投稿時間 + 大井キャラ反映度" },
    @{ d="marketing"; w="writing"; t="LinkedIn 営業文5パターン"; p="# タスク: LinkedIn 中堅企業向け営業文5パターン`nAIpa Web/AIpaX向け・コネクション依頼+1stメッセージ構成" },
    @{ d="marketing"; w="writing"; t="動画台本 大井17歳ストーリー"; p="# タスク: YouTube動画台本『17歳AI起業家』10分`n大井ストーリー・事業構造・1年後の絵" },
    @{ d="marketing"; w="writing"; t="EEMUS 高校パンフ案"; p="# タスク: EEMUS 高校生配布パンフ案 A4両面`nビジュアル指示 + コピー + QR位置" },

    # ===== CODING/DEV 15件 =====
    @{ d="dev"; w="coding"; t="Testall データモデル仕様"; p="# タスク: Testall データモデル仕様書`nUser/Score/StudyPlan/Goal/Notification の5テーブル`n各カラム/型/制約/関係性" },
    @{ d="dev"; w="coding"; t="Testall API仕様 v1"; p="# タスク: Testall REST API仕様 v1`n認証/学習計画生成/進捗記録/通知の各エンドポイント設計" },
    @{ d="dev"; w="coding"; t="AIpa Web Googleフォーム→DBスキーマ"; p="# タスク: AIpa Web 16セクションフォーム → DBスキーマ`n各セクションのフィールド・型・バリデーション" },
    @{ d="dev"; w="coding"; t="AIpaX 保存庫コア技術仕様"; p="# タスク: AIpaX 会社別AI保存庫 技術仕様`nベクトルDB/RAGパイプライン/Slack連携の構成" },
    @{ d="dev"; w="coding"; t="AOF アプリ仕様 v1"; p="# タスク: AOF アプリ機能仕様 v1`n戦績/ランク/チーム/予約/観戦の5機能・各画面構成" },
    @{ d="dev"; w="coding"; t="Stripe決済設定 5事業ロードマップ"; p="# タスク: 主力5事業のStripe決済設定ロードマップ`n各: 商品設定/価格モデル(定期vs単発)/支払い方法/法的考慮" },
    @{ d="dev"; w="coding"; t="Testall モデルプロンプト設計"; p="# タスク: Testall 学習計画生成プロンプト設計`nLLM活用の入出力/エッジケース/失敗時フォールバック" },
    @{ d="dev"; w="coding"; t="brain System 拡張案"; p="# タスク: brain System 次の3拡張案`nRAG基盤/embedding/vault分割/月次レビュー自動化" },
    @{ d="dev"; w="coding"; t="OpenClaw worker 並列度UP案"; p="# タスク: OpenClaw worker 並列度4→8基UP方法`nGPU共有/メモリ管理/スケジューリング戦略" },
    @{ d="dev"; w="coding"; t="EEMUS マッチング ロジック仕様"; p="# タスク: EEMUS 高校生×企業マッチング ロジック仕様`n属性ベース/興味ベース/距離ベース のハイブリッド" },
    @{ d="dev"; w="coding"; t="IPAK-darts アプリ仕様"; p="# タスク: IPAK-darts アプリ仕様`n入退店QR/予約/課金/会員ランクの4機能" },
    @{ d="dev"; w="coding"; t="FishOps Agent システム構成図"; p="# タスク: FishOps Agent 5機能のシステム構成図`n各機能のデータフロー・外部API・DB設計" },
    @{ d="dev"; w="coding"; t="AIpaX school LMS仕様"; p="# タスク: AIpaX school LMS仕様 v1`n生徒管理/カリキュラム/進捗/親レポート機能" },
    @{ d="dev"; w="coding"; t="brain dashboard 拡張案"; p="# タスク: brain dashboard 拡張案 3つ`n部署別タスク完了率・Mythos品質トレンド・コスト追跡" },
    @{ d="dev"; w="coding"; t="Recurrent pipeline 改善案"; p="# タスク: Recurrent pipeline 改善案`nDepth別異なるmodel切替/Depth合計コスト最適化" },

    # ===== NEWBIZ 15件 (戦略/ピッチ/提案) =====
    @{ d="newbiz"; w="newbiz"; t="主力5事業 90日進捗ロードマップ"; p="# タスク: 主力5事業 90日進捗ロードマップ`nAIpaX/Testall/AIpa Web/AIpaX school/EEMUS 各15ステップ" },
    @{ d="newbiz"; w="newbiz"; t="Testall MVP機能優先順位"; p="# タスク: Testall MVP機能優先順位 9月リリース版`n5機能の優先順位 + 各工数 + 切り捨て基準" },
    @{ d="newbiz"; w="newbiz"; t="AIpaX 5社目以降のプラン体系"; p="# タスク: AIpaX 5社目以降の通常価格プラン体系`n初期100-150万 + 月10-15万 の根拠 + 3プラン構成案" },
    @{ d="newbiz"; w="newbiz"; t="AIpa Web 月315万シナリオ詳細化"; p="# タスク: AIpa Web 月315万売上シナリオ詳細`n月8件+25社運用 の達成ロードマップ・月別目標数値" },
    @{ d="newbiz"; w="newbiz"; t="EEMUS 連携企業20社接触戦略"; p="# タスク: EEMUS 静岡県内連携企業20社接触戦略`n各社へのアプローチ順序・予測反応・成約率予測" },
    @{ d="newbiz"; w="newbiz"; t="AOF PoC開催プラン詳細"; p="# タスク: AOF β大会 (10チーム×4人) 開催プラン詳細`n会場/機材/運営/スポンサー/告知 6つの分野・タイムライン" },
    @{ d="newbiz"; w="newbiz"; t="IPAK-darts BEP37名達成3シナリオ"; p="# タスク: IPAK-darts BEP37名達成シナリオ 3パターン`n楽観(6ヶ月)/標準(12ヶ月)/悲観(18ヶ月) 各施策 + KPI" },
    @{ d="newbiz"; w="newbiz"; t="FishOps Agent β顧客5社獲得シナリオ"; p="# タスク: FishOps Agent β顧客5社獲得シナリオ`n養殖/漁業/釣具屋/釣り場 各セクター候補と接触経路" },
    @{ d="newbiz"; w="newbiz"; t="AIpaX school 第1期生5名 獲得計画"; p="# タスク: AIpaX school 第1期生5名 獲得計画`nXお試し会経由・親紹介・コンテスト経由 3経路の戦略" },
    @{ d="newbiz"; w="newbiz"; t="6/21月収100万達成 緊急シナリオ"; p="# タスク: 2026/6/21月収100万達成 緊急シナリオ`n残30日・現状20万 → 80万追加の現実的施策5本" },
    @{ d="newbiz"; w="newbiz"; t="夢AWARD後の次5ビジコン応募戦略"; p="# タスク: 夢AWARD後に応募する次5ビジコン応募戦略`n7-9月締切ものに集中・各事業別優先順位" },
    @{ d="newbiz"; w="newbiz"; t="SFC AO エッセイ骨子v3"; p="# タスク: SFC AO エッセイ骨子v3 30000字`n『AIによる思考の外部化と人間の主体性』テーマ・大井実例" },
    @{ d="newbiz"; w="newbiz"; t="主力5事業 リスクマップ"; p="# タスク: 主力5事業 リスクマップ`n各事業: 競合参入リスク/技術リスク/資金リスク/法的リスク 4軸評価" },
    @{ d="newbiz"; w="newbiz"; t="2026 Q3/Q4 採用計画"; p="# タスク: 2026年Q3/Q4 採用計画`nエンジニア/営業/CS/マーケ 各役割の必要時期 + 採用方法 + 月給目安" },
    @{ d="newbiz"; w="newbiz"; t="主力5事業 3年後の絵"; p="# タスク: 主力5事業 3年後 (2029年) の絵`n各事業: 売上/従業員/市場ポジション/EXIT可能性" },

    # ===== CORP 10件 (財務/契約/整理) =====
    @{ d="corp"; w="corp"; t="AIpaX 業務委託契約書 (5社目用)"; p="# タスク: AIpaX 業務委託契約書 5社目向けテンプレ`n業務範囲/価格/データ保護/解約/知財/反社条項 を含む3500字" },
    @{ d="corp"; w="corp"; t="AIpa Web モニター契約書"; p="# タスク: AIpa Web モニター契約書 (15万円プラン用)`n納期/瑕疵対応/月額移行条件/中途解約 含む2500字" },
    @{ d="corp"; w="corp"; t="Testall β顧客 利用規約"; p="# タスク: Testall β顧客 利用規約v1`n月980円 (β限定)・3ヶ月後の通常価格移行条件含む3000字" },
    @{ d="corp"; w="corp"; t="個人情報保護方針 主力5事業共通"; p="# タスク: 個人情報保護方針 主力5事業共通テンプレ`n2026年改正個人情報保護法対応" },
    @{ d="corp"; w="corp"; t="主力5事業 月次キャッシュフロー予測"; p="# タスク: 主力5事業 月次キャッシュフロー予測 6月〜12月`n各月の売上/コスト/純利益 表形式" },
    @{ d="corp"; w="corp"; t="主力5事業 損益分岐点分析"; p="# タスク: 主力5事業 損益分岐点分析`n各事業の固定費/変動費/BEP月数" },
    @{ d="corp"; w="corp"; t="副業/業務委託契約 標準テンプレ"; p="# タスク: 副業/業務委託契約 標準テンプレ`nエンジニア/デザイナー/ライター 3パターン" },
    @{ d="corp"; w="corp"; t="主力5事業 KPI管理シート設計"; p="# タスク: 主力5事業 KPI管理シート設計`n各事業の週次/月次KPI・取得方法・閾値" },
    @{ d="corp"; w="corp"; t="EEMUS 連携企業契約書"; p="# タスク: EEMUS 連携企業 (高校生インターン受入) 契約書`n受入条件/責任分担/保険/中途解約 含む2500字" },
    @{ d="corp"; w="corp"; t="主力5事業 補助金活用マップ"; p="# タスク: 主力5事業で使える補助金10件マップ`nIT導入補助金/小規模事業者持続化/事業再構築/各都道府県補助 各事業との適合度" },

    # ===== SECRETARY 5件 (整理/議事録/日報テンプレ) =====
    @{ d="secretary"; w="secretary"; t="議事録テンプレ 5パターン"; p="# タスク: 議事録テンプレ 5パターン`n商談/社内MTG/インタビュー/講義/プロジェクト" },
    @{ d="secretary"; w="secretary"; t="日報テンプレ 大井向け1分版"; p="# タスク: 日報テンプレ 大井向け1分版`n進捗/詰まり/明日 3項目で1分で書ける構造" },
    @{ d="secretary"; w="secretary"; t="週次レビューテンプレ"; p="# タスク: 週次レビューテンプレ 大井向け`n5事業×3指標 + 来週の本命1個・棚卸し3項目" },
    @{ d="secretary"; w="secretary"; t="email下書きテンプレ 大井キャラ"; p="# タスク: メール下書きテンプレ集 大井キャラ反映`n初対面/紹介/お断り/感謝/緊急依頼 5パターン" },
    @{ d="secretary"; w="secretary"; t="メンター連絡ルール 5層"; p="# タスク: メンター連絡ルール 5層別`nTier1月1接触/Tier2四半期/Tier3半年/Tier4年1/Tier5緊急の連絡頻度と内容" }
)

$dispatched = 0
foreach ($t in $tasks) {
    $stamp = (Get-Date).ToString("yyyyMMdd-HHmm")
    $sid = [guid]::NewGuid().ToString().Substring(0,4)
    $slug = ($t.t -replace '[^\w]','-').ToLower()
    if ($slug.Length -gt 40) { $slug = $slug.Substring(0, 40) }
    $outPath = "$brain\wiki\_inbox\$($t.d)\$($t.w)-$slug-$stamp-$sid.md"
    & $dispatcher -Department $t.d -Title "[$($t.w)] $($t.t)" -Prompt $t.p -Model "qwen3.6:latest" -OutputPath $outPath -Priority "normal" 2>&1 | Out-Null
    $dispatched++
}
Write-Host "Overnight Wave dispatched: $dispatched tasks"
