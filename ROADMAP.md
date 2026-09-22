# Harness.AgentAdapter Roadmap

**Vision:** The Harness.AgentAdapter behaviour plus six adapters for headless coding-agent CLIs (Claude Code, Cursor, Codex, Grok, Antigravity, Pi), all driven over uniform OTP Ports with no per-agent SDK and no output normalization. Extracted from the harness orchestration engine so any BEAM consumer can spawn and drive a headless coding agent without depending on harness's dispatch, review, or landing machinery.

**Task tracking:** This file is rendered by `rmap` from `roadmap/tasks.toml`. Don't hand-edit the task tables inside `<!-- TASKS:BEGIN -->` / `<!-- TASKS:END -->` marker pairs — they're regenerated on every `rmap render`. Edit `roadmap/tasks.toml` or use `rmap status` / `rmap mark` / `rmap new`, then `rmap render`. Prose outside the marker pairs is byte-preserved.

**Completed work:** See [CHANGELOG.md](CHANGELOG.md).

## Current Focus

<!-- FOCUS:BEGIN -->
**Focus phase:** 1 — Extraction (2 of 2 done · 0 in progress)

**Last shipped:** Task 3 — Repair process-fixture port-close race and refresh generated agent instructions found by integrated QA on 2026-09-22

**Up next:** none — focus phase complete or all blocked
<!-- FOCUS:END -->

---

## Phase 1: Extraction

> Standalone package extracted from harness, with the QA gates a dispatch target needs.

<!-- TASKS:BEGIN phase=1 -->
| Task | Status | Notes |
|------|--------|-------|
| Task 2 | ✅ | 🎁 **qa-gates** · 🐛 Run AGENTS.md freshness check from an installed marketplace copy when the operator checkout is absent [D:2/B:3/U:2 → Eff:1.25] 📋 |
| Task 3 | ✅ | 🎁 **qa-gates** · 🐛 Repair process-fixture port-close race and refresh generated agent instructions found by integrated QA [D:1/B:2/U:2 → Eff:2.0] 🎯 |
<!-- TASKS:END -->
