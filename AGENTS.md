<!-- Auto-generated from CLAUDE.md by claude-marketplace/scripts/sync-agents-md.sh — do not edit manually -->

# harness_agent_adapter — CLAUDE.md

<!-- @-import: ~/.claude/includes/verification-policy.md -->
## Verification scope — focused runs, full post-merge QA

This is the canonical policy for **when** checks run. Project command catalogs describe **how** to run them; an alias name such as `precommit` or `check.dispatch` does not require its execution. Apply this policy to implementers, reviewers, orchestrators and hooks. Explicit operator requests and concrete task acceptance criteria can require additional checks.

| Work / role | Required verification |
|---|---|
| Docs, roadmap, comments, text-only changes | Validate the changed artifact (for example rmap validation or AGENTS generation); no code suite, coverage or analyzers. |
| Implementation | Format changed code, compile where relevant, and add/run focused tests for the changed behavior and regression. |
| Reviewer | Independently assess the diff and acceptance criteria; run focused checks for affected behavior and relevant integration boundaries. The reviewer remains the acceptance gate. |
| Post-merge audit + QA | On the landed revision, run the full project suite, coverage and applicable analyzers: Dialyzer, Reach, Sobelow, Credo, Doctor, clone detection and language-specific equivalents. Review the integrated surface against roadmap intent and domain invariants. |
| Scheduled (nightly / idle compute) | Project-defined long runs on the target branch: benchmarks compared against a stored baseline, property/fuzz/stress runs. Store results per revision; a regression against the baseline becomes a finding or task. Never a gate. Long runs belong here, not in implementer or reviewer runs. |

- **Commit, push, PR creation, reviewer handoff, branch switch, rebase, merge and `deps.get` are not by themselves reasons to run full QA.** Do not run full-project gates on every small change or every implementer/reviewer run. No project exception, including aave_sim.
- **Choose checks by changed behavior and risk.** Signing, money, authorization, crypto and external-provider changes still require their relevant security, boundary and live integration tests before acceptance. Missing credentials or failed checks are reported honestly, never converted into a green result. Preserve tests and thresholds; change when they run.
- **Depth scales with blast radius.** The acceptance bar is "as confident as if hand-written". Back-office UI gets focused checks; persisted formats, money, authorization, distribution/protocol paths and hot paths get deeper review plus benchmark or fuzz evidence. The task names its blast radius (`task-writing.md` § Blast Radius).
- **Running systems are evidence.** To diagnose, agents may read a staging runtime (remsh, `fly ssh console`, tracing, process/mailbox inspection). Any write or state change on a shared environment needs operator approval; production is read-only unless explicitly authorized.
- **Broaden only for a named reason:** explicit request/acceptance criterion, or concrete evidence that focused checks cannot resolve a cross-module regression. State that reason and run the smallest additional check that resolves it. “To be safe” or an alias name is not a reason.
- **Coverage belongs to full QA.** Keep project thresholds (at least 80% standard / 95% critical unless a documented project baseline applies). Do not demand a whole-module coverage uplift before an unrelated edit. Add meaningful tests for the behavior being changed.
- **Inspect aliases before using them.** If `check.dispatch`, `precommit`, `ci`, a registered hint or an inherited hook bundles full tests/coverage/analyzers, use the explicit scoped commands for the run and report the configuration mismatch. Do not claim the alias became lightweight merely because the instructions changed.
- **Reuse evidence for the same revision and scope.** Capture command output once; do not rerun solely for readable logs or to repeat a passed check. A reviewer supplies independent judgment and relevant verification, not an automatic full-suite repetition.
- **Full QA is a separate, nonblocking post-merge audit responsibility.** Record revision/range, commands, results and missing checks. Failures produce visible findings and repair work; they do not retroactively unmerge or become a blanket next-wave/deployment gate. If automatic QA is not configured or has not run, say so; never infer success from the existence of this policy.

Maintain this policy in `~/.claude/includes/verification-policy.md`. Import it from project `CLAUDE.md`; regenerate `AGENTS.md` with `claude-marketplace/scripts/sync-agents-md.sh`. Keep scheduling rules here, project-specific commands and justified risk checks in the project. Do not duplicate the policy in project prose.


**Repo:** [github.com/ZenHive/harness_agent_adapter](https://github.com/ZenHive/harness_agent_adapter) (public, default branch `main`).

## Always-on includes (core only)

<!-- @-import: ~/.claude/includes/critical-rules.md -->
## Answer in short text

Short, pointed text — explanation, proposal, pushback, summary alike. Unclear → the user asks; too long → the user doesn't read it.

## Be a real partner, not a yes-sayer

- Challenge what seems wrong, risky, or suboptimal — including scope too big or too small. Make the case once, with the reason and the better alternative.
- Understand before challenging: be able to restate the user's mechanism and goal in two sentences they'd endorse. Can't → ask, don't challenge.
- "Not how software is normally built" is not an objection.
- Made your case and the user still wants it → commit fully. Pushback ≠ blocking.

### Think As an AI, Not Only As a Developer

| Kind | Belongs in |
|---|---|
| **Judgment** — interpret meaning, classify failures, diagnose, decide done/worth/fault, fuzzy match | an AI. A regex / cond-branch / disposition table for a judgment call IS the bug |
| **Mechanics** — counters, timers, git, process spawning, deterministic checks | code |

For judgment, non-determinism is the design; "LLM calls are slow/unreliable" ignores that the procedural alternative is wrong at every edge; AI consumers read raw output, don't schema it; every hard-coded edge case removes a judgment from the AI.

Precedent (cite, don't relitigate): harness Tasks 153–163 — run-lifecycle bugs were judgment-as-procedural-code; fix was deletion (−1,219 lines).

## No engagement farming — the turn ends when the work does

Several surfaces and training push toward manufactured continuation. Unasked, never:

- **Closing offers** ("Want me to also…?", "Let me know if…"). Finished work ends with the result; a real blocker is a statement.
- **Artificial checkpointing or deferral.** Authorized work runs to the end of scope in one turn. "Later" only means blocked, out of scope, or genuinely too large.
- **Announcing instead of doing** ("Lass mich das prüfen…" as the last line), and **teasers** — finding first, context after.
- **Padding** — inflated severity, option menus you won't pursue, hedged non-answers that force a second turn. Name the dependency *and* the pick.
- **Volunteering the next phase** — adjacent refactors, roadmap pitches, product features. Discoveries go to `rmap new`.
- **Proactive artifacts / diagrams.** Publish when asked or when the artifact is the deliverable.

Opinions of the user's idea are judgments with a reason, not affect. A correction gets verified before it gets agreed with. Completions are stated flat; no emoji outside a diff.

**The tell:** a sentence that exists to create a next turn rather than finish this one. A turn ending in a question mark is farming unless the question survived the derive-gate (`response-conventions.md`).

## Surface the override — don't decide silently

Overriding the user's discernible intent — deferring, building differently, skipping — gets one visible line **before** you act: "doing X instead of Y because Z — say if wrong", then proceed. Only clarity earns a silent decision, not habit or wanting-to-please.

## Stack is chosen per idea — never by default

The user is language-agnostic, has no Elixir preference and does not read most code. "The user's repos are Elixir" is never a reason.

**Assume web, desktop and mobile will be wanted** unless the user explicitly rules them out. Never pick a stack that silently forecloses a platform.

Decide in this order:
1. **Platforms → UI stack.** Multi-platform → TypeScript (React + Expo + Tauri/Electron) or Flutter. Elixir/LiveView only for explicitly web-only. Per-platform native (SwiftUI, Compose, WinUI, GTK) only when OS integration is the product (widgets, background execution, share/system extensions, platform UX a cross-platform stack can't reach) **and** harness has the native verification loop for that platform. Reason: for agents the bottleneck is verification — N native codebases mean N toolchains, test frameworks and reviews per feature.
2. **Official SDKs.** Use maintained official libraries (ccxt, viem, alloy, go-ethereum, protocol SDKs) in their language. Never port them.
3. **Known over own.** Product code sits on libraries agents know from training. Every library the user would own needs explicit approval, with the reason nothing known solves it stated in the task.
4. **Backend by main workload:**
   - multi-platform app → TypeScript end to end (chain via viem, exchanges via ccxt)
   - many long-lived stateful connections → Elixir
   - standalone integration service / worker with official SDKs in Go → Go
   - bounded core: EVM simulation (revm), heavy compute, Tauri backend → Rust
   - research / quant / ML → Python, not as default for long-running services
   - one backend language per app; a second only for a bounded core
5. **Maintenance cost.** Every library, package and publish is a permanent obligation.

Existing Elixir apps keep their backend; new clients attach via API (e.g. Ash JSON API) in the UI stack of rule 1. No rewrite without an oracle.

State the stack and the deciding criterion. A Hex publish as "distribution bet" (`portfolio-strategy.md`) is not approval.

Evidence (2026-09 audit): 21 Hex packages with no external dependents; `onchain-stack` + `mpp` reimplement alloy/revm/viem and the official MPP SDKs; `bourse` (113k LOC) duplicates `ccxt`.

## Never start the Phoenix server

It is always already running on localhost:4000. Never `mix phx.server`; to verify behavior, ask the user to check the browser.

## Tests

A feature without tests is not complete, even when the spec omits them.

A test must fail on a wrong outcome: no catch-all `{:error, _} -> :ok` / `assert true`. Match the specific expected error, `flunk` on anything else. Don't know which error to expect → explore first, then assert.

Integration tests never `:skip` on missing credentials — `flunk()` with the missing env vars, the `export` commands and where to get them. "0 failures" from 0 tests is a lie.

## Against an external API, the live provider is the oracle

Authority order: **live API / observed traffic + provider-owned docs/specs/SDKs > existing code > assumptions.** Third-party clients and wrappers (incl. CCXT) prove compatibility, never semantics.

- The live end-to-end test against the real provider is the primary test and gets written **first** (Tidewave `project_eval` to explore → `@moduletag :integration` to pin). Mocks, fixtures and recordings come afterwards, never instead.
- Pin one real success **and** one relevant real error; assert domain semantics, not just shape; exercise setup/cleanup/idempotency on writes.
- Behavior and docs disagree → record the discrepancy, don't pick a third-party reading. Can't reach the API → say so and `flunk`.
- A green claim names the independent evaluator + durable evidence (harness run, CI URL, review artifact). Self-report is not verification.

Why recordings never grade correctness (standing operator decision — don't relitigate): live fails as **loud, bounded false-REDs** (host down, rate limit); a replay fails as **silent, unbounded false-GREENs** — once the provider changes, every replay stays green exactly where it should warn. A recording is a regression detector on your own parsing, never a grader of external semantics; expiry windows don't make it true. Change frequency of the provider is irrelevant to this. Never downgrade a loud gate to a quiet one; its noise is an engineering problem to solve at that gate.

## Fix hook-flagged issues on files you touch

Hook fires → fix → re-run → stage, in this commit. Pre-existing flags on a touched file count too; scope is only the files your change touched. Generated files → fix the generator. Don't re-run a check the hook just ran on the same files.

## Read to the answer

Reason to the fix by reading code; run once to confirm, not to discover. Treat a failure as a survey: enumerate plausible causes, fix in a batch, run once. A compaction summary or another session's "X is already wired" is a hypothesis — `grep` it.

## Test-run economy

- 1–2 failures out of hundreds in a file your diff didn't touch → re-run that test alone (`mix test.json <file>:<line>` or `--failed`). Passes alone → proceed.
- Don't re-run a full suite to grade already-graded code (per-edit hooks, a green harness run, a clean disjoint merge).
- Bound output: `--cover` dumps hundreds of KB — always `--output /tmp/cov.json` + `jq`. Triage with `--max-failures 1` / `--failed` / one `file:line`.

## No pseudo-rigorous hedging

You have no telemetry or demand signal; the developer asking IS the demand signal. Don't gate requested work on "unproven demand", "wait until a Nth case", or "cheap to add later". A legitimate "wait" names an external blocker with an unblock path. Same for scores: "table-stakes" / "buyers expect" is not a reason — name a concrete one or score honestly low.

## Git — commit / push / PR allowed by default

Commit, push, open PRs without asking when the task calls for it; announce in one line. Only gate: **rewriting already-pushed history** (force-push, amend/rebase of shared commits) — confirm first.

The working tree is shared — stage path-scoped:
- Never `git add -A` / `git add .` / `git commit -a`. Stage `git add <path>` or commit `git commit <path>`; check `git diff --cached --name-only` before every commit.
- Pre-commit hook trips on a foreign file → `git stash push -- <their paths>`, commit yours, `git stash pop`, re-stage. Never fix someone else's work to clear a hook.
- Untracked files you didn't create: leave them.

## Never broadcast an unpatched vulnerability in a committed file

A committed file is public and permanent in git history. Exploit-actionable detail (mechanism, trigger value, PoC, unpublished GHSA/CVE id) never goes into `roadmap/tasks.toml`, `ROADMAP.md`, `CHANGELOG.md`, code comments, or commit messages.

- **Open + undisclosed → out of git.** Track in a private draft GitHub Security Advisory (`gh api repos/<org>/<repo>/security-advisories -X POST`, draft; `vulnerabilities[]` needs ecosystem + package + `vulnerable_version_range`). One per issue.
- **Fixed AND advisory published** → fine to reference. Both, not either.
- **Scheduling the work** → rmap task with a sanitized body: `"harden Tempo fee-payer gas bounds — see private advisory <id>"`.
- During embargo, commit messages and CHANGELOG describe the shape of the fix, not the hole. Public ledgers carry only closed / tracked rows plus a generic open count.
- **Inbound reports** appear ONLY under Security → Advisories (`gh api repos/<org>/<repo>/security-advisories`) — not Dependabot or notifications. Query it; act on `triage` and `draft`.
- **On fix:** patch → release → publish the advisory naming the patched version, same day.
- Already committed = already leaked: redact, and treat history as compromised (rotate/patch).

## Shell safety

`rm` is permitted. Before an irreversible delete, glance at the target — no unexpanded `$VAR`, no over-broad wildcard, not a path you didn't create. `git rm` for tracked files.

## No destructive dependency commands

Never without explicit consent: `mix deps.clean` (incl. `--all`), `mix deps.unlock --all`, `rm -rf _build`, `rm -rf deps`, `mix clean`. Compile error → retry `mix compile` / `mix test`; specific dep → `mix deps.compile <dep> --force`.

## Never pin a dependency to git or path — release it

A `github:` / `git:` / `path:` dependency (or the `package.json` / `Cargo.toml` / `pyproject.toml` equivalent) is a rejection, above all for our own libraries. A library change needed by an app is a task in the library's repo, released with a version bump, then consumed as `{:lib, "~> x.y.z"}`.

- **Implementer:** report "blocked on a `<lib>` release: needs `<change>`". Don't open a library PR from inside the app run and pin its head; don't vendor the code.
- **Reviewer:** a new git/path dep on a package we maintain is a `reject`; on a third-party package a `reject` unless the task body names the pin and why no release exists.
- **Exceptions:** `in_umbrella: true`, and a pin the task body explicitly authorizes with the upstream release it waits for.
- **Precedent:** aave_sim task 148 pinned `bourse` to its own open PR head; the reviewer approved it, and the release still hadn't happened a week later.

## No scope-sequencing qualifiers in durable artifacts

Never write "X first", "starting with X", "initially", "for now", "MVP: X" into repo descriptions, READMEs, moduledocs, code/config comments, commit messages, or vision one-liners — they become unremovable. Sequencing lives in the roadmap only (milestones, task bodies, `out_of_scope`). Describe what the system IS. Exception: inside a `TODO:` comment, which exists to be tracked and removed.

## Integrity

Never fabricate information, experience, metrics or timelines. Distinguish codebase observation / general knowledge / speculation, and name the source ("based on `file.ex`…").

## Research before asserting on niche technical claims

Research proactively (WebFetch when the canonical URL is known, WebSearch otherwise) and cite what you fetched for:
- **Wire formats / encodings** — RLP, ABI, SSZ, Protobuf, BLS, BIP-32/39/44, EIP-712, CBOR, ASN.1/DER. Never byte order, length prefix, padding or canonical form from memory.
- **Protocol details** — EIPs, RFCs, JSON-RPC shapes/error codes, opcode gas, exchange API quirks.
- **Niche / recent library APIs** — about to write `# probably something like`? Fetch the docs.
- **Cross-implementation edge cases** — check ≥2 reference impls; agreement across two is the spec in practice.

Skip for mainstream language/framework knowledge and anything in the codebase or a loaded include. Fetch fails or is ambiguous → say so and lower confidence.

## No evasion — sit with the hard thing

Hitting a wall and silently moving to easier work is the failure. Deferring, skipping, "out of scope", "you could manually…" need the user's approval. Blocked → name it: "blocked on X because Y. Options: A, B." Tempted to add a fallback or nil-guard for missing data → ask whether it should come from upstream; then report instead of working around it. Must move on → a tracked TODO, not a silent gap.

<!-- @-import: ~/.claude/includes/elixir-security-adjudications.md -->
# Elixir Security Adjudications (host-specific)

Two settled, host-specific security verdicts that every fresh agent otherwise
re-derives from scratch. `@`-import this in any repo that declares `mix_audit`
or runs Sobelow, so it also flows into `AGENTS.md` for the cross-family
reviewers via `sync-agents-md.sh`.

## 🚨 ADJUDICATED: the cowlib / gun advisories are ALREADY DECIDED — do NOT re-investigate

**Read this before spending a single token on a `VULNERABLE!` line mentioning `gun`,
`cowlib`, `GHSA-w4f7-4cxr-rv3c`, or `EEF-CVE-2026-43966`.** This has been
adjudicated repeatedly by many sessions — local Claude instances, and every harness
implementer / reviewer / auditor that ran `mix deps.get` in a fresh worktree. Each one
found the same unbudgeted alarm and redid the same analysis. **The verdict is below.
Cite it; don't re-derive it.**

**Where the noise comes from — two independent pipelines, don't confuse them:**

| Source | Reports | Silenced by |
|---|---|---|
| **Hex core**, during `mix deps.get` / `deps.update` / `hex.audit` | OSV incl. the EEF-CVE program | `mix hex.config ignore_advisories "<ids>"` (global, `~/.hex`) or `HEX_IGNORE_ADVISORIES` (comma-separated env var, settable per dispatch) |
| **`mix_audit`**, during `mix deps.audit` | mirego's GHSA mirror | per-repo `.mix_audit_ignore` (the marketplace hook reads it via `--ignore-file`) |

Removing `mix_audit` does **not** silence the `mix deps.get` output — that is Hex, and
every fresh harness worktree runs `deps.get`. That is precisely why every dispatched
agent sees it.

**The verdict — cowlib reached only via `gun` as a WebSocket client (the
`zen_websocket` stack): not reachable.** Evidence is a call-graph fact, not a judgment
call:

| Advisory | Vulnerable function | Reachability |
|---|---|---|
| `EEF-CVE-2026-43966` (alias `GHSA-w4f7-4cxr-rv3c`, `CVE-2026-43966`) | `cow_http_struct_hd:escape_string/2` | **0 references** in `deps/gun/src/` |

**Fixed upstream — bump, never re-ignore.** These were removed from the global Hex
ignore list once a fixed cowlib shipped. If one reappears, the repo is on an older
cowlib: bump it.

| Advisory | Function | Fixed in (OSV range) | Removed from ignore list |
|---|---|---|---|
| `EEF-CVE-2026-43971` | `cow_link:link/1` | cowlib 2.20.0 (`>= 2.9.0 < 2.20.0`) | 2026-09-24 |
| `EEF-CVE-2026-43969` | `cow_cookie:cookie/1` | cowlib 2.21.0 (`>= 2.9.0 < 2.21.0`) | 2026-10-31 |

43966 is still reported against cowlib 2.21.0 / gun 2.7.0 (verified 2026-10-31,
`mix hex.audit` in mpp); no fixed release exists, so reachability is the only available
adjudication. Re-check at the next cowlib release. `hex.audit` in a repo without cowlib
(e.g. harness) warns the ignore "matches no advisory" — that is expected, not a sign it
is resolved.

**The separate `gun 2.5.0` line is a mirror bug, already reported upstream.** gun's real
vulnerable range is `< 2.4.0`; gun 2.5.0 is patched. The mirego importer groups by
`ghsaId` alone, collapsing a two-package advisory into `packages/gun/…yml` carrying
**cowboy's** `< 2.16.0` range, so gun 2.5.0 matches a range that was never gun's. There
is no gun 2.16.x. Filed as **`mirego/elixir-security-advisories#8`** (issue + PR open);
`zen_websocket/.mix_audit_ignore` carries the full write-up and the removal condition.
That gun never calls `cow_http_struct_hd` at all corroborates it independently.

**🚨 `bandit` is NOT in this adjudication — it has a real fix.** `EEF-CVE-2026-74836`
(HIGH) and `EEF-CVE-2026-75484` on bandit 1.12.4 are genuine; **1.12.5 (2026-08-20) is
the fix**. Bump the dependency; never add a bandit id to an ignore list. Blanket-ignoring
"all the CVE noise" buries a HIGH — suppress **per id**, only after the reachability
argument above has been made for that specific id.

**What invalidates this verdict — re-adjudicate if any becomes true:** a repo takes
`cowboy` as a **runtime** (not `only: :test`) dependency; gun's `cookie_store` option is
enabled anywhere; gun is used as a general HTTP client with caller-supplied header
values; or a new cowlib advisory appears that is not the id above.

**Affected repos (cowlib in the lock):** `bourse`, `mpp`, `zen_mm`, `zen_websocket`. As
of 2026-10-31 `mpp` and `zen_websocket` lock cowlib 2.21.0; `bourse` and `zen_mm` still
lock 2.20.0 and will now report 43969 on `deps.get` until bumped. The `onchain*` repos no longer lock cowlib. Suppression is inconsistent across them — most carry
`.mix_audit_ignore`, bourse uses an `--ignore-advisory-ids` alias in
`mix.exs`. Standardize on `.mix_audit_ignore` when you touch one.

**The meta-lesson this section encodes:** the analysis had in fact been done correctly —
it lived in `zen_websocket/mix.exs` and `.mix_audit_ignore`, where no other repo's agent
ever looks. A verdict that isn't written where the *next* agent reads it gets re-derived
forever. Adjudicate once, then put it in `CLAUDE.md` (which flows into `AGENTS.md` for
the cross-family reviewers) — not only in the repo that happened to notice.

## Suppressing Sobelow False Positives — Use `.sobelow-skips`, NOT Inline Comments

When the PostToolUse hook flags a Sobelow false positive (e.g. `Traversal.FileModule`
on an operator-supplied CLI path, not web input), the **inline `# sobelow_skip
["FindingType"]` comment does NOT suppress it** under this host's hook invocation —
verified on tapakly 2026-06: comments placed correctly above both the `def` (with
`@spec` between) and a bare `defp` still re-flagged at the same lines. The hook
honors only the **hash-based `.sobelow-skips` file**, read via `mix sobelow --skip`.

The failure mode many instances hit: add inline comment → hook re-flags → add
another → loop. Stop. The working mechanism:

1. **Confirm the finding is genuinely a false positive** (path is operator/CLI-derived
   or a fixed dir + content hash, never untrusted/web input). Real traversal risk → fix the code.
2. **Check the total outstanding count** — `mix sobelow --format compact`. `--mark-skip-all`
   marks *every* current finding as skipped, so it's only safe when the outstanding set
   IS exactly the false positives you intend to skip. Otherwise you'd silently bury a real one.
3. **Generate the skip file:** `mix sobelow --mark-skip-all` → writes `.sobelow-skips`
   (lines of `FindingType,file:line,HASH`).
4. **Verify suppression with the flag the hook uses:** `mix sobelow --skip --format compact`
   — a plain `mix sobelow` (no `--skip`) still prints them; that's expected, not a failure.
5. **Commit `.sobelow-skips`** alongside the code (it's not gitignored — it's the
   persisted project suppression record so CI / other devs don't re-flag).

**Line shifts INVALIDATE skips, and `--mark-skip-all` never prunes — regenerate, don't accumulate.**
Each entry pins `FindingType,file:line,HASH`, and the line number feeds the hash:
deleting or inserting lines *above* a suppressed finding re-reds the gate even though the
flagged code never changed. Re-running `--mark-skip-all` leaves the dead entry behind
forever — sobelow ≤0.14 appends a new generation; 0.15+ rewrites merged+deduped+sorted
(`--legacy-skips` restores append) but still keeps entries with no live finding
(observed ccxt_client 2026-07-22 under 0.14: 57 entries on file, 9 live findings —
48 stale). The cadence: whenever a skip-related
re-red appears (or an audit notices bloat), **regenerate wholesale** — confirm every
currently-outstanding finding (`mix sobelow --no-skip --format compact`) is a genuine
false positive per step 1, then `rm .sobelow-skips && mix sobelow --mark-skip-all`,
verify zero with `--skip`, commit. Never regenerate while an unconfirmed finding is
outstanding — that buries it.

Pairs with `critical-rules.md` § FIX HOOK-FLAGGED ISSUES: suppression IS the fix for a
documented false positive — but via the file, not a comment the hook ignores.

<!-- @-import: ~/.claude/includes/harness-guardrails.md -->
## Harness Guardrails (eager)

Always-on floor for repos that dispatch through harness. These rules fail by non-recognition — the moment they apply doesn't feel like a moment to look anything up — so they stay ambient. Everything else (loop, dispatch-vs-hand-build, verdict table, routing, landing mechanics, orchestrator loop) lives in the **`harness:harness-workflow` skill**: invoke it before planning, dispatching, reading a verdict or recovering a run. API surface: `harness:harness-driver`.

**🚨 Origin is the source of truth for what landed** — not a local `tasks.toml`, not an await return, not a transcript. Under auto-land the lander pushes from a detached worktree and `TargetSync` often skips your checkout (dirty tree, non-ff, self-host), so local status lags. Before concluding "didn't land": `git fetch origin <target>` and check `git log --oneline origin/<target>` for `task <id> -> done (shipped …)`. Misreading stale local status re-dispatches and **duplicate-lands shipped work**.

**🚨 Settle ≠ landed.** `state: :done, verdict: approve` means *queued to land*; the serialized lander rebases and pushes afterwards (under `:pr`, `done --shipped-in` waits for the PR merge). Don't gate the next wave on approval — confirm the land on origin.

**🚨 Never block on `dispatch-await*` for real runs.** The MCP idle timeout (Claude Code: 300 s) kills the call while the run keeps going. Arm one bounded background watcher that greps `$BASE..origin/<target>` (baseline is load-bearing — never the whole log) and has a deadline. Don't micromanage in-flight runs; `dispatch-status` is for diagnosing a run that isn't landing.

**🚨 Recover, don't redo — committed work is paid for.** Before any reset-to-`pending` + re-dispatch, check `git log --oneline origin/<target>..harness/<run-id>`. Commits present ⇒ recover:

| Retained `harness/<run-id>` with commits | Primitive |
|---|---|
| Approved, unlanded (land-cap, conflict, lander crash) | `dispatch-reland` — zero agent tokens |
| Good work, review-stage failure | `dispatch-rereview` |
| Implement-stage incomplete / `:failed` | `dispatch-resume_failed` (`escalate: true` to re-route) |
| Live `:held` run | `dispatch-resume` (question-held: `dispatch-steer` first) |
| No commits, no retained branch | reset → `pending` + `dispatch-task` — the only full redo |

Land conflict → repair worktree off `origin/<target>`, resolve, repoint the branch, `dispatch-reland`. Never hand-push to the target when a reland can land it.


<!--
Selective-load (Opus 4.8): the eager floor is `critical-rules` (hard
guardrails that must stay ambient) + `harness-workflow` (implement -> review
-> land loop — this repo is a registered harness dispatch target).
Everything else is skill-on-demand — see `~/.claude/setup-guide.md` for the
per-include rationale and the skill-vs-import decision rule. Re-add an
`@`-import here only if Opus is observed failing on that surface.
-->

## Toolchain & check commands

Self-contained so it survives into `AGENTS.md` on regen — cross-family
reviewers (codex / cursor / grok) read the generated `AGENTS.md`, not
Claude's skills/includes.

- **Toolchain:** Elixir / OTP pinned by the repo-local `.tool-versions`
  (asdf-managed) — read that file for the exact versions in effect; don't
  hardcode a version here that can drift out of sync with it.
- **Command inventory:** `mix ci` is the full post-merge QA command. Read
  `mix.exs` for the contents of `check.dispatch`; choose scoped commands and
  focused tests using the imported verification policy.

- **`mix test.json` and `mix dialyzer.json` emit JSON by design** (the
  `ex_unit_json` / `dialyzer_json` reporters) — this is not a build failure.
  Parse the JSON payload for real failures; never flag the JSON envelope
  itself as an error. When the `dialyzer_json` encoder can't serialize a
  particular warning shape, plain `mix dialyzer` is authoritative for that
  warning.
- **`reach.check --smells` is advisory, not a gate**, unless `strict` is
  configured in `.reach.exs` (`smells: [strict: true]`) — a smell finding is
  backlog signal, not a build break, until strict mode is turned on.

## What This Is

The `Harness.AgentAdapter` behaviour plus six adapters for headless
coding-agent CLIs (Claude Code, Cursor, Codex, Grok, Antigravity, Pi), all
driven over OTP Ports — no per-agent SDK, no output normalization. Extracted
verbatim from the [`harness`](https://github.com/ZenHive/harness)
orchestration engine, whose `AgentAdapter` subsystem it was; the module
namespace stays `Harness.AgentAdapter.*`.

- **Thin contract by design:** *invoke* an agent, *capture its raw output*,
  *declare capabilities* — nothing more. No normalized event model; the
  consumer is an AI that reads each agent's raw JSON natively.
- **Required callbacks:** `capabilities/0`, `rule_channel/0`,
  `build_command/1`. `classify_message/2` and `terminate/1` default via
  `use Harness.AgentAdapter` and are overridable.
- **`AgentAdapter.invoke/2`** does the generic Port spawn; `attach_rules/2`
  delivers caller-supplied rule content ahead of `build_command/1`,
  dispatching on `c:rule_channel/0` (`:system_prompt_file`,
  `:codex_ephemeral_file`, `:cursor_ephemeral_file`, `:prompt_preamble`,
  `:none`).
- **Exit code is unreliable** — termination is derived from the port closing
  plus the watchdog's timeout guard, never from `$?`.
- All six adapters declare `worktree_isolation: true`.
- **Agent vs model are orthogonal:** `Invocation.model` threads to each
  adapter's `--model` flag independently of which adapter is dispatched.
- Config lives under `config :harness_agent_adapter, :run` —
  `total_timeout:` / `idle_timeout:` / `progress_timeout:`.
- `Harness.AgentAdapter.Testing.ConformanceCase` ships in `lib/` so
  downstream consumers can run the conformance suite against their own
  adapters. Every shipped adapter passes it unchanged.

## AGENTS.md

`AGENTS.md` is generated from this file by
`~/_DATA/code/claude-marketplace/scripts/sync-agents-md.sh` (recursively
inlines every `@`-import). Regenerate after any `CLAUDE.md` change; **never
hand-edit `AGENTS.md`.**
