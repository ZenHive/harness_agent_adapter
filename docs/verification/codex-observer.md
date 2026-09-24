# Codex observation contract

`Harness.AgentAdapter.Codex.Observer.command/3` is separate from the autonomous
coding adapter. The caller supplies an exclusively owned temporary directory,
`response.schema.json` in that directory, an explicit model, and a prompt.
The caller owns process supervision, timeout, raw output capture and cleanup.

The command uses `codex exec --sandbox read-only`, approval policy `never`, a
fresh ephemeral session, no user configuration or exec rules, no project
instructions, disabled shell/hooks/apps/skills/multi-agent features, disabled web
search and an empty MCP configuration. It never resumes or falls back to a model.
The schema controls output structure, not the truth of model observations.

Verified by the Harness Task 445 integration suite with Codex CLI 0.155.0 and
explicit `gpt-6-astra`: observations persisted to an isolated Postgres database,
then a later audit update revised the same finding. The parent repository keeps
live invocation, rejection, filesystem-canary and screenshot evidence under
`docs/verification/run-insights/task-445`. Re-run its `CodexLiveTest` to check
provider behavior independently; recorded output is not a live oracle.

Codex is sandboxed, not claimed to be tool-free. Supplying read-only permissions
does not justify granting external MCP or lifecycle access. Use an empty caller
workspace and the command as returned, without appending permission overrides.

Official contract:
https://learn.chatgpt.com/docs/non-interactive-mode
