---
title: "Brain as Human Brain — 大井湧瑛 Cognitive Architecture (Definitive)"
status: draft
created: 2026-06-07
author: Claude (Opus 4.8)
type: architecture
supersedes: [2026-06-06-dream-consolidation]
tags: [architecture, cognitive-science, CLS, global-workspace, predictive-processing, consolidation]
---

# Brain as Human Brain
## A Definitive Cognitive Architecture for the 大井湧瑛 Knowledge System

*Academic in framing, implementable on the real stack: Windows 11 + Obsidian + PowerShell + Task Scheduler + Ollama (qwen3:8b, single 8GB GPU) + Claude sessions. Every theoretical construct is mapped to a file that already exists or to ≤1 PowerShell script + ≤1 scheduler that can be added without breaking the 68 live `.ps1` scripts. The migration plan is **subtractive-first**: it forgets before it builds.*

---

## 0. Thesis

The `brain/` system is already ~70% a cognitive architecture, but it was assembled organism-by-organism without a unifying theory, so the organs do not regulate one another. It has a rich **generative** subsystem (≈30 `*_filler.ps1`, dispatch waves, OpenClaw workers) and a weak **selective** subsystem. A biological brain spends most of its metabolic budget *inhibiting, selecting, and forgetting* — not generating. This system inverts that ratio. The result is the observed pathology: 430+ unpromoted inbox traces, a stub "dream" that consolidates nothing, and an 0/3 daily-action streak in which the owner is drowned by a hundred equal-weight drafts instead of being handed the one action that matters.

This document does three things:

1. Gives a rigorous **region → function → artifact** mapping grounded in five theories (Tulving, Baddeley, Complementary Learning Systems, Global Workspace, Predictive Processing) plus Damasio (salience) and Tononi–Cirelli (sleep-dependent forgetting).
2. Identifies the **three loops a brain closes that this system does not**: salience-gated attention, replay-based consolidation with pruning, and predict→act→measure-surprise.
3. Specifies a **phased, subtractive-first migration** whose minimal-viable slice touches three existing files, adds zero schedulers and zero folders, and respects the documented hardware limits and the existing self-healing "immune system" (`queue_guard.ps1`).

A design note on intellectual honesty, carried over from the feasibility red-team and treated as binding: the more speculative imports (Friston free-energy as a literal nightly job; Dehaene "ignition" with a magic-number-7 cap on a markdown file; a five-field somatic-marker struct) are **demoted to later, optional phases or cut**, because they cannot be evaluated on this stack and would re-create the over-generation disease they purport to cure. Where the architecture-analysis draft and the ground-truth artifacts disagree, **the artifacts win** and the disagreement is documented inline.

---

## 1. The Cognitive Substrate: which theory governs which organ

| Theory | Author(s) | What it governs here | Status in this design |
|---|---|---|---|
| **Memory taxonomy** (episodic / semantic / procedural) | Tulving 1972, 1985 | The folder ontology — what *kind* of memory each directory is | Adopted as-is (already correct) |
| **Working-memory model** (central executive, loops, episodic buffer) | Baddeley & Hitch 1974; Baddeley 2000 | The "conscious now": `hot.md`, `TODAY.md`, the Claude context window | Adopted; the "magic number 7" cap is treated as a *soft heuristic*, not a hard rule |
| **Complementary Learning Systems** (fast hippocampus / slow neocortex; replay) | McClelland, McNaughton & O'Reilly 1995; Kumaran, Hassabis & McClelland 2016 | The `_inbox`→`_promoted` pipeline and nightly consolidation | **Load-bearing.** This is the true isomorphism and the spine of the design |
| **Sleep & memory consolidation; SHY** | Diekelmann & Born 2010; Tononi & Cirelli 2014 | Why sleep both *strengthens* (replay) and *weakens* (synaptic downscaling / forgetting) | Adopted; forgetting is elevated to a first-class, mechanical (non-LLM) operation |
| **Global Workspace / neuronal ignition** | Baars 1988; Dehaene & Changeux 2011 | The attention gate: which traces become "conscious" (reach Claude) | Adopted as **ranking + threshold**; the neuro-theatre (ignition, θ as a Greek letter, K=7) is demoted to vocabulary, not mechanism |
| **Somatic-marker hypothesis** | Damasio 1994 | Salience tagging that biases selection | Adopted but **collapsed to a single 0–1 scalar**, not a 5-D struct (the inputs cannot support 5-D precision) |
| **Predictive processing / active inference** | Friston 2010 | Anticipating the owner instead of reacting | **Demoted to Phase 4 (optional, after the streak breaks).** Not in MVP. Flagged as currently unevaluable on this stack |
| **Metacognition / error monitoring** | Fleming & Lau 2014; Botvinick et al. 2001 (ACC conflict) | Fixing the *process*, re-weighting the lower loops | Demoted to Phase 5; depends on retrieval telemetry that does not yet exist |
| **Self-memory system / narrative identity** | Conway & Pleydell-Pearce 2000; Damasio's core/autobiographical self | The personality layer that colors all cognition | Adopted as an **always-on top-down prior** (the 大井 clone-spec) |

---

## 2. Memory Taxonomy → Folder Mapping (the ontology)

Tulving's taxonomy is the cleanest, most defensible mapping in the system and requires no change — only naming and enforcement.

| Memory type | Definition | Folder(s) | Half-life | Write path |
|---|---|---|---|---|
| **Working memory** | The capacity-limited "now"; goal + active scratchpad | `wiki/hot.md` (今ここ), `00_YUEI/TODAY.md` (the single must-do), live Claude context | Minutes–hours | Hand + session-start protocol |
| **Episodic memory** | Time-stamped, context-bound autobiographical events | `wiki/_conversations/YYYY-MM-DD/`, `wiki/daily/YYYY-MM-DD.md`, `00_YUEI/REPORT.md` | Days–weeks (until consolidated) | Stop-hook capture (automatic) |
| **Semantic memory** | De-contextualized facts, concepts, schemas, entities | `wiki/meta/`, `wiki/concepts/`, `wiki/entities/`, `wiki/10_projects/`, `09_knowledge/frameworks/` | Months–permanent | Consolidation (dream) + hand-curation |
| **Procedural memory** | Cached action sequences fired without deliberation | `wiki/skills/`, `09_knowledge/skills/`, `scripts/*.ps1`, `~/.claude/skills/` | Permanent until refactored | Code + skill authoring |

**Consolidation direction is strictly episodic → semantic.** An episode in `_conversations` becomes a fact in `concepts`/`meta` only by surviving replay. Procedural memory is written separately (by authoring code/skills), exactly as motor learning is encoded by a different pathway than declarative learning.

### The hippocampus / neocortex split (the spine)

CLS predicts two learning systems with opposite properties, and the system already instantiates both:

| Property | Hippocampus (fast) | Neocortex (slow) |
|---|---|---|
| Learning rate | One-shot, immediate | Slow, interleaved |
| Representation | Sparse, pattern-separated (kept apart to avoid interference) | Overlapping, structured (schemas) |
| Artifact | `queue/inbox`, `wiki/_inbox/{dept}/`, `.raw/`, `00_YUEI/NOTES.md`, `00_YUEI/INBOX.md` | `wiki/_promoted/`, `meta/`, `concepts/`, `entities/`, `10_projects/` |
| Current state | **Overloaded** (430+ unpromoted; 291 archived) | **Underfed** (≈4 promotions/week) |

The disease is a CLS imbalance: rapid encoding with almost no transfer to neocortex, and no decay of the hippocampal store. In a biological hippocampus, un-replayed traces fade within days; here they accumulate forever. **The cure is more replay and active forgetting, not more encoding.**

---

## 3. Region → Function → Artifact (the core table)

Ground-truth corrections from the artifacts are marked **[FACT]**.

| Brain region | Theory | Function | Artifact (existing → target) | Trigger |
|---|---|---|---|---|
| Prefrontal — central executive | Baddeley | Hold goal, allocate attention, inhibit | `00_YUEI/TODAY.md` (1 must-do) + `hot.md` 今ここ | Session start; `task_board.ps1` |
| Phonological loop / sketchpad | Baddeley | Capacity-limited scratchpad | `hot.md` (soft cap) + Claude context window | hot.md maintenance rule |
| Episodic buffer | Baddeley | Bind today's multimodal episode | `daily/YYYY-MM-DD.md`, `_conversations/` | Stop hook (exists) |
| Hippocampus | CLS | One-shot sparse encoding of the new | `queue/inbox`, `wiki/_inbox/{dept}`, `.raw/`, `00_YUEI/NOTES.md` | `harvest.ps1` (hourly) |
| Entorhinal gateway | CLS | Route + index + **gate** into hippocampus | **`harvest.ps1` itself** — add scoring/dedup at copy time. **[FACT]** harvest currently does an *ungated* `Copy-Item` of every `results/{dept}/*.md` → this is the real flood source, not "no gate elsewhere" | on-harvest |
| Neocortex | CLS | Stable generalized knowledge / schemas | `wiki/_promoted/`, `meta/`, `concepts/`, `entities/`, `10_projects/` | `auto_promote.ps1` (exists) |
| Sleep / SWS replay | Diekelmann–Born; CLS | Replay → dedup → schema → promote → prune | `dream_consolidation.ps1` (**[FACT]** stub: counts files, leaves a literal `(朝の Claude が追記)` human placeholder; consolidation is NOT automated) → upgrade | `BrainDreamConsolidation` 23:00 |
| Synaptic downscaling / forgetting | Tononi–Cirelli SHY | Net nightly weakening; only replayed traces survive | **Prune block inside `dream_consolidation.ps1`** (mechanical, no LLM) | nightly, after replay |
| Thalamus / Global Workspace | Baars; Dehaene | Select the coalition that reaches consciousness | **`today_priorities.json` + `TODAY.md`** are *already* the conscious set. **[FACT]** `priority_filler.ps1` is already a partial Global Workspace (reads `today_priorities.json`, 48h staleness gate, splits `human_only`→`TODAY.md`, dedup guard) | every session start |
| Attention threshold | Dehaene ignition | What "wins" the workspace | salience scalar ≥ cutoff in harvest gate (cutoff is a *tunable number*, not a fixed Greek constant) | on-harvest |
| Amygdala / somatic marker | Damasio | Affective value tag biasing selection | **Single `salience: 0–1`** frontmatter field (collapsed from the rejected 5-field struct) + existing `priority:` + age | `harvest.ps1` writes; decays nightly |
| Basal ganglia / procedural | — | Cached habits fired without deliberation | `skills/`, `scripts/*.ps1` | on trigger |
| Default Mode Network | Raichle | Off-task recombination → insight | `brain_excavation.ps1` (resurfaces unused notes) + dream's schema pass | `BrainExcavation` Sun 21:00 |
| Self-model / narrative identity | Conway; Damasio | Personality that colors all cognition | `meta/ooi-clone-spec.md` (**[FACT]** file is `ooi-clone-spec.md`, *not* `-v4`), `ooi-soul.md`, `ooi-deep-synthesis-2026-05-20.md`, `mission-vision-values-v1.md` | always-on prior at session start |
| Immune system (NEW name for existing) | — | Quarantine, self-heal, prevent contention | **[FACT]** `queue_guard.ps1` (10-min): mojibake auto-quarantine, `.paused` orphan self-heal, 3-strike poison-pill reaper, stale-lock graveyard, stray-worker GPU-contention killer, 25-min silent-stall detector, Ollama auto-restart, done-archival, log rotation | every 10 min |
| Cerebellum / forward model | Friston | Predict next state, compute error | **Phase 4, optional.** Demoted: no labeled data, no eval; an LLM grading its own guess is not measurable on this stack | — |
| PFC metacognition / ACC | Fleming; Botvinick | Self-monitor, re-weight lower loops | `self_review.ps1` (weekly) + `ceo-orchestrator`; **Phase 5, optional** — requires retrieval telemetry that does not yet exist (`operations.jsonl` logs edits, not reads) | weekly |
| Subcortical drives (pathological) | — | Background generation | ≈30 `*_filler.ps1` + waves → **subtract ~most, gate the survivors** | various crons |

---

## 4. Complementary Learning Systems: the upgraded "Dream" (consolidation)

This is the heart of the redesign. CLS holds that intelligence emerges from *interleaved replay*: the hippocampus repeatedly reactivates recent sparse traces, the neocortex slowly weaves them into existing schemas, near-duplicates collapse, and un-reactivated traces decay. The current `dream_consolidation.ps1` performs **none** of this — it counts files and writes a human placeholder. We replace it with a five-stage nightly pipeline, but the pipeline is engineered around two hard constraints from the artifacts:

- **GPU reality [FACT]:** one 8GB GPU, standardized on `qwen3:8b` (qwen3.6 was removed; CLAUDE.md's lingering "qwen3.6" references are stale and were copied into the prior draft in error). `queue_guard.ps1` actively kills stray workers to avoid VRAM contention. Therefore the dream uses **exactly one OpenClaw call per night**, not a per-cluster fan-out.
- **Flood history [FACT]:** `BrainAutoReview` was disabled after a 1500-file pile-up; `queue_guard` comments record "1215件膨張 / 1500件一気投入." Therefore consolidation must be **net-reducing** — every night the inbox must end smaller than it started.

### The five stages (one nightly job, GPU-safe)

```
23:00  BrainDreamConsolidation  →  dream_consolidation.ps1 (rewritten)

  Stage 1 — REPLAY (PowerShell, no LLM)
    Gather today's _inbox traces, sorted by salience (frontmatter scalar) desc.
    Take top-N (N small, e.g. 15–25) as the "replay set". Everything below is
    a candidate for forgetting in Stage 5.

  Stage 2 — DEDUP (PowerShell, no LLM)
    Cluster the replay set by `schema_tag` + cheap similarity (filename/title
    overlap; reuse embed_wiki.ps1 ONLY if embeddings are confirmed current —
    otherwise keyword Jaccard). Mark near-duplicates; keep the highest-salience
    representative per cluster.

  Stage 3 — SCHEMA EXTRACTION + SYNTHESIS (ONE OpenClaw call, qwen3:8b)
    Feed ONLY the deduped representatives (a handful, not hundreds).
    Single prompt → structured output:
      - 3 findings (new schema/pattern worth keeping)
      - 3 failure patterns (what to stop doing)
      - tomorrow's Top 5 (seeds next salience priors)
    This is the DMN/insight + generalization step, bounded to one job.

  Stage 4 — PROMOTE (PowerShell, no LLM)
    Move deduped, high-salience representatives → wiki/_promoted/ and the
    matching neocortex folder; hand verdicts to existing auto_promote.ps1.
    Extracted schemas → 09_knowledge/learnings/ or concepts/.

  Stage 5 — PRUNE / SHY DOWNSCALING (PowerShell, no LLM)
    The replay set's losers + everything below threshold that is also
    un-retrieved and aged → _archive (then delete after 60d untouched).
    NET RULE: |_inbox after| < |_inbox before|. Mirror queue_guard's overflow
    pattern so the two do not fight.

  Output: overwrite the human placeholder with the Stage-3 synthesis →
    00_YUEI/TOMORROW.md + seed scripts/today_priorities.json for tomorrow.
```

Two CLS principles made concrete: **(a) only replayed traces survive** (Stage 1 selects, Stage 5 forgets the rest); **(b) generalization happens during replay** (Stage 3 extracts schemas the waking system never had time to abstract).

---

## 5. Global Workspace: the attention / salience selector

Baars' Global Workspace and Dehaene's "ignition" describe a competition in which one coalition of content is broadcast system-wide and becomes "conscious." Here, "consciousness" = **what reaches a Claude session**. The crucial artifact-grounded correction: **the system already has a Global Workspace** — `today_priorities.json` is the single command source, and `priority_filler.ps1` already gates against it with a staleness check and a `human_only` split whose own comment states its purpose is to stop "機械がドラフト量産で『仕事した感』を出して人間のボトルネックを誤魔化す."

Therefore we do **not** build a parallel `salience.ps1` + `_workspace/NOW.md`. We close the one open seam: the **encode side** (`harvest.ps1`) does not honor the salience source. The fix:

- **Salience = one scalar (Damasio, collapsed).** At harvest time, stamp each file with `salience: 0–1`, derived from: keyword/`schema_tag` overlap with `today_priorities.json` + `TODAY.md` (goal-fit), recency, and the existing `priority:` tag. No five-field struct — the inputs cannot justify per-field precision.
- **Threshold as a tunable number, not theatre.** Below-cutoff files go to `_inbox/_low/`, which Claude does not review by default. The cutoff starts deliberately high and is tuned by watching one week of inbox volume. (Dehaene's "ignition threshold" is honored as *vocabulary*; the mechanism is a sortable number.)
- **The "magic number 7" is a soft heuristic.** A markdown file has no working-memory capacity limit; capping the conscious set to ~7 is about *human* attention (the owner's), and is enforced where it already lives — `TODAY.md`'s single must-do and `priority_filler.ps1`'s `human_only` lane — not by a new K-of-N cap on the inbox.

Net: the Global Workspace becomes a **closed loop** — `priority_filler.ps1` writes the conscious set; `harvest.ps1` now *reads* it to gate encoding; the dream re-seeds it nightly.

---

## 6. Predictive Processing & Proactivity (Phase 4 — demoted, optional)

Friston's active inference says an intelligent agent predicts its world and acts to minimize surprise. Applied here it would mean: predict tomorrow's owner needs + market signals, pre-draft the likely deliverable, then score yesterday's prediction against reality.

This is the **most attractive and least buildable** layer, and it is deliberately deferred:

- There is no labeled data, no model, and no evaluation harness. A `predict.ps1` would be an LLM guessing tomorrow; a "surprise score" would be an LLM grading its own guess. That is not measurable on this stack.
- The honest proactive behavior the system *can* do today already exists: Claude hand-writes 先回り提案 in `hot.md` each session, and the dream's Stage-3 "tomorrow's Top 5" seeds priors. That is a defensible, evaluable proxy for prediction.

**Decision:** keep predictive processing as the *aspiration* that the dream's Stage-3 synthesis approximates. Build a real `predict.ps1` only after Phases 1–3 break the 0/3 streak, and only once retrieval telemetry (Section 7) exists to measure surprise. Until then, claiming an active-inference loop would be astrology with a citation.

---

## 7. Metacognition & the Executive (CEO) — Phase 5, optional

Fleming's metacognition and Botvinick's ACC conflict-monitoring describe a system that watches itself, detects error, and **re-weights the lower loops**. The executive here is `ceo-orchestrator` + `self_review.ps1` (weekly).

The principled version — "did promoted notes get retrieved? if not, the salience weights were wrong, so re-tune them" — requires **retrieval telemetry that does not exist**: `operations.jsonl` logs *edits*, not *reads*. So Phase 5 has a prerequisite:

- **Prerequisite (cheap, additive):** start logging retrieval — when a `_promoted`/`concepts` note is opened or wikilink-followed in a session, append to a `retrieval.jsonl`. This is the missing sensor for the whole metacognitive loop.
- **Then** `metacog.ps1` (weekly) can compute one honest signal: *promotion precision* = fraction of promoted notes retrieved within K days. Low precision → lower the salience cutoff's goal-fit weight; high precision with low recall → raise it. This is the *only* loop permitted to rewrite the weights of harvest's gate and the dream's selection — exactly the PFC's job.
- **The 0/3 streak is a first-class error signal.** Eleven days of unactioned plans means the *plans* are mis-salienced, not that the owner is failing. Metacog should respond by surfacing the single highest-leverage action (which `TODAY.md` already attempts) and down-weighting low-effort-fit busywork.

---

## 8. The Identity Layer: how the 大井 clone-spec colors all cognition

Conway's self-memory system and Damasio's autobiographical self hold that the self-model is not one module among many — it is a **standing prior** that biases perception, memory, and action everywhere. In this system the self-model is rich (`ooi-clone-spec.md`, `ooi-soul.md`, `ooi-deep-synthesis`, `ooi-life-story.md`, `mission-vision-values-v1.md`) but **passive**: it is read only when Claude happens to remember to. That is the architectural error — the personality should *color* cognition, not be an optional lookup.

Two enforcement points (both cheap, both in MVP-adjacent phases):

1. **At the gate (salience `value`).** The clone-spec's value ordering — money > brand > busywork; ship over polish; concrete over abstract; one decisive action over many drafts — becomes the *prior* on the goal-fit term in `harvest.ps1`'s salience scalar. A draft that merely looks productive scores low because the self-model says so.
2. **At every reply.** A compact, always-prepended digest — `meta/ooi-identity-core.md` (≈200 lines, distilled from the clone-spec) — is loaded at session start so the personality colors generation, not just retrieval. This is the cheapest high-leverage change after forgetting: it makes the system *sound like and prioritize like* the owner by default.

The identity layer is therefore not a phase of its own — it is the **prior threaded through Phases 1, 2, and 5**: it weights the gate, seeds the dream's "what matters," and is the reference the metacognitive loop tunes toward.

---

## 9. The Three Unclosed Loops (why the system is retentive, not intelligent)

A brain is intelligent, not merely retentive, because it closes three loops this system currently leaves open:

1. **Encode → gate → ignite.** Today `harvest.ps1` floods all traces in with equal status. **Close it:** gate at harvest against `today_priorities.json` (Phase 1).
2. **Replay → consolidate → forget.** Today the dream consolidates nothing and nothing is ever forgotten. **Close it:** the five-stage net-reducing dream (Phases 2–3).
3. **Predict → act → measure surprise → re-weight.** Today the system generates but never scores itself against reality. **Close it later:** retrieval telemetry → metacog (Phase 5), real prediction (Phase 4) only once measurable.

Close loops 1 and 2 and the 0/3 streak should break, because for the first time the system surfaces *one* salient action instead of a hundred equal ones.

---

## 10. Phased Migration Plan (subtractive-first, additive-safe)

**Binding principles for every phase:** (a) **forget before you build** — pruning the backlog removes half the disease with `Remove-Item`, no architecture required; (b) **subtract generators before adding processors** — a faithful reading of the thesis *deletes* fillers, it does not wrap them; (c) **edit existing files over adding new ones** — fewer new failure surfaces (locks, BOM/mojibake, GPU contention); (d) every new MD writer must replicate the existing `UTF8Encoding($false)` BOM-less pattern or it regresses mojibake; (e) do not fight `queue_guard.ps1` — extend its patterns, never duplicate them.

### Phase 0 — Forget (one-time debt clearance). ~1 hour. **Do this first.**
- One-time mechanical prune over the existing `_inbox` backlog (430 unpromoted + 291 archived + promote-candidates): `priority: low`/none **AND** no inbound wikilink **AND** age > 14d → `_archive`; archived + untouched 60d → delete.
- **No LLM, no scheduler, no new folder.** This alone clears most of the diagnosed hoarding on day one and makes every later phase cheaper.

### Phase 1 — The Gate at the real flood point. ~3 hours. (Highest ROI build.)
- Edit **`harvest.ps1`** (not a new `encode.ps1`): before `Copy-Item`, (a) skip near-duplicates vs the previous file in the same dept (keyword overlap); (b) read `today_priorities.json` `schema_tag`s and stamp each file with `salience: 0–1`; (c) below-cutoff files → `_inbox/_low/` (not the main inbox Claude reviews).
- Cutoff starts high; tune over one week. **Zero new schedulers** (folds into `BrainHarvest`). **Identity prior:** the goal-fit term is weighted by the clone-spec's value ordering (Section 8).

### Phase 2 + 3 — Real Dream (consolidate + forget nightly). ~4 hours.
- Rewrite **`dream_consolidation.ps1`** into the five-stage pipeline of Section 4: REPLAY + DEDUP + PROMOTE + PRUNE in PowerShell; **exactly one** `qwen3:8b` OpenClaw call for Stage-3 synthesis. Net rule enforced: inbox ends smaller than it started.
- Replace the human placeholder with the Stage-3 output → `00_YUEI/TOMORROW.md` + seed `today_priorities.json`.
- **Reuses** `BrainDreamConsolidation` (23:00) and the existing BOM-less UTF8 writer. **Zero new schedulers.** Prune lives *inside* the dream so it cannot race `queue_guard`.

### Phase 3.5 — Subtract the mania. ~2 hours.
- Audit the ≈30 `*_filler.ps1`. **Disable (not gate) the majority** — keep only the few whose output the owner actually consumes. This is the literal application of "a brain inhibits more than it generates," and it removes failure surfaces instead of adding a budget-broker mechanism.
- Survivors must request nothing new; they simply run less. (A formal `energy_budget.ps1` broker is explicitly *rejected* for now — rewriting 30 dispatch contracts is exactly the cross-cutting change that breaks live schedulers.)

### Phase 4 — Identity-as-prior, everywhere. ~2 hours.
- Distill `meta/ooi-clone-spec.md` → `meta/ooi-identity-core.md` (≈200 lines). Prepend at session start; reference its value ordering in the harvest gate. Now the personality colors both selection and generation.

### Phase 5 — Retrieval telemetry (the missing sensor). ~2 hours.
- Begin logging reads/wikilink-follows of `_promoted`/`concepts` notes → `retrieval.jsonl`. No behavior change yet — just instrument. This is the prerequisite for any honest metacognition or surprise measurement.

### Phase 6 — Metacognition (only after telemetry exists). ~half day. **Optional.**
- `metacog.ps1` (weekly, via `ceo-orchestrator`): compute promotion precision from `retrieval.jsonl`; re-tune the harvest salience cutoff and the dream's selection N. The only loop allowed to rewrite lower-loop weights.

### Phase 7 — Predictive processing (last, gated on measurability). **Optional, may stay unbuilt.**
- Only after Phases 1–6: build `predict.ps1` + morning reconcile *iff* `retrieval.jsonl` + outcome data make "surprise" measurable. Until then, the dream's "tomorrow's Top 5" is the sanctioned proxy.

### What is explicitly cut or merged (vs. the original 6-script plan)
- **Cut for now:** standalone `encode.ps1` (folded into harvest), `salience.ps1` + `_workspace/NOW.md` (the workspace already exists as `today_priorities.json`/`TODAY.md`), `energy_budget.ps1` (disable fillers instead), `predict.ps1` (unmeasurable), the 5-field salience struct (→ 1 scalar), four new schedulers (→ zero new for MVP).
- **Net new schedulers through Phase 5: zero.** Net new folders through Phase 5: one (`_inbox/_low/`).

---

## 11. Target Deltas (summary)

| Kind | Change |
|---|---|
| **Edit** | `harvest.ps1` (gate + salience stamp + dedup), `dream_consolidation.ps1` (5-stage net-reducing rewrite) |
| **One-time** | Mechanical backlog prune (Phase 0) |
| **Disable** | Majority of `*_filler.ps1` (Phase 3.5) |
| **New file (small)** | `meta/ooi-identity-core.md` (digest), `retrieval.jsonl` (telemetry) |
| **New folder** | `_inbox/_low/` (sub-threshold quarantine) — the only one in MVP |
| **New scheduler** | **None** through Phase 5 |
| **Reuse unchanged** | `priority_filler.ps1` (already the Global Workspace), `queue_guard.ps1` (the immune system), `auto_promote.ps1`, `BrainHarvest`, `BrainDreamConsolidation`, `BrainExcavation`, `BrainSelfReview` |
| **Behavior** | Claude reads the gated inbox + identity-core digest at session start; consolidation is genuinely automated; the system forgets nightly |

---

## 12. One-Paragraph Conclusion

The system already has Tulving's memory taxonomy, Baddeley's working memory, and the CLS hippocampus→neocortex pipeline. What it lacks are the three things that make a brain *intelligent* rather than merely *retentive*: an **attention gate** at the true flood point (`harvest.ps1`, honoring the Global Workspace that already exists in `today_priorities.json`), **real sleep** (a net-reducing replay-dedup-promote-prune dream, one GPU-safe LLM call), and **forgetting** (SHY downscaling, mechanical, first). The honest move is subtractive: forget the 430-file debt, disable most generators, gate the one real intake, and automate the one true gap — consolidation. The speculative imports (Friston, Dehaene's ignition theatre, a 5-D somatic struct) are demoted until the stack can measure them. Build Phase 0 through Phase 3 and the 0/3 streak should break — because for the first time the system will hand the owner *one* salient action instead of drowning him in a hundred equal drafts.

---

### Provenance
- **Verified against artifacts (this session):** `wiki/` and `wiki/_inbox/` structure, `wiki/meta/` (confirmed `ooi-clone-spec.md`, not `-v4`), `00_YUEI/` (TODAY/TOMORROW/NOTES/INBOX/REPORT present), `queue/` (processing/done/failed/_lock_graveyard/_corrupted_tasks present), `scripts/` (68 `.ps1`; `harvest.ps1`, `dream_consolidation.ps1`, `priority_filler.ps1`, `queue_guard.ps1`, `auto_promote.ps1`, `embed_wiki.ps1`, `search_wiki.ps1` all present), `scripts/today_priorities.json` (confirmed as the single salience source with `human_only`/`openclaw_draft`/`claude_research` lanes).
- **Inputs:** architecture analysis (region→artifact mapping, gap ranking, original 6-phase plan) + feasibility red-team (artifact-grounded corrections, GPU/immune-system constraints, subtractive MVP).
- **Key reconciliations where artifacts overrode the analysis:** (1) an attention gate already exists (`priority_filler.ps1`) — the missing piece is the *encode-side* gate in `harvest.ps1`; (2) the flood source is harvest's ungated `Copy-Item`, not a global absence of gating; (3) `qwen3:8b` single-GPU forces one nightly LLM call, not per-cluster fan-out; (4) a self-healing immune system (`queue_guard.ps1`) already exists and must be extended, not duplicated; (5) Friston/Dehaene/5-field-salience demoted as currently unevaluable.
