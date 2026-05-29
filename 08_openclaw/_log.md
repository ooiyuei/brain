---
type: department-log
dept_code: 08_openclaw
updated: 2026-05-27
managed_by: Claude (worker.ps1 とは別、意味ログ)
---

# 08_openclaw 活動ログ

> **OpenClaw に関する「意味ログ」。worker.ps1 のテクニカルログは `queue/logs/worker-*.log` に別途あり。**

---

### 2026-05-27 06:30 queue 滞留事故対応
- 真因: 5/25 朝 BrainAutoReview が 1500件超を一気投入、worker (1件3-5分) では消化不可能 (75-125時間相当)
- 対処: 1521件を `_archive/inbox-purge-2026-05-27/` に保全退避、BrainAutoReview を Disabled 維持
- 学び: **自動投入系は1回100件以下 + worker 消化速度を見ながら段階投入** に変更必須 (再発防止)
- 関連: `wiki/dashboards/openclaw-activity.md` (再生成済)

---
