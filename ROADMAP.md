# Harness.AgentAdapter Roadmap

**Vision:** The Harness.AgentAdapter behaviour plus six adapters for headless coding-agent CLIs (Claude Code, Cursor, Codex, Grok, Antigravity, Pi), all driven over uniform OTP Ports with no per-agent SDK and no output normalization. Extracted from the harness orchestration engine so any BEAM consumer can spawn and drive a headless coding agent without depending on harness's dispatch, review, or landing machinery.

**Task tracking:** This file is rendered by `rmap` from `roadmap/tasks.toml`. Don't hand-edit the task tables inside `<!-- TASKS:BEGIN -->` / `<!-- TASKS:END -->` marker pairs — they're regenerated on every `rmap render`. Edit `roadmap/tasks.toml` or use `rmap status` / `rmap mark` / `rmap new`, then `rmap render`. Prose outside the marker pairs is byte-preserved.

**Completed work:** See [CHANGELOG.md](CHANGELOG.md).

## Current Focus

<!-- FOCUS:BEGIN -->
**Focus phase:** 1 — Extraction (0 of 1 done · 0 in progress)

**Last shipped:** no recent shipments

**Up next:** Task 2 — Run AGENTS.md freshness check from an installed marketplace copy when the operator checkout is absent [D:2/B:3/U:2 → Eff:1.25] 📋
<!-- FOCUS:END -->

---

## Phase 1: Extraction

> Standalone package extracted from harness, with the QA gates a dispatch target needs.

<!-- TASKS:BEGIN phase=1 -->
| Task | Status | Notes |
|------|--------|-------|
| Task 2 | ⬜ | 🎁 **qa-gates** · 🐛 Run AGENTS.md freshness check from an installed marketplace copy when the operator checkout is absent [D:2/B:3/U:2 → Eff:1.25] 📋 |
<!-- TASKS:END -->
