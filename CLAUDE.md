# harness_agent_adapter — CLAUDE.md

@~/.claude/includes/verification-policy.md

**Repo:** [github.com/ZenHive/harness_agent_adapter](https://github.com/ZenHive/harness_agent_adapter) (public, default branch `main`).

## Always-on includes (core only)

@~/.claude/includes/critical-rules.md
@~/.claude/includes/elixir-security-adjudications.md
@~/.claude/includes/harness-workflow.md

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
- **Command inventory:** `mix check.dispatch` is format + compile only;
  reviewers add focused tests and risk-relevant live/security checks.
  `mix ci` is the portable full post-merge QA command (`check.dispatch`
  plus Credo, Doctor, clone detection, Reach, Sobelow, the coverage
  suite, and Dialyzer). `mix precommit.full` is `ci` plus `agents.check`.
  Read `mix.exs` for the exact alias steps.

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
