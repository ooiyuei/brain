# wiki/_inbox/ — OpenClaw成果物の一時置き場

OpenClawが生成し、output_path未指定だった成果物はここに集まる。

## レビュー手順（Claudeエージェント向け）

1. 部署別フォルダ（research/ / newbiz/ / marketing/ ...）を巡回
2. 各ファイルを読み、品質チェック
3. OK → wiki/{正式パス}/ へリネーム+移動
4. NG → 削除 or 再依頼

## 部署別配置先目安

| 部署 | 昇格先 |
|---|---|
| research | wiki/research/ or wiki/sources/ |
| newbiz | wiki/10_projects/{プロジェクト名}/ |
| dev | wiki/30_resources/dev/ |
| marketing | wiki/20_areas/marketing/ |
| corp | wiki/20_areas/corp/ |
| secretary | wiki/40_daily/ or wiki/_meetings/ |

## このフォルダのサイズが大きくなったら

Claudeに「wiki/_inbox整理して」と言えば、ceo-orchestrator経由で各部署エージェントに振り分けてレビュー&昇格処理される。
