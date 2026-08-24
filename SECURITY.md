# Security Policy

`harness_agent_adapter` spawns headless coding-agent CLIs as OS processes and
threads caller-controlled prompts, rule content, and environment variables
into their command lines and env. Bugs in command construction, environment
scrubbing, or worktree-path handling can leak credentials or let agent output
escape the intended working directory, so we take security reports
seriously.

## Supported Versions

This library is pre-1.0; only the current release line receives security
fixes.

| Version          | Supported          |
| ---------------- | ------------------ |
| Latest minor     | :white_check_mark: |
| Earlier versions | :x:                |

## Reporting a Vulnerability

**Do not open a public issue for security vulnerabilities.**

Report privately through GitHub's **Security** tab on this repository:
**Security → Advisories → "Report a vulnerability"**
(<https://github.com/ZenHive/harness_agent_adapter/security/advisories/new>).

This opens a private advisory visible only to you and the maintainers.

### In scope

- Command-line and environment construction in `build_command/1` for any
  shipped adapter
- Auth-environment scrubbing (`Harness.AgentAdapter.scrub_auth_env/2`)
- Rule-file delivery and cleanup (`Harness.AgentAdapter.RulesInjection`) —
  path traversal, ephemeral-file leakage, or stale-injection reuse
- The watchdog's blocked-command and worktree-boundary detection
  (`Harness.AgentAdapter.Watchdog`)

### Out of scope

- Vulnerabilities in the agent CLIs themselves (Claude Code, Cursor, Codex,
  Grok, Antigravity, Pi) — report those to their respective maintainers
- Application logic built on top of this package (e.g. `harness`'s own
  dispatch, review, or landing logic)
- Vulnerabilities in upstream dependencies — a heads-up is welcome

### What to expect

- **Acknowledgement** within a few business days.
- A fix or mitigation plan communicated through the private advisory.
- Coordinated disclosure: we'll agree on a disclosure timeline with you
  before any public release.

Thank you for helping keep the stack safe.
