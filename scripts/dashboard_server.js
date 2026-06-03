#!/usr/bin/env node
/** Brain Live Dashboard v3 - http://localhost:7777 + /org */
const http = require('http');
const fs = require('fs');
const path = require('path');
const os = require('os');
const { execSync } = require('child_process');

const PORT = 7777;
const BRAIN_ROOT = 'C:\\Users\\Owner\\business\\brain';
const QUEUE = path.join(BRAIN_ROOT, 'queue');
const PAUSE_FILE = path.join(QUEUE, '.paused');
const PIPELINE_ROOT = path.join(BRAIN_ROOT, 'wiki', '_pipeline');
const PROJECTS_ROOT = path.join(BRAIN_ROOT, 'wiki', '10_projects');

// ===== Pipeline status =====
function getPipelineStatus() {
    const stages = [
        { key: '1_seeded', label: '💡 種まき', desc: 'アイデア生成' },
        { key: '2_judged', label: '⚖️ 採点', desc: '10項目ティア判定' },
        { key: '3_refined', label: '✨ 磨き', desc: '実行可能まで磨く' },
        { key: '4_redteam', label: '🔥 Red Team', desc: '穴探し・GO/HOLD/KILL' },
        { key: '5_prd', label: '📋 PRD', desc: '実装仕様書' }
    ];
    const out = { stages: [], shipped: [], graveyard: 0 };

    for (const s of stages) {
        const dir = path.join(PIPELINE_ROOT, s.key);
        const cards = [];
        if (fs.existsSync(dir)) {
            const files = fs.readdirSync(dir).filter(f => f.endsWith('.md'));
            for (const f of files) {
                try {
                    const content = fs.readFileSync(path.join(dir, f), 'utf8');
                    const titleMatch = content.match(/^#\s+(.+)$/m);
                    const tierMatch = content.match(/tier:\s*([SABC])/i) || content.match(/TIER:\s*([SABC])/);
                    const scoreMatch = content.match(/score:\s*(\d+)/i) || content.match(/SCORE:\s*(\d+)/);
                    const verdictMatch = content.match(/verdict:\s*(GO|HOLD|KILL)/i);
                    const stat = fs.statSync(path.join(dir, f));
                    cards.push({
                        file: f,
                        title: titleMatch ? titleMatch[1].trim() : f.replace('.md', ''),
                        tier: tierMatch ? tierMatch[1] : null,
                        score: scoreMatch ? parseInt(scoreMatch[1]) : null,
                        verdict: verdictMatch ? verdictMatch[1].toUpperCase() : null,
                        mtime: stat.mtime.toISOString()
                    });
                } catch (e) {}
            }
        }
        out.stages.push({ ...s, count: cards.length, cards: cards.sort((a, b) => b.mtime.localeCompare(a.mtime)) });
    }

    // shipped projects
    if (fs.existsSync(PROJECTS_ROOT)) {
        const projs = fs.readdirSync(PROJECTS_ROOT, { withFileTypes: true }).filter(d => d.isDirectory());
        for (const d of projs) {
            const readme = path.join(PROJECTS_ROOT, d.name, 'README.md');
            let status = 'unknown', shippedAt = null;
            if (fs.existsSync(readme)) {
                try {
                    const c = fs.readFileSync(readme, 'utf8');
                    const sm = c.match(/status:\s*([\w-]+)/);
                    const sa = c.match(/shipped_at:\s*([^\n]+)/);
                    if (sm) status = sm[1];
                    if (sa) shippedAt = sa[1].trim();
                } catch (e) {}
            }
            out.shipped.push({ slug: d.name, status, shippedAt });
        }
    }

    // graveyard count
    const gDir = path.join(PIPELINE_ROOT, '_graveyard');
    if (fs.existsSync(gDir)) {
        try {
            const tiers = fs.readdirSync(gDir, { withFileTypes: true }).filter(d => d.isDirectory());
            for (const t of tiers) {
                out.graveyard += fs.readdirSync(path.join(gDir, t.name)).filter(f => f.endsWith('.md')).length;
            }
        } catch (e) {}
    }

    return out;
}

// ===== 部署別タスク状況 =====
const DEPARTMENTS = [
    { key: 'research', label: '🔬 経営企画室', desc: '市場・競合・トレンド調査', color: '#3b82f6', filler: 'idle_filler', agent: 'researcher' },
    { key: 'newbiz', label: '🚀 新規事業部', desc: '新規事業創出・PRD化', color: '#a855f7', filler: '新規事業パイプライン + idle_filler', agent: 'venture-director + idea-generator他4' },
    { key: 'marketing', label: '💼 営業マーケCS部', desc: '営業・集客・カスタマーサクセス', color: '#f59e0b', filler: 'sales_filler + writing_filler + money_filler + cs_filler', agent: 'sales-rep + marketer + customer-success' },
    { key: 'dev', label: '🛠️ 開発部', desc: '開発・アプリ仕様・コード', color: '#10b981', filler: 'dev_filler', agent: 'developer + planner + tdd-guide' },
    { key: 'corp', label: '💰 コーポレート部', desc: '財務・法務・人事', color: '#ef4444', filler: 'corp_filler', agent: 'cfo + legal + hr-recruiter' },
    { key: 'secretary', label: '📝 秘書室', desc: '日報・議事録・通信', color: '#ec4899', filler: 'daily_brain + secretary_filler', agent: 'secretary + chief-of-staff' }
];

function getDepartmentsStatus() {
    const inboxDir = path.join(QUEUE, 'inbox');
    const procDir = path.join(QUEUE, 'processing');
    const doneDir = path.join(QUEUE, 'done');
    const wikiInbox = path.join(BRAIN_ROOT, 'wiki', '_inbox');
    const wikiPromoted = path.join(BRAIN_ROOT, 'wiki', '_promoted');
    const wikiFinal = path.join(BRAIN_ROOT, 'wiki', '_final');

    // 既存ジョブ収集 (BOM除去対応)
    const readJobs = (dir) => {
        if (!fs.existsSync(dir)) return [];
        return fs.readdirSync(dir).filter(f => f.endsWith('.json')).map(f => {
            try {
                const raw = fs.readFileSync(path.join(dir, f), 'utf8').replace(/^﻿/, '');
                const j = JSON.parse(raw);
                const stat = fs.statSync(path.join(dir, f));
                return { ...j, _file: f, _mtime: stat.mtime.toISOString() };
            } catch (e) { return null; }
        }).filter(Boolean);
    };

    const inboxJobs = readJobs(inboxDir);
    const procJobs = readJobs(procDir);
    const doneJobs = readJobs(doneDir);

    // 24h以内の完了
    const dayAgo = Date.now() - 24 * 3600 * 1000;
    const doneRecent = doneJobs.filter(j => new Date(j._mtime).getTime() > dayAgo);
    const doneAll = doneJobs.sort((a, b) => b._mtime.localeCompare(a._mtime));

    return {
        departments: DEPARTMENTS.map(d => {
            const waiting = inboxJobs.filter(j => j.department === d.key);
            const processing = procJobs.filter(j => j.department === d.key);
            const done24h = doneRecent.filter(j => j.department === d.key);

            // wiki 成果物
            const countMd = (root, dept) => {
                const p = path.join(root, dept);
                if (!fs.existsSync(p)) return 0;
                return fs.readdirSync(p).filter(f => f.endsWith('.md')).length;
            };

            return {
                ...d,
                waiting: waiting.length,
                processing: processing.length,
                done24h: done24h.length,
                doneTotal: doneJobs.filter(j => j.department === d.key).length,
                inboxMd: countMd(wikiInbox, d.key),
                promotedMd: countMd(wikiPromoted, d.key),
                finalMd: countMd(wikiFinal, d.key),
                tasksNow: [
                    ...processing.map(j => ({ status: 'processing', title: j.title, priority: j.priority, time: j._mtime })),
                    ...waiting.slice(0, 3).map(j => ({ status: 'waiting', title: j.title, priority: j.priority, time: j._mtime })),
                    ...done24h.slice(0, 5).map(j => ({ status: 'done', title: j.title, priority: j.priority, time: j._mtime }))
                ]
            };
        }),
        totals: {
            waiting: inboxJobs.length,
            processing: procJobs.length,
            done24h: doneRecent.length,
            doneAll: doneJobs.length
        },
        recentDone: doneAll.slice(0, 30).map(j => ({
            title: j.title,
            department: j.department,
            priority: j.priority,
            completed_at: j.completed_at || j._mtime,
            output_path: j.output_path
        }))
    };
}

// ===== 状態取得関数群 =====
// 2026-06-03: 毎回 powershell(Get-Counter ~3s) を起動していたのを純node(os.cpus差分)に置換。
// /api/status が 3.6s→<0.5s に高速化し、2秒ポーリングが詰まらなくなる。
let _lastCpu = null;
function getCpuUsage() {
    try {
        const cpus = os.cpus();
        let idle = 0, total = 0;
        for (const c of cpus) {
            for (const k in c.times) total += c.times[k];
            idle += c.times.idle;
        }
        let pct = 0;
        if (_lastCpu) {
            const dIdle = idle - _lastCpu.idle;
            const dTotal = total - _lastCpu.total;
            pct = dTotal > 0 ? (1 - dIdle / dTotal) * 100 : 0;
        }
        _lastCpu = { idle, total };
        return Math.round(pct * 10) / 10;
    } catch (e) { return null; }
}

function getMemoryUsage() {
    const total = os.totalmem();
    const free = os.freemem();
    const used = total - free;
    return {
        usedGB: Math.round(used / 1024 / 1024 / 1024 * 10) / 10,
        totalGB: Math.round(total / 1024 / 1024 / 1024 * 10) / 10,
        percent: Math.round(used / total * 1000) / 10,
    };
}

function getGpuUsage() {
    try {
        const out = execSync(
            'nvidia-smi --query-gpu=name,utilization.gpu,memory.used,memory.total,temperature.gpu --format=csv,noheader,nounits',
            { timeout: 3000, windowsHide: true }
        ).toString().trim();
        const p = out.split(',').map(x => x.trim());
        return { name: p[0], util: parseInt(p[1]), vramUsedMB: parseInt(p[2]), vramTotalMB: parseInt(p[3]), tempC: parseInt(p[4]) };
    } catch (e) { return null; }
}

function getOllamaLoadedModels() {
    return new Promise((resolve) => {
        const req = http.get('http://localhost:11434/api/ps', (res) => {
            let data = '';
            res.on('data', c => data += c);
            res.on('end', () => { try { resolve(JSON.parse(data).models || []); } catch (e) { resolve([]); } });
        });
        req.on('error', () => resolve(null));
        req.setTimeout(2000, () => { req.destroy(); resolve(null); });
    });
}

function readJsonSafe(filepath) {
    try { return JSON.parse(fs.readFileSync(filepath, 'utf8')); } catch (e) { return null; }
}

function getQueueDetails() {
    const today = new Date().toDateString();
    const read = (dir, todayOnly = false) => {
        try {
            return fs.readdirSync(dir).map(f => {
                try {
                    const stat = fs.statSync(path.join(dir, f));
                    if (todayOnly && stat.mtime.toDateString() !== today) return null;
                    const j = readJsonSafe(path.join(dir, f));
                    if (!j) return null;
                    const ageMs = Date.now() - stat.mtime.getTime();
                    return {
                        title: j.title, model: j.model, priority: j.priority,
                        department: j.department, requested_by: j.requested_by,
                        use_agent: j.use_agent, completedAt: j.completed_at,
                        ageSec: Math.floor(ageMs / 1000),
                    };
                } catch (e) { return null; }
            }).filter(x => x);
        } catch (e) { return []; }
    };

    const failed = (() => { try { return fs.readdirSync(path.join(QUEUE, 'failed')).length; } catch (e) { return 0; } })();
    return {
        inbox: read(path.join(QUEUE, 'inbox')).slice(0, 30),
        processing: read(path.join(QUEUE, 'processing')),
        done: read(path.join(QUEUE, 'done'), true).sort((a, b) => (b.completedAt || '').localeCompare(a.completedAt || '')),
        failedCount: failed,
    };
}

function getWorkerLocks() {
    const heavyLock = path.join(QUEUE, '.worker-heavy.lock');
    const lightLock = path.join(QUEUE, '.worker-light.lock');
    return {
        heavy: fs.existsSync(heavyLock),
        light: fs.existsSync(lightLock),
        heavyAge: fs.existsSync(heavyLock) ? Math.floor((Date.now() - fs.statSync(heavyLock).mtime.getTime()) / 1000) : 0,
        lightAge: fs.existsSync(lightLock) ? Math.floor((Date.now() - fs.statSync(lightLock).mtime.getTime()) / 1000) : 0,
    };
}

// 2026-06-03: schtasks 起動(~1-2s)を毎回やらず20秒キャッシュ。スケジューラ状態は頻繁に変わらないため十分。
let _schedCache = { ts: 0, data: [] };
function getScheduledTasks() {
    const now = Date.now();
    if (now - _schedCache.ts < 20000 && _schedCache.data.length) return _schedCache.data;
    try {
        const out = execSync(
            `powershell -NoProfile -Command "schtasks /query /fo CSV 2>$null | ConvertFrom-Csv | Where-Object { $_.TaskName -match 'Brain|Daily' } | Select-Object TaskName,Status | ConvertTo-Json"`,
            { timeout: 5000, windowsHide: true }
        ).toString().trim();
        const parsed = JSON.parse(out);
        const arr = Array.isArray(parsed) ? parsed : [parsed];
        const result = arr.map(t => ({ name: (t.TaskName || '').replace(/^\\/, ''), status: t.Status }));
        _schedCache = { ts: now, data: result };
        return result;
    } catch (e) { return _schedCache.data; }
}

function getCounts() {
    const doneDir = path.join(QUEUE, 'done');
    const cutoff = Date.now() - 7 * 24 * 60 * 60 * 1000;
    let week = 0, today = 0;
    const todayStr = new Date().toDateString();
    try {
        for (const f of fs.readdirSync(doneDir)) {
            try {
                const m = fs.statSync(path.join(doneDir, f)).mtime;
                if (m.toDateString() === todayStr) today++;
                if (m.getTime() >= cutoff) week++;
            } catch (e) {}
        }
    } catch (e) {}
    return { todayDone: today, weekDone: week };
}

function isPaused() { return fs.existsSync(PAUSE_FILE); }

async function getFullStatus() {
    const [cpu, mem, gpu, models] = await Promise.all([
        Promise.resolve(getCpuUsage()),
        Promise.resolve(getMemoryUsage()),
        Promise.resolve(getGpuUsage()),
        getOllamaLoadedModels(),
    ]);
    return {
        timestamp: new Date().toISOString(),
        paused: isPaused(),
        cpu, memory: mem, gpu,
        ollama: { ok: models !== null, loadedModels: models || [] },
        queue: getQueueDetails(),
        workers: getWorkerLocks(),
        schedulers: getScheduledTasks(),
        counts: getCounts(),
    };
}

// ===== HTML共通スタイル =====
const COMMON_CSS = `
:root {
  --bg:#000; --surface:#0a0a0a; --surface-2:#141414; --surface-3:#1a1a1a;
  --border:#1f1f1f; --border-strong:#2a2a2a;
  --text:#ededed; --text-mute:#888; --text-dim:#555;
  --blue:#3b82f6; --green:#10b981; --amber:#f59e0b; --red:#ef4444;
  --purple:#8b5cf6; --cyan:#06b6d4; --pink:#ec4899;
}
* { box-sizing: border-box; margin:0; padding:0; }
body {
  font-family: 'Inter', 'Hiragino Kaku Gothic ProN', sans-serif;
  background: var(--bg); color: var(--text);
  font-size: 13px; line-height: 1.6;
  font-feature-settings: 'palt' 1;
  min-height: 100vh;
}
.mono { font-family: 'JetBrains Mono', monospace; }
a { color: var(--blue); text-decoration: none; }
a:hover { text-decoration: underline; }
::-webkit-scrollbar { width: 8px; height: 8px; }
::-webkit-scrollbar-thumb { background: var(--border-strong); border-radius: 4px; }
`;

// ===== Main Dashboard HTML =====
const HTML_DASHBOARD = `<!DOCTYPE html>
<html lang="ja"><head>
<meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>🧠 Brain Live</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@400;600&family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
<style>
${COMMON_CSS}
.app { display: grid; grid-template-columns: 240px 1fr; grid-template-rows: 56px 1fr; grid-template-areas: "header header" "side main"; height: 100vh; overflow:hidden; }
.header { grid-area: header; display: flex; align-items: center; justify-content: space-between; padding: 0 20px; border-bottom: 1px solid var(--border); background: rgba(0,0,0,0.8); }
.sidebar { grid-area: side; border-right: 1px solid var(--border); padding: 16px 12px; overflow-y: auto; }
.main { grid-area: main; padding: 16px 20px; overflow-y: auto; }
.brand { font-weight: 700; font-size: 15px; }
.brand .dot { color: var(--green); animation: pulse 1.5s infinite; }
@keyframes pulse { 0%,100%{opacity:1} 50%{opacity:0.4} }
.nav-links { display: flex; gap: 12px; }
.nav-link { font-size: 12px; padding: 6px 12px; border-radius: 6px; color: var(--text-mute); }
.nav-link.active { background: var(--surface-2); color: var(--text); }
.header-stats { display: flex; align-items: center; gap: 10px; }
.pill { font-family: 'JetBrains Mono', monospace; font-size: 12px; padding: 5px 10px; border-radius: 6px; background: var(--surface-2); border: 1px solid var(--border-strong); display: flex; align-items: center; gap: 6px; }
.pill .label { color: var(--text-mute); font-size: 10px; }
.pill.busy { border-color: var(--green); background: rgba(16,185,129,0.1); }
.pill.idle { border-color: var(--border-strong); }
.pill.paused { border-color: var(--amber); background: rgba(245,158,11,0.15); }
.timestamp { font-size: 11px; color: var(--text-dim); font-family: 'JetBrains Mono', monospace; }
.btn {
  padding: 8px 18px; border-radius: 8px;
  border: 1px solid var(--border-strong);
  background: linear-gradient(180deg, var(--surface-3), var(--surface-2));
  color: var(--text); cursor: pointer;
  font-size: 12px; font-weight: 600; font-family: inherit;
  transition: all 0.12s ease-out;
  box-shadow: 0 2px 0 rgba(0,0,0,0.4), 0 1px 0 rgba(255,255,255,0.04) inset;
  user-select: none;
  position: relative; top: 0;
}
.btn:hover {
  background: linear-gradient(180deg, #1f1f1f, var(--surface-3));
  border-color: var(--text-dim);
  box-shadow: 0 3px 0 rgba(0,0,0,0.5), 0 0 0 1px rgba(255,255,255,0.05) inset;
}
.btn:active {
  top: 2px;
  box-shadow: 0 0 0 rgba(0,0,0,0.4), 0 1px 2px rgba(0,0,0,0.6) inset;
  background: linear-gradient(180deg, var(--surface-2), var(--surface-3));
}
.btn-pause { border-color: var(--amber); color: var(--amber);
  background: linear-gradient(180deg, rgba(245,158,11,0.15), rgba(245,158,11,0.08));
  box-shadow: 0 2px 0 rgba(180,80,0,0.5), 0 1px 0 rgba(255,200,100,0.15) inset;
}
.btn-pause:hover {
  background: linear-gradient(180deg, rgba(245,158,11,0.25), rgba(245,158,11,0.12));
  box-shadow: 0 3px 0 rgba(180,80,0,0.6), 0 0 12px rgba(245,158,11,0.3);
}
.btn-pause:active {
  box-shadow: 0 0 0 rgba(180,80,0,0.4), 0 1px 3px rgba(120,60,0,0.6) inset;
  background: linear-gradient(180deg, rgba(245,158,11,0.1), rgba(245,158,11,0.15));
}
.btn-resume { border-color: var(--green); color: var(--green);
  background: linear-gradient(180deg, rgba(16,185,129,0.2), rgba(16,185,129,0.1));
  box-shadow: 0 2px 0 rgba(0,100,60,0.5), 0 1px 0 rgba(100,255,200,0.15) inset;
}
.btn-resume:hover {
  background: linear-gradient(180deg, rgba(16,185,129,0.3), rgba(16,185,129,0.15));
  box-shadow: 0 3px 0 rgba(0,100,60,0.6), 0 0 12px rgba(16,185,129,0.4);
}
.btn-resume:active {
  box-shadow: 0 0 0 rgba(0,100,60,0.4), 0 1px 3px rgba(0,60,40,0.6) inset;
  background: linear-gradient(180deg, rgba(16,185,129,0.15), rgba(16,185,129,0.2));
}
.sidebar-section { margin-bottom: 20px; }
.sidebar-title { font-size: 10px; text-transform: uppercase; letter-spacing: 0.1em; color: var(--text-dim); font-weight: 600; margin-bottom: 8px; display: flex; justify-content: space-between; }
.metric { margin-bottom: 12px; }
.metric-label { display: flex; justify-content: space-between; font-size: 12px; color: var(--text-mute); margin-bottom: 4px; }
.metric-value { font-family: 'JetBrains Mono', monospace; font-weight: 600; color: var(--text); }
.bar { height: 4px; background: var(--surface-2); border-radius: 2px; overflow: hidden; }
.bar-fill { height: 100%; transition: width 0.4s ease, background 0.3s; }
.bar-fill.low { background: var(--blue); }
.bar-fill.mid { background: var(--green); }
.bar-fill.high { background: var(--amber); }
.bar-fill.critical { background: var(--red); }
.workers-row { display: flex; gap: 6px; }
.worker-chip { flex: 1; padding: 8px; background: var(--surface-2); border: 1px solid var(--border-strong); border-radius: 6px; font-size: 11px; text-align: center; }
.worker-chip.on { background: rgba(16,185,129,0.15); border-color: var(--green); }
.worker-chip .name { font-weight: 600; }
.worker-chip .age { font-family: 'JetBrains Mono', monospace; font-size: 10px; color: var(--text-mute); }
.sched-grid { display: grid; grid-template-columns: repeat(8, 1fr); gap: 4px; }
.sched-dot { width: 100%; aspect-ratio: 1; border-radius: 50%; background: var(--surface-3); }
.sched-dot.ready { background: var(--green); opacity: 0.7; }
.sched-dot.running { background: var(--green); box-shadow: 0 0 6px var(--green); }
.counts { display: grid; grid-template-columns: 1fr 1fr; gap: 8px; }
.count-cell { background: var(--surface-2); border-radius: 6px; padding: 8px; text-align: center; }
.count-num { font-family: 'JetBrains Mono', monospace; font-size: 20px; font-weight: 700; }
.count-label { font-size: 10px; color: var(--text-mute); text-transform: uppercase; }

/* Hero - 強化版モデル表示 */
.hero { background: linear-gradient(135deg, var(--surface) 0%, #0d0d10 100%); border: 1px solid var(--border); border-radius: 12px; padding: 18px; margin-bottom: 16px; }
.hero-title { font-size: 11px; text-transform: uppercase; letter-spacing: 0.1em; color: var(--text-dim); margin-bottom: 12px; display: flex; align-items: center; gap: 8px; }
.hero-title::before { content: "●"; color: var(--green); animation: pulse 1.5s infinite; }
.active-model-banner {
  display: flex; align-items: center; gap: 16px;
  padding: 14px 18px; margin-bottom: 12px;
  background: linear-gradient(90deg, rgba(139,92,246,0.15), rgba(59,130,246,0.05));
  border: 1px solid var(--border-strong); border-radius: 10px;
  position: relative; overflow: hidden;
}
.active-model-banner.heavy { background: linear-gradient(90deg, rgba(139,92,246,0.2), rgba(139,92,246,0.05)); border-color: rgba(139,92,246,0.4); }
.active-model-banner.light { background: linear-gradient(90deg, rgba(6,182,212,0.2), rgba(6,182,212,0.05)); border-color: rgba(6,182,212,0.4); }
.active-model-banner.idle { background: var(--surface-2); }
.model-icon { font-size: 32px; }
.model-info { flex: 1; }
.model-name-big { font-size: 20px; font-weight: 700; font-family: 'JetBrains Mono', monospace; }
.model-sub { font-size: 12px; color: var(--text-mute); margin-top: 4px; }
.model-vram { text-align: right; font-family: 'JetBrains Mono', monospace; }
.model-vram-num { font-size: 18px; font-weight: 700; color: var(--text); }
.model-vram-label { font-size: 10px; color: var(--text-mute); text-transform: uppercase; }

.proc-card { background: var(--surface-2); border: 1px solid var(--border-strong); border-radius: 8px; padding: 12px; margin-bottom: 8px; }
.proc-meta { display: flex; gap: 8px; align-items: center; margin-bottom: 8px; flex-wrap: wrap; }
.chip { font-size: 11px; padding: 3px 8px; border-radius: 4px; background: var(--surface-3); color: var(--text-mute); }
.chip.dept-research { background: rgba(59,130,246,0.2); color: #93c5fd; }
.chip.dept-newbiz { background: rgba(139,92,246,0.2); color: #c4b5fd; }
.chip.dept-marketing { background: rgba(245,158,11,0.2); color: #fcd34d; }
.chip.dept-dev { background: rgba(6,182,212,0.2); color: #67e8f9; }
.chip.dept-corp { background: rgba(16,185,129,0.2); color: #6ee7b7; }
.chip.dept-secretary { background: rgba(236,72,153,0.2); color: #f9a8d4; }
.chip.dept-misc { background: var(--surface-3); color: var(--text-mute); }
.chip.model-heavy { background: rgba(139,92,246,0.15); color: var(--purple); }
.chip.model-light { background: rgba(6,182,212,0.15); color: var(--cyan); }
.chip.priority-high { background: rgba(239,68,68,0.2); color: var(--red); }
.chip.priority-normal { background: rgba(59,130,246,0.2); color: var(--blue); }
.chip.priority-low { background: var(--surface-3); color: var(--text-mute); }
.proc-age { margin-left: auto; font-family: 'JetBrains Mono', monospace; font-size: 12px; color: var(--amber); }
.proc-age.long { color: var(--red); animation: pulse 1s infinite; }
.proc-title { font-size: 14px; font-weight: 500; }
.empty { text-align: center; padding: 30px 0; color: var(--text-dim); font-size: 13px; }

.task-cols { display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 12px; margin-bottom: 16px; }
.task-col { background: var(--surface); border: 1px solid var(--border); border-radius: 12px; padding: 12px; min-height: 300px; max-height: 600px; overflow-y: auto; }
.task-col-header { display: flex; justify-content: space-between; align-items: center; padding-bottom: 10px; margin-bottom: 10px; border-bottom: 1px solid var(--border); position: sticky; top: -12px; background: var(--surface); }
.task-col-title { font-size: 11px; text-transform: uppercase; letter-spacing: 0.1em; font-weight: 600; color: var(--text-mute); }
.task-col-count { font-family: 'JetBrains Mono', monospace; font-size: 14px; font-weight: 700; }
.task-item { padding: 8px 10px; margin-bottom: 4px; background: var(--surface-2); border-radius: 6px; font-size: 12px; border-left: 2px solid transparent; }
.task-item.high { border-left-color: var(--red); }
.task-item.normal { border-left-color: var(--blue); }
.task-item.low { border-left-color: var(--text-dim); }
.task-item-title { font-weight: 500; color: var(--text); line-height: 1.4; }
.task-item-meta { display: flex; gap: 6px; margin-top: 4px; font-size: 10px; color: var(--text-mute); font-family: 'JetBrains Mono', monospace; }

.models-bar { display: flex; gap: 8px; flex-wrap: wrap; background: var(--surface); border: 1px solid var(--border); border-radius: 12px; padding: 12px; }
.model-pill { background: var(--surface-2); border: 1px solid var(--border-strong); border-radius: 8px; padding: 8px 12px; display: flex; align-items: center; gap: 10px; font-size: 12px; }
.model-pill.heavy { border-color: var(--purple); }
.model-pill.light { border-color: var(--cyan); }
.model-pill-name { font-weight: 600; }
.model-pill-info { color: var(--text-mute); font-family: 'JetBrains Mono', monospace; font-size: 11px; }
.gpu-stats { display: flex; justify-content: space-between; font-size: 11px; color: var(--text-mute); font-family: 'JetBrains Mono', monospace; }
.paused-overlay { background: rgba(245,158,11,0.1); border: 1px solid var(--amber); border-radius: 8px; padding: 10px 14px; margin-bottom: 16px; color: var(--amber); font-weight: 600; display: flex; align-items: center; gap: 10px; }
@media (max-width: 1100px) { .task-cols { grid-template-columns: 1fr; } }
@media (max-width: 768px) { .app { grid-template-columns: 1fr; grid-template-areas: "header" "main"; } .sidebar { display: none; } }
</style>
</head>
<body>
<div class="app">
  <div class="header">
    <div style="display:flex; align-items:center; gap:24px;">
      <div class="brand"><span class="dot">●</span> Brain Live</div>
      <div class="nav-links">
        <a href="/" class="nav-link active">🧠 ダッシュボード</a>
        <a href="/org" class="nav-link">🏢 組織図</a>
        <a href="/pipeline" class="nav-link">🚀 新規事業</a>
        <a href="/departments" class="nav-link">🏢 部署タスク</a>
      </div>
    </div>
    <div class="header-stats">
      <button class="btn" id="pause-btn" onclick="togglePause()">⏸ 一時停止</button>
      <div class="pill" id="status-pill"><span id="status-text">⚪ 待機</span></div>
      <div class="pill"><span class="label">モデル</span><span class="mono" id="models-count">0</span></div>
      <div class="timestamp" id="timestamp">--:--:--</div>
    </div>
  </div>

  <div class="sidebar">
    <div class="sidebar-section">
      <div class="sidebar-title">Resource</div>
      <div class="metric"><div class="metric-label"><span>CPU</span><span class="metric-value" id="cpu-val">--%</span></div><div class="bar"><div class="bar-fill" id="cpu-bar"></div></div></div>
      <div class="metric"><div class="metric-label"><span>RAM</span><span class="metric-value" id="ram-val">--%</span></div><div class="bar"><div class="bar-fill" id="ram-bar"></div></div><div class="metric-label" style="margin-top:2px;"><span style="font-size:10px;" id="ram-sub">-- GB</span></div></div>
      <div class="metric"><div class="metric-label"><span>GPU</span><span class="metric-value" id="gpu-val">--%</span></div><div class="bar"><div class="bar-fill" id="gpu-bar"></div></div><div class="gpu-stats" style="margin-top:4px;"><span id="gpu-vram">VRAM:--</span><span id="gpu-temp">--°C</span></div></div>
    </div>
    <div class="sidebar-section">
      <div class="sidebar-title">Workers</div>
      <div class="workers-row">
        <div class="worker-chip" id="worker-heavy"><div class="name">Heavy</div><div class="age" id="heavy-age">--</div></div>
        <div class="worker-chip" id="worker-light"><div class="name">Light</div><div class="age" id="light-age">--</div></div>
      </div>
    </div>
    <div class="sidebar-section">
      <div class="sidebar-title">Schedulers <span class="mono" id="sched-count" style="color:var(--text-mute);">--</span></div>
      <div class="sched-grid" id="sched-grid"></div>
    </div>
    <div class="sidebar-section">
      <div class="sidebar-title">Totals</div>
      <div class="counts">
        <div class="count-cell"><div class="count-num mono" id="cnt-today">--</div><div class="count-label">Today</div></div>
        <div class="count-cell"><div class="count-num mono" id="cnt-week">--</div><div class="count-label">Week</div></div>
      </div>
    </div>
  </div>

  <div class="main">
    <div id="paused-overlay-container"></div>
    <div class="hero">
      <div class="hero-title">いま何をやっているか</div>
      <div id="active-model-section"></div>
      <div id="hero-content"><div class="empty">処理待ち...</div></div>
    </div>
    <div class="task-cols">
      <div class="task-col">
        <div class="task-col-header"><div class="task-col-title">📥 未完了 Inbox</div><div class="task-col-count mono" id="col-inbox-count">0</div></div>
        <div id="col-inbox"></div>
      </div>
      <div class="task-col">
        <div class="task-col-header"><div class="task-col-title">⚙️ 着手中 Processing</div><div class="task-col-count mono" id="col-proc-count">0</div></div>
        <div id="col-proc"></div>
      </div>
      <div class="task-col">
        <div class="task-col-header"><div class="task-col-title">✅ 完了 Today</div><div class="task-col-count mono" id="col-done-count">0</div></div>
        <div id="col-done"></div>
      </div>
    </div>
    <div class="models-bar" id="models-bar"><div class="empty">モデル未ロード</div></div>
  </div>
</div>

<script>
function barClass(p){if(p>=90)return'critical';if(p>=70)return'high';if(p>=30)return'mid';return'low';}
function deptChip(d){if(!d)return'';return'<span class="chip dept-'+d+'">'+d+'</span>';}
function modelChip(m){if(!m)return'';const h=m.includes('qwen3.6')||m.includes('latest');return'<span class="chip model-'+(h?'heavy':'light')+'">'+m+'</span>';}
function priorityChip(p){if(!p)return'';return'<span class="chip priority-'+p+'">'+p+'</span>';}
function formatAge(s){if(s<60)return s+'s';if(s<3600)return Math.floor(s/60)+'m '+(s%60)+'s';return Math.floor(s/3600)+'h '+Math.floor((s%3600)/60)+'m';}
function escapeHtml(s){if(!s)return'';return s.replace(/[&<>"']/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]));}

async function togglePause(){
    const btn = document.getElementById('pause-btn');
    btn.disabled = true;
    btn.style.opacity = '0.5';
    try {
        const r = await fetch('/api/toggle-pause', { method: 'POST' });
        await r.json();
        await fetchStatus();
    } finally {
        btn.disabled = false;
        btn.style.opacity = '1';
    }
}

async function fetchStatus(){
    try{const r=await fetch('/api/status');const d=await r.json();render(d);}catch(e){console.error(e);}
}

function render(d){
    // Pause button
    const pauseBtn = document.getElementById('pause-btn');
    if (d.paused) {
        pauseBtn.textContent = '▶ 再開';
        pauseBtn.className = 'btn btn-resume';
        document.getElementById('paused-overlay-container').innerHTML =
            '<div class="paused-overlay">⏸ システム一時停止中 — workers/idle_filler が処理を停止しています</div>';
    } else {
        pauseBtn.textContent = '⏸ 一時停止';
        pauseBtn.className = 'btn btn-pause';
        document.getElementById('paused-overlay-container').innerHTML = '';
    }

    document.getElementById('timestamp').textContent = new Date(d.timestamp).toLocaleTimeString('ja-JP');
    document.getElementById('models-count').textContent = d.ollama.loadedModels.length;

    const isBusy = d.queue.processing.length > 0 || d.workers.heavy || d.workers.light || d.ollama.loadedModels.length > 0;
    const sp = document.getElementById('status-pill');
    const st = document.getElementById('status-text');
    if (d.paused) { sp.className = 'pill paused'; st.textContent = '⏸ 停止中'; }
    else if (isBusy) { sp.className = 'pill busy'; st.textContent = '🔥 稼働中'; }
    else { sp.className = 'pill idle'; st.textContent = '⚪ 待機'; }

    const cpu = d.cpu !== null ? d.cpu : 0;
    document.getElementById('cpu-val').textContent = cpu.toFixed(1) + '%';
    const cb = document.getElementById('cpu-bar'); cb.style.width = cpu + '%'; cb.className = 'bar-fill ' + barClass(cpu);
    document.getElementById('ram-val').textContent = d.memory.percent + '%';
    const rb = document.getElementById('ram-bar'); rb.style.width = d.memory.percent + '%'; rb.className = 'bar-fill ' + barClass(d.memory.percent);
    document.getElementById('ram-sub').textContent = d.memory.usedGB + ' / ' + d.memory.totalGB + ' GB';
    if (d.gpu) {
        document.getElementById('gpu-val').textContent = d.gpu.util + '%';
        const gb = document.getElementById('gpu-bar'); gb.style.width = d.gpu.util + '%'; gb.className = 'bar-fill ' + barClass(d.gpu.util);
        const vp = Math.round(d.gpu.vramUsedMB / d.gpu.vramTotalMB * 100);
        document.getElementById('gpu-vram').textContent = 'VRAM:' + vp + '%';
        document.getElementById('gpu-temp').textContent = d.gpu.tempC + '°C';
    }

    const he = document.getElementById('worker-heavy');
    he.className = 'worker-chip ' + (d.workers.heavy ? 'on' : '');
    document.getElementById('heavy-age').textContent = d.workers.heavy ? formatAge(d.workers.heavyAge) : 'idle';
    const le = document.getElementById('worker-light');
    le.className = 'worker-chip ' + (d.workers.light ? 'on' : '');
    document.getElementById('light-age').textContent = d.workers.light ? formatAge(d.workers.lightAge) : 'idle';

    document.getElementById('sched-count').textContent = d.schedulers.length;
    document.getElementById('sched-grid').innerHTML = d.schedulers.map(s => {
        const cls = s.status === 'Running' ? 'running' : (s.status === 'Ready' ? 'ready' : '');
        return '<div class="sched-dot ' + cls + '" title="' + s.name + ' (' + s.status + ')"></div>';
    }).join('');

    document.getElementById('cnt-today').textContent = d.counts.todayDone;
    document.getElementById('cnt-week').textContent = d.counts.weekDone;

    // === Active Model Banner (新規・強化版) ===
    const amSection = document.getElementById('active-model-section');
    if (d.ollama.loadedModels.length > 0) {
        // 最も大きいモデル＝今ロード中のメイン
        const main = d.ollama.loadedModels[0];
        const isHeavy = main.name.includes('qwen3.6') || main.name.includes('latest');
        const sizeGB = Math.round(main.size / 1024 / 1024 / 1024 * 10) / 10;
        const vramGB = main.size_vram ? Math.round(main.size_vram / 1024 / 1024 / 1024 * 10) / 10 : 0;
        let expires = '';
        if (main.expires_at) {
            const remMin = Math.round((new Date(main.expires_at) - new Date()) / 60000);
            expires = remMin > 0 ? '残り ' + remMin + '分でアンロード' : 'アンロード予定時刻通過';
        }
        amSection.innerHTML =
            '<div class="active-model-banner ' + (isHeavy ? 'heavy' : 'light') + '">' +
                '<div class="model-icon">🦙</div>' +
                '<div class="model-info">' +
                    '<div class="model-name-big">' + main.name + '</div>' +
                    '<div class="model-sub">' + '⚡ qwen3:8b · 8GB GPU最適化 (num_ctx 8192)' + ' · ' + expires + '</div>' +
                '</div>' +
                '<div class="model-vram">' +
                    '<div class="model-vram-num">' + vramGB + ' GB</div>' +
                    '<div class="model-vram-label">VRAM 使用</div>' +
                '</div>' +
            '</div>';
    } else {
        amSection.innerHTML =
            '<div class="active-model-banner idle">' +
                '<div class="model-icon">💤</div>' +
                '<div class="model-info">' +
                    '<div class="model-name-big" style="color:var(--text-mute);">モデル未ロード</div>' +
                    '<div class="model-sub">タスク待機中 — 次のリクエストでロード</div>' +
                '</div>' +
            '</div>';
    }

    // Hero processing
    const heroEl = document.getElementById('hero-content');
    if (d.queue.processing.length > 0) {
        heroEl.innerHTML = d.queue.processing.map(p => {
            const ageCls = p.ageSec > 600 ? 'long' : '';
            return '<div class="proc-card">' +
                '<div class="proc-meta">' +
                    deptChip(p.department) + modelChip(p.model) + priorityChip(p.priority) +
                    (p.use_agent ? '<span class="chip" style="background:rgba(139,92,246,0.2);color:#c4b5fd;">agent</span>' : '') +
                    '<div class="proc-age ' + ageCls + ' mono">⏱ ' + formatAge(p.ageSec) + '</div>' +
                '</div>' +
                '<div class="proc-title">' + escapeHtml(p.title) + '</div>' +
            '</div>';
        }).join('');
    } else {
        heroEl.innerHTML = '<div class="empty">処理中タスクなし</div>';
    }

    document.getElementById('col-inbox-count').textContent = d.queue.inbox.length;
    document.getElementById('col-inbox').innerHTML = d.queue.inbox.length > 0
        ? d.queue.inbox.slice(0, 25).map(i =>
            '<div class="task-item ' + (i.priority || 'normal') + '">' +
                '<div class="task-item-title">' + escapeHtml(i.title) + '</div>' +
                '<div class="task-item-meta">' + (i.department || '') + ' · ' + (i.model || '') + '</div>' +
            '</div>'
          ).join('')
        : '<div class="empty">空</div>';

    document.getElementById('col-proc-count').textContent = d.queue.processing.length;
    document.getElementById('col-proc').innerHTML = d.queue.processing.length > 0
        ? d.queue.processing.map(p => {
            const ageCls = p.ageSec > 600 ? 'high' : 'normal';
            return '<div class="task-item ' + ageCls + '">' +
                '<div class="task-item-title">' + escapeHtml(p.title) + '</div>' +
                '<div class="task-item-meta">' + (p.department || '') + ' · ⏱ ' + formatAge(p.ageSec) + '</div>' +
            '</div>';
        }).join('')
        : '<div class="empty">なし</div>';

    document.getElementById('col-done-count').textContent = d.queue.done.length;
    document.getElementById('col-done').innerHTML = d.queue.done.length > 0
        ? d.queue.done.slice(0, 30).map(item => {
            const time = item.completedAt ? item.completedAt.substring(11, 16) : '';
            return '<div class="task-item ' + (item.priority || 'normal') + '">' +
                '<div class="task-item-title">' + escapeHtml(item.title) + '</div>' +
                '<div class="task-item-meta">' + time + ' · ' + (item.department || '') + ' · ' + (item.model || '') + '</div>' +
            '</div>';
        }).join('')
        : '<div class="empty">今日まだ</div>';

    if (d.ollama.loadedModels.length > 0) {
        document.getElementById('models-bar').innerHTML = d.ollama.loadedModels.map(m => {
            const sizeGB = Math.round(m.size / 1024 / 1024 / 1024 * 10) / 10;
            const vramGB = m.size_vram ? Math.round(m.size_vram / 1024 / 1024 / 1024 * 10) / 10 : 0;
            let exp = '';
            if (m.expires_at) {
                const rm = Math.round((new Date(m.expires_at) - new Date()) / 60000);
                exp = '<span class="model-pill-info">unload ' + rm + 'min</span>';
            }
            const cls = m.name.includes('qwen3.6') ? 'heavy' : 'light';
            return '<div class="model-pill ' + cls + '">' +
                '<span class="model-pill-name">' + m.name + '</span>' +
                '<span class="model-pill-info">' + sizeGB + 'GB</span>' +
                '<span class="model-pill-info">VRAM ' + vramGB + 'GB</span>' + exp +
            '</div>';
        }).join('');
    } else {
        document.getElementById('models-bar').innerHTML = '<div class="empty">モデル未ロード</div>';
    }
}

fetchStatus();
setInterval(fetchStatus, 2000);
</script>
</body></html>`;

// ===== Organization HTML =====
const HTML_ORG = `<!DOCTYPE html>
<html lang="ja"><head>
<meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>🏢 Brain Organization</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@400;600&family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
<style>
${COMMON_CSS}
.app { display: grid; grid-template-rows: 56px 1fr; height: 100vh; overflow: hidden; }
.header { display: flex; align-items: center; justify-content: space-between; padding: 0 20px; border-bottom: 1px solid var(--border); background: rgba(0,0,0,0.8); }
.brand { font-weight: 700; font-size: 15px; }
.brand .dot { color: var(--green); animation: pulse 1.5s infinite; }
@keyframes pulse { 0%,100%{opacity:1} 50%{opacity:0.4} }
.nav-links { display: flex; gap: 12px; margin-left: 24px; }
.nav-link { font-size: 12px; padding: 6px 12px; border-radius: 6px; color: var(--text-mute); }
.nav-link.active { background: var(--surface-2); color: var(--text); }
.main { padding: 30px; overflow-y: auto; }
h1 { font-size: 24px; margin-bottom: 8px; }
.intro { color: var(--text-mute); margin-bottom: 32px; }

/* 組織図 */
.org-tree { display: flex; flex-direction: column; align-items: center; gap: 20px; }
.node {
  background: var(--surface); border: 1px solid var(--border-strong);
  border-radius: 10px; padding: 14px 20px; min-width: 160px; text-align: center;
  transition: all 0.3s;
}
.node:hover { transform: translateY(-2px); border-color: var(--text-mute); }
.node-title { font-weight: 700; font-size: 14px; }
.node-sub { font-size: 11px; color: var(--text-mute); margin-top: 4px; font-family: 'JetBrains Mono', monospace; }
.node-role { font-size: 10px; color: var(--text-dim); margin-top: 2px; }
.node.owner { background: linear-gradient(135deg, rgba(245,158,11,0.2), rgba(245,158,11,0.05)); border-color: var(--amber); }
.node.ceo { background: linear-gradient(135deg, rgba(59,130,246,0.2), rgba(59,130,246,0.05)); border-color: var(--blue); }
.node.dept { background: linear-gradient(135deg, rgba(139,92,246,0.1), transparent); border-color: var(--purple); min-width: 200px; }
.node.agent { background: var(--surface-2); }
.node.openclaw { background: rgba(6,182,212,0.05); border-color: var(--cyan); }

.line-down { width: 2px; height: 24px; background: var(--border-strong); }

.dept-row { display: grid; grid-template-columns: repeat(6, 1fr); gap: 16px; width: 100%; max-width: 1400px; margin-top: 0; }
.dept-col { display: flex; flex-direction: column; align-items: center; gap: 12px; }
.dept-col .line-down { height: 16px; }
.dept-tasks { font-size: 10px; color: var(--text-dim); margin-top: 6px; padding: 4px 8px; background: var(--surface-3); border-radius: 4px; font-family: 'JetBrains Mono', monospace; }

.legend { display: flex; gap: 20px; margin: 30px 0; padding: 14px; background: var(--surface); border: 1px solid var(--border); border-radius: 8px; }
.legend-item { display: flex; align-items: center; gap: 8px; font-size: 12px; }
.legend-box { width: 16px; height: 16px; border-radius: 4px; }

.flow-section { margin-top: 50px; }
.flow-section h2 { font-size: 16px; margin-bottom: 16px; color: var(--text-mute); text-transform: uppercase; letter-spacing: 0.1em; }
.flow-diagram { background: var(--surface); border: 1px solid var(--border); border-radius: 12px; padding: 20px; font-family: 'JetBrains Mono', monospace; font-size: 13px; white-space: pre; color: var(--text-mute); line-height: 1.8; overflow-x: auto; }
.flow-diagram .hl { color: var(--text); font-weight: 600; }
.flow-diagram .h { color: var(--purple); }
.flow-diagram .l { color: var(--cyan); }
.flow-diagram .a { color: var(--amber); }

@media (max-width: 1100px) { .dept-row { grid-template-columns: repeat(2, 1fr); } }
</style>
</head>
<body>
<div class="app">
  <div class="header">
    <div style="display:flex; align-items:center;">
      <div class="brand"><span class="dot">●</span> Brain Live</div>
      <div class="nav-links">
        <a href="/" class="nav-link">🧠 ダッシュボード</a>
        <a href="/org" class="nav-link active">🏢 組織図</a>
        <a href="/pipeline" class="nav-link">🚀 新規事業</a>
        <a href="/departments" class="nav-link">🏢 部署タスク</a>
      </div>
    </div>
  </div>

  <div class="main">
    <h1>🏢 Brain System 組織図</h1>
    <div class="intro">大井湧瑛 株式会社の AI組織構造。CEOが全体を統括し、各部署のClaude エージェントがOpenClaw社員（qwen3:8b・8GB GPU最適化済）を使ってタスクを実行。</div>

    <div class="legend">
      <div class="legend-item"><div class="legend-box" style="background:rgba(245,158,11,0.5); border:1px solid var(--amber);"></div><span>Owner（大井湧瑛）</span></div>
      <div class="legend-item"><div class="legend-box" style="background:rgba(59,130,246,0.5); border:1px solid var(--blue);"></div><span>CEO（Claude Sonnet）</span></div>
      <div class="legend-item"><div class="legend-box" style="background:rgba(139,92,246,0.3); border:1px solid var(--purple);"></div><span>部署エージェント</span></div>
      <div class="legend-item"><div class="legend-box" style="background:rgba(6,182,212,0.2); border:1px solid var(--cyan);"></div><span>OpenClaw社員（Ollama）</span></div>
    </div>

    <div class="org-tree">
      <div class="node owner">
        <div class="node-title">👤 大井湧瑛</div>
        <div class="node-sub">Owner / Founder</div>
        <div class="node-role">指示・判断・最終承認</div>
      </div>
      <div class="line-down"></div>
      <div class="node ceo">
        <div class="node-title">🧠 Claude Sonnet</div>
        <div class="node-sub">CEO / 秘書 / マネージャー</div>
        <div class="node-role">発話分解 / dispatch / レビュー</div>
      </div>
      <div class="line-down"></div>

      <div class="dept-row">
        <!-- Research -->
        <div class="dept-col">
          <div class="node dept" style="border-color:rgba(59,130,246,0.6);">
            <div class="node-title" style="color:#93c5fd;">🔍 Research</div>
            <div class="node-sub">経営企画室</div>
          </div>
          <div class="line-down"></div>
          <div class="node agent">
            <div class="node-title">researcher</div>
            <div class="node-role">市場・競合・技術</div>
          </div>
          <div class="line-down"></div>
          <div class="node openclaw">
            <div class="node-title">🦞 research-agent</div>
            <div class="node-sub">qwen3:8b</div>
          </div>
          <div class="dept-tasks">BG-Competitive<br>BG-AINews<br>monitor</div>
        </div>

        <!-- Newbiz -->
        <div class="dept-col">
          <div class="node dept">
            <div class="node-title" style="color:#c4b5fd;">💡 Newbiz</div>
            <div class="node-sub">新規事業部</div>
          </div>
          <div class="line-down"></div>
          <div class="node agent">
            <div class="node-title">venture-director</div>
            <div class="node-role">+idea-generator他4</div>
          </div>
          <div class="line-down"></div>
          <div class="node openclaw">
            <div class="node-title">🦞 newbiz-agent</div>
            <div class="node-sub">qwen3:8b</div>
          </div>
          <div class="dept-tasks">BG-Business<br>BG-AppBattery<br>BG-Entities</div>
        </div>

        <!-- Marketing -->
        <div class="dept-col">
          <div class="node dept" style="border-color:rgba(245,158,11,0.6);">
            <div class="node-title" style="color:#fcd34d;">📣 Marketing</div>
            <div class="node-sub">営業マーケCS</div>
          </div>
          <div class="line-down"></div>
          <div class="node agent">
            <div class="node-title">marketer / sales-rep / cs</div>
            <div class="node-role">3エージェント</div>
          </div>
          <div class="line-down"></div>
          <div class="node openclaw">
            <div class="node-title">🦞 marketing-agent</div>
            <div class="node-sub">qwen3:8b (軽量)</div>
          </div>
          <div class="dept-tasks">BG-AipaOutreach<br>SEO/LP/メール</div>
        </div>

        <!-- Dev -->
        <div class="dept-col">
          <div class="node dept" style="border-color:rgba(6,182,212,0.6);">
            <div class="node-title" style="color:#67e8f9;">💻 Dev</div>
            <div class="node-sub">開発部</div>
          </div>
          <div class="line-down"></div>
          <div class="node agent">
            <div class="node-title">developer + 12エージェント</div>
            <div class="node-role">planner/tdd/code-review他</div>
          </div>
          <div class="line-down"></div>
          <div class="node openclaw">
            <div class="node-title">🦞 dev-agent</div>
            <div class="node-sub">qwen3:8b</div>
          </div>
          <div class="dept-tasks">README<br>API docs</div>
        </div>

        <!-- Corp -->
        <div class="dept-col">
          <div class="node dept" style="border-color:rgba(16,185,129,0.6);">
            <div class="node-title" style="color:#6ee7b7;">💰 Corp</div>
            <div class="node-sub">コーポレート</div>
          </div>
          <div class="line-down"></div>
          <div class="node agent">
            <div class="node-title">cfo / legal / hr</div>
            <div class="node-role">3エージェント</div>
          </div>
          <div class="line-down"></div>
          <div class="node openclaw">
            <div class="node-title">🦞 main</div>
            <div class="node-sub">qwen3:8b</div>
          </div>
          <div class="dept-tasks">数字レポ<br>契約条項</div>
        </div>

        <!-- Secretary -->
        <div class="dept-col">
          <div class="node dept" style="border-color:rgba(236,72,153,0.6);">
            <div class="node-title" style="color:#f9a8d4;">📋 Secretary</div>
            <div class="node-sub">秘書室</div>
          </div>
          <div class="line-down"></div>
          <div class="node agent">
            <div class="node-title">secretary / cos</div>
            <div class="node-role">大井専属＋メール係</div>
          </div>
          <div class="line-down"></div>
          <div class="node openclaw">
            <div class="node-title">🦞 main</div>
            <div class="node-sub">qwen3:8b</div>
          </div>
          <div class="dept-tasks">議事録<br>日報</div>
        </div>
      </div>
    </div>

    <!-- データフロー -->
    <div class="flow-section">
      <h2>🔄 タスク処理フロー</h2>
      <div class="flow-diagram">
<span class="hl">[👤 大井]</span> 「○○調べて」（発話 or Discord or アイデア書き殴り）
        │
        ▼
<span class="hl">[🧠 CEO Claude]</span> 受信 → タスク分解 → 部署判定
        │
        ▼
   <span class="hl">dispatch.ps1</span>  → queue/inbox/{priority}-{stamp}-{id}.json
        │
        ▼
<span class="hl">[👷 BrainWorker]</span> 1分おき / レーン振り分け（priority/use_agent/model）
        ├─── <span class="h">Heavy lane (qwen3.6:latest)</span>   重い判断・統合
        └─── <span class="l">Light lane (qwen3:8b)</span>          量産・整形・要約
        │
        ▼
   <span class="hl">処理 → queue/results/{id}.md</span> 保存（task_idユニーク）
        │
        ▼
   <span class="hl">harvest.ps1</span> (1時間おき) → wiki/_inbox/{部署}/
        │
        ▼
<span class="hl">[🧠 CEO Claude]</span> midday/evening でレビュー
        ├─── PROMOTE → wiki/_promoted/ や entities/ へ昇格
        ├─── MERGE → entities統合（手動）
        └─── ARCHIVE → wiki/_inbox/_archive/
        │
        ▼
   <span class="hl">wiki/ ナレッジ蓄積</span>（複利で太る）
      </div>
    </div>

    <!-- 自動稼働サイクル -->
    <div class="flow-section">
      <h2>⏰ 自動稼働サイクル</h2>
      <div class="flow-diagram">
<span class="a">07:00</span> morning-catchup (リモート・Gmail/Calendar/Stripe コネクター)
<span class="a">07:30</span> BrainBGAINews   (HN/arXiv/Anthropic → 業界動向)
<span class="a">07:55</span> BrainHealth     (自動修復 + Discord通知)
<span class="a">08:00</span> Morning routine (ローカル・今日の作戦)
<span class="a">08:30</span> BrainMonitor    (競合3本・締切・朝の問い)
<span class="a">09:15</span> BrainBGAppBattery   (アプリ量産 5案/日 → 100案完成)
<span class="a">09:30</span> BrainBGContests     (ビジコン10件/日 深掘り)
<span class="a">09:45</span> BrainBGAipaOutreach (AIpa Web 顧客リスト/メール/分析 循環)
<span class="a">10:00</span> BrainBGEntities     (entities/ 2件/日 更新)
<span class="a">10:30</span> BrainBGBusiness     (15事業×4視点 = 60ファイル深掘り)
<span class="a">11:00</span> BrainBGCompetitive  (競合5社/日 動向)
<span class="a">11:30</span> BrainAggCompetitive (meta/competitive-intel.md 自動更新)
<span class="a">13:00</span> Midday routine   (進捗確認 + PDCAレビュー)
<span class="a">21:00</span> Evening routine  (振り返り + 明日仕込み)
<span class="a">22:00</span> BrainSelfReview  (日曜のみ・自己改善ループ)
<span class="a">23:00</span> DailyBrainOllama (自動日報生成)

<span class="hl">常時稼働:</span>
1min: BrainWorkerHeavy / BrainWorkerLight (qwen3.6 / qwen3:8b 並列)
5min: BrainTaskBoard (today.md更新) / BrainIdleFiller (5軸pool・inbox補充)
1min: BrainLiveStatus (live-status.md)
1hr:  BrainHarvest (results→wiki/_inbox) / BrainAutoReview
      </div>
    </div>
  </div>
</div>
</body></html>`;

const HTML_DEPARTMENTS = `<!DOCTYPE html>
<html lang="ja"><head><meta charset="UTF-8"><title>🏢 部署別タスクボード</title>
<style>
  * { box-sizing: border-box; margin: 0; padding: 0; }
  body { font-family: -apple-system,'Hiragino Kaku Gothic ProN','BIZ UDPGothic',sans-serif;
    background: #0a0e1a; color: #e0e7ff; padding: 20px; line-height: 1.7; min-height: 100vh; }
  header { display: flex; justify-content: space-between; align-items: center; padding-bottom: 18px;
    border-bottom: 1px solid #1f2937; margin-bottom: 24px; }
  h1 { font-size: 22px; background: linear-gradient(90deg, #fbbf24, #f59e0b, #ef4444);
    -webkit-background-clip: text; background-clip: text; color: transparent; }
  nav a { color: #818cf8; text-decoration: none; margin-left: 16px; font-size: 14px; }
  nav a:hover { color: #c4b5fd; }
  nav a.active { color: #fbbf24; font-weight: bold; }
  .stats { display: grid; grid-template-columns: repeat(4, 1fr); gap: 12px; margin-bottom: 24px; }
  .stat { background: #111827; border: 1px solid #1f2937; border-radius: 8px; padding: 14px; text-align: center; }
  .stat-label { font-size: 11px; color: #9ca3af; margin-bottom: 4px; }
  .stat-value { font-size: 28px; font-weight: bold; }
  .dept-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(360px, 1fr)); gap: 16px; margin-bottom: 28px; }
  .dept { background: #0f172a; border: 1px solid #1e293b; border-radius: 12px; padding: 16px; }
  .dept-h { display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px; }
  .dept-t { font-size: 16px; font-weight: bold; }
  .dept-d { font-size: 11px; color: #6b7280; margin-bottom: 12px; }
  .dept-meta { font-size: 10px; color: #4b5563; margin-bottom: 12px; padding: 6px 8px; background: #0a0e1a; border-radius: 4px; }
  .dept-stats { display: grid; grid-template-columns: repeat(5, 1fr); gap: 4px; margin-bottom: 12px; font-size: 11px; }
  .ds { background: #1f2937; padding: 6px 4px; border-radius: 4px; text-align: center; }
  .ds-num { font-size: 16px; font-weight: bold; }
  .ds-lbl { color: #9ca3af; font-size: 9px; }
  .tasks { max-height: 240px; overflow-y: auto; }
  .task { padding: 6px 8px; margin-bottom: 4px; border-left: 3px solid #4b5563; font-size: 11px; border-radius: 3px; background: rgba(255,255,255,0.02); }
  .task.processing { border-left-color: #fbbf24; background: rgba(251,191,36,0.08); }
  .task.waiting { border-left-color: #6b7280; }
  .task.done { border-left-color: #10b981; opacity: 0.7; }
  .task-t { color: #f9fafb; }
  .task-m { font-size: 9px; color: #6b7280; margin-top: 2px; display: flex; gap: 8px; }
  .pri-high { color: #ef4444; font-weight: bold; }
  .pri-normal { color: #9ca3af; }
  .pri-low { color: #4b5563; }
  .recent-section { background: #0f172a; border: 1px solid #1e293b; border-radius: 12px; padding: 16px; }
  .recent-section h2 { font-size: 14px; margin-bottom: 12px; color: #fbbf24; }
  .recent-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(280px, 1fr)); gap: 8px; }
  .recent-item { background: #1f2937; padding: 8px 10px; border-radius: 4px; font-size: 11px; border-left: 3px solid #10b981; }
  .recent-item .ri-t { color: #f9fafb; margin-bottom: 3px; }
  .recent-item .ri-m { font-size: 9px; color: #9ca3af; }
  .empty { color: #4b5563; font-style: italic; font-size: 10px; text-align: center; padding: 12px; }
</style></head>
<body>
<header>
  <h1>🏢 部署別タスクボード</h1>
  <nav>
    <a href="/">🧠 ダッシュボード</a>
    <a href="/org">🏢 組織図</a>
    <a href="/pipeline">🚀 新規事業</a>
    <a href="/departments" class="active">🏢 部署タスク</a>
  </nav>
</header>

<div class="stats" id="stats"></div>
<div class="dept-grid" id="deptGrid"></div>
<div class="recent-section">
  <h2>📜 直近完了タスク (全部署・最新30件)</h2>
  <div class="recent-grid" id="recentList"></div>
</div>

<script>
function ago(iso) {
  const m = Math.round((Date.now() - new Date(iso)) / 60000);
  if (m < 60) return m + 'm前';
  if (m < 1440) return Math.floor(m/60) + 'h前';
  return Math.floor(m/1440) + 'd前';
}
async function load() {
  try {
    const r = await fetch('/api/departments');
    const d = await r.json();

    document.getElementById('stats').innerHTML = \`
      <div class="stat"><div class="stat-label">待機中</div><div class="stat-value" style="color:#6b7280">\${d.totals.waiting}</div></div>
      <div class="stat"><div class="stat-label">処理中</div><div class="stat-value" style="color:#fbbf24">\${d.totals.processing}</div></div>
      <div class="stat"><div class="stat-label">24h完了</div><div class="stat-value" style="color:#10b981">\${d.totals.done24h}</div></div>
      <div class="stat"><div class="stat-label">総完了</div><div class="stat-value" style="color:#a78bfa">\${d.totals.doneAll}</div></div>
    \`;

    document.getElementById('deptGrid').innerHTML = d.departments.map(dept => \`
      <div class="dept" style="border-top:3px solid \${dept.color}">
        <div class="dept-h">
          <span class="dept-t" style="color:\${dept.color}">\${dept.label}</span>
        </div>
        <div class="dept-d">\${dept.desc}</div>
        <div class="dept-meta">
          🤖 \${dept.agent}<br>
          ⚙️ \${dept.filler}
        </div>
        <div class="dept-stats">
          <div class="ds"><div class="ds-num" style="color:#6b7280">\${dept.waiting}</div><div class="ds-lbl">待機</div></div>
          <div class="ds"><div class="ds-num" style="color:#fbbf24">\${dept.processing}</div><div class="ds-lbl">処理中</div></div>
          <div class="ds"><div class="ds-num" style="color:#10b981">\${dept.done24h}</div><div class="ds-lbl">24h完了</div></div>
          <div class="ds"><div class="ds-num" style="color:#a78bfa">\${dept.promotedMd}</div><div class="ds-lbl">昇格</div></div>
          <div class="ds"><div class="ds-num" style="color:#f59e0b">\${dept.finalMd}</div><div class="ds-lbl">Final</div></div>
        </div>
        <div class="tasks">
          \${dept.tasksNow.length === 0 ? '<div class="empty">タスクなし</div>' :
            dept.tasksNow.map(t => \`
              <div class="task \${t.status}">
                <div class="task-t">\${t.title || '(no title)'}</div>
                <div class="task-m">
                  <span>\${t.status === 'processing' ? '⚙️ 処理中' : t.status === 'waiting' ? '⏳ 待機' : '✓ 完了'}</span>
                  <span class="pri-\${t.priority || 'normal'}">[\${t.priority || 'normal'}]</span>
                  <span>\${ago(t.time)}</span>
                </div>
              </div>
            \`).join('')
          }
        </div>
      </div>
    \`).join('');

    document.getElementById('recentList').innerHTML = d.recentDone.length === 0 ?
      '<div class="empty">まだ完了タスクなし</div>' :
      d.recentDone.map(t => {
        const deptObj = d.departments.find(x => x.key === t.department);
        const c = deptObj ? deptObj.color : '#10b981';
        return \`<div class="recent-item" style="border-left-color:\${c}">
          <div class="ri-t">\${t.title || '(no title)'}</div>
          <div class="ri-m">\${t.department} / \${t.priority || 'normal'} / \${ago(t.completed_at)}</div>
        </div>\`;
      }).join('');
  } catch (e) {
    document.body.innerHTML += '<p style="color:red">Error: ' + e.message + '</p>';
  }
}
load();
setInterval(load, 10000);
</script>
</body></html>`;

const HTML_PIPELINE = `<!DOCTYPE html>
<html lang="ja"><head><meta charset="UTF-8"><title>🚀 新規事業 ∞ パイプライン</title>
<style>
  * { box-sizing: border-box; margin: 0; padding: 0; }
  body { font-family: -apple-system,'Hiragino Kaku Gothic ProN','BIZ UDPGothic',sans-serif;
    background: #0a0e1a; color: #e0e7ff; padding: 20px; line-height: 1.7; min-height: 100vh; }
  header { display: flex; justify-content: space-between; align-items: center; padding-bottom: 18px;
    border-bottom: 1px solid #1f2937; margin-bottom: 20px; }
  h1 { font-size: 22px; background: linear-gradient(90deg, #a78bfa, #60a5fa, #34d399);
    -webkit-background-clip: text; background-clip: text; color: transparent; }
  nav a { color: #818cf8; text-decoration: none; margin-left: 16px; font-size: 14px; }
  nav a:hover { color: #c4b5fd; }
  .summary { display: grid; grid-template-columns: repeat(4, 1fr); gap: 12px; margin-bottom: 24px; }
  .stat { background: #111827; border: 1px solid #1f2937; border-radius: 8px; padding: 14px; text-align: center; }
  .stat-label { font-size: 11px; color: #9ca3af; margin-bottom: 4px; }
  .stat-value { font-size: 28px; font-weight: bold; color: #f9fafb; }
  .kanban { display: grid; grid-template-columns: repeat(5, 1fr); gap: 10px; margin-bottom: 28px; }
  .col { background: #0f172a; border: 1px solid #1e293b; border-radius: 10px; padding: 12px; min-height: 400px; }
  .col-h { display: flex; justify-content: space-between; align-items: baseline; padding-bottom: 8px;
    margin-bottom: 10px; border-bottom: 1px solid #1e293b; }
  .col-t { font-size: 14px; font-weight: bold; color: #e0e7ff; }
  .col-c { background: #1e3a8a; color: #93c5fd; padding: 2px 8px; border-radius: 10px; font-size: 11px; }
  .col-d { font-size: 10px; color: #6b7280; margin-bottom: 8px; }
  .card { background: #1f2937; border-radius: 6px; padding: 8px 10px; margin-bottom: 6px; font-size: 11px;
    border-left: 3px solid #4b5563; }
  .card.tier-S { border-left-color: #f59e0b; background: linear-gradient(90deg, #1f2937, #2d1f0c); }
  .card.tier-A { border-left-color: #10b981; }
  .card.tier-B { border-left-color: #6b7280; opacity: 0.65; }
  .card.tier-C { border-left-color: #ef4444; opacity: 0.5; }
  .card.verdict-GO { border-left-color: #10b981; }
  .card.verdict-HOLD { border-left-color: #f59e0b; }
  .card.verdict-KILL { border-left-color: #ef4444; opacity: 0.5; }
  .card-t { font-weight: bold; margin-bottom: 4px; color: #f9fafb; line-height: 1.4; }
  .card-meta { font-size: 10px; color: #9ca3af; display: flex; gap: 8px; flex-wrap: wrap; }
  .tier-badge { padding: 1px 6px; border-radius: 8px; font-weight: bold; }
  .tier-badge.S { background: #f59e0b; color: #000; }
  .tier-badge.A { background: #10b981; color: #fff; }
  .tier-badge.B { background: #6b7280; color: #fff; }
  .tier-badge.C { background: #ef4444; color: #fff; }
  .shipped { background: #064e3b; border: 1px solid #10b981; border-radius: 10px; padding: 16px; }
  .shipped h2 { font-size: 16px; color: #6ee7b7; margin-bottom: 12px; }
  .shipped-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(220px, 1fr)); gap: 10px; }
  .ship { background: #022c22; padding: 10px; border-radius: 6px; border: 1px solid #047857; }
  .ship-name { font-weight: bold; font-size: 13px; color: #6ee7b7; margin-bottom: 4px; }
  .ship-meta { font-size: 10px; color: #9ca3af; }
  .empty { color: #4b5563; font-size: 11px; text-align: center; padding: 20px 0; font-style: italic; }
</style></head>
<body>
<header>
  <h1>🚀 新規事業 ∞ パイプライン</h1>
  <nav>
    <a href="/">← ダッシュボード</a>
    <a href="/org">🏢 組織図</a>
    <a href="/pipeline">🚀 新規事業</a>
  </nav>
</header>

<div class="summary" id="summary"></div>
<div class="kanban" id="kanban"></div>
<div class="shipped" id="shipped"></div>

<script>
async function load() {
  try {
    const r = await fetch('/api/pipeline');
    const d = await r.json();

    const total = d.stages.reduce((a,s) => a + s.count, 0);
    const shipped = d.shipped.length;
    document.getElementById('summary').innerHTML = \`
      <div class="stat"><div class="stat-label">進行中アイデア</div><div class="stat-value">\${total}</div></div>
      <div class="stat"><div class="stat-label">PRD完成・実装待ち</div><div class="stat-value">\${shipped}</div></div>
      <div class="stat"><div class="stat-label">廃案 (Graveyard)</div><div class="stat-value">\${d.graveyard}</div></div>
      <div class="stat"><div class="stat-label">最終更新</div><div class="stat-value" style="font-size:14px;padding-top:8px;">\${new Date().toLocaleTimeString('ja-JP')}</div></div>
    \`;

    document.getElementById('kanban').innerHTML = d.stages.map(s => \`
      <div class="col">
        <div class="col-h"><span class="col-t">\${s.label}</span><span class="col-c">\${s.count}</span></div>
        <div class="col-d">\${s.desc}</div>
        \${s.cards.length === 0 ? '<div class="empty">なし</div>' : s.cards.map(c => {
          const tierClass = c.tier ? \`tier-\${c.tier}\` : '';
          const verdictClass = c.verdict ? \`verdict-\${c.verdict}\` : '';
          const badges = [];
          if (c.tier) badges.push(\`<span class="tier-badge \${c.tier}">\${c.tier}</span>\`);
          if (c.score !== null) badges.push(\`\${c.score}pt\`);
          if (c.verdict) badges.push(c.verdict);
          const age = Math.round((Date.now() - new Date(c.mtime)) / 60000);
          const ageStr = age < 60 ? \`\${age}m前\` : age < 1440 ? \`\${Math.floor(age/60)}h前\` : \`\${Math.floor(age/1440)}d前\`;
          badges.push(ageStr);
          return \`<div class="card \${tierClass} \${verdictClass}">
            <div class="card-t">\${c.title.substring(0, 40)}</div>
            <div class="card-meta">\${badges.join(' ')}</div>
          </div>\`;
        }).join('')}
      </div>
    \`).join('');

    document.getElementById('shipped').innerHTML = \`
      <h2>🏆 実装待ち (wiki/10_projects/)</h2>
      \${d.shipped.length === 0 ? '<div class="empty">まだ無い。パイプライン回せば溜まる。</div>' :
        '<div class="shipped-grid">' + d.shipped.map(p =>
          \`<div class="ship"><div class="ship-name">\${p.slug}</div><div class="ship-meta">status: \${p.status} / \${p.shippedAt || '-'}</div></div>\`
        ).join('') + '</div>'
      }
    \`;
  } catch (e) {
    document.body.innerHTML += '<p style="color:red">Error: ' + e.message + '</p>';
  }
}
load();
setInterval(load, 15000);
</script>
</body></html>`;

// ===== HTTP Server =====
const server = http.createServer(async (req, res) => {
    if (req.url === '/' || req.url === '/index.html') {
        res.writeHead(200, { 'Content-Type': 'text/html; charset=utf-8' });
        res.end(HTML_DASHBOARD); return;
    }
    if (req.url === '/org' || req.url === '/organization') {
        res.writeHead(200, { 'Content-Type': 'text/html; charset=utf-8' });
        res.end(HTML_ORG); return;
    }
    if (req.url === '/pipeline') {
        res.writeHead(200, { 'Content-Type': 'text/html; charset=utf-8' });
        res.end(HTML_PIPELINE); return;
    }
    if (req.url === '/api/pipeline') {
        try { res.writeHead(200, { 'Content-Type': 'application/json; charset=utf-8' }); res.end(JSON.stringify(getPipelineStatus())); }
        catch (e) { res.writeHead(500); res.end(JSON.stringify({ error: e.message })); }
        return;
    }
    if (req.url === '/departments') {
        res.writeHead(200, { 'Content-Type': 'text/html; charset=utf-8' });
        res.end(HTML_DEPARTMENTS); return;
    }
    if (req.url === '/api/departments') {
        try { res.writeHead(200, { 'Content-Type': 'application/json; charset=utf-8' }); res.end(JSON.stringify(getDepartmentsStatus())); }
        catch (e) { res.writeHead(500); res.end(JSON.stringify({ error: e.message })); }
        return;
    }
    if (req.url === '/api/status') {
        try { res.writeHead(200, { 'Content-Type': 'application/json; charset=utf-8' }); res.end(JSON.stringify(await getFullStatus())); }
        catch (e) { res.writeHead(500); res.end(JSON.stringify({ error: e.message })); }
        return;
    }
    if (req.url === '/api/toggle-pause' && req.method === 'POST') {
        try {
            const wasPaused = fs.existsSync(PAUSE_FILE);
            const scriptsDir = path.join(__dirname);
            const script = wasPaused
                ? path.join(scriptsDir, 'resume_brain.ps1')
                : path.join(scriptsDir, 'pause_brain.ps1');

            try {
                execSync(
                    `powershell -NoProfile -ExecutionPolicy Bypass -File "${script}"`,
                    { timeout: 60000, windowsHide: true }
                );
            } catch (e) {
                // .ps1 がエラー終了しても続行 (個別ステップが冪等)
                console.error(`[toggle-pause] ${path.basename(script)} error:`, e.message);
            }

            // safety net: ps1 が失敗してもフラグだけは確実に切り替える
            if (wasPaused) {
                if (fs.existsSync(PAUSE_FILE)) { try { fs.unlinkSync(PAUSE_FILE); } catch (e) {} }
            } else {
                if (!fs.existsSync(PAUSE_FILE)) { try { fs.writeFileSync(PAUSE_FILE, new Date().toISOString()); } catch (e) {} }
            }

            res.writeHead(200, { 'Content-Type': 'application/json' });
            res.end(JSON.stringify({ paused: !wasPaused, fullStop: !wasPaused }));
        } catch (e) {
            res.writeHead(500); res.end(JSON.stringify({ error: e.message }));
        }
        return;
    }
    res.writeHead(404); res.end('Not Found');
});

server.listen(PORT, '127.0.0.1', () => {
    console.log(`🧠 Brain Live v3: http://localhost:${PORT}`);
    console.log(`🏢 Organization: http://localhost:${PORT}/org`);
});
