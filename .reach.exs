# Reach architecture policy for harness_agent_adapter (extracted from harness's
# `Harness.AgentAdapter.*` subsystem — the behaviour + six headless coding-agent
# CLI adapters, driven over OTP Ports).
#
# harness's own .reach.exs forbade `Harness.AgentAdapter.*` from calling
# `Harness.Dashboard/Dispatch/Batch/Oban/Lander.*` — those modules live in the
# harness monorepo, not here, so that rule list is dead weight in this repo and
# is NOT copied verbatim. The real invariant for a standalone extraction is the
# inverse shape: nothing in *this* package may reach outside its own namespace
# into a bare `Harness.*` module that isn't `Harness.AgentAdapter.*` — i.e. no
# accidental dependency on the monorepo surface this was extracted from.
#
# 🚨 That invariant CANNOT be expressed as a `calls: forbidden` rule in reach
# 2.7's config DSL, and this is deliberate, not an oversight — read before
# "fixing" it:
#
#   `calls: [forbidden: [{caller_patterns, call_patterns, opts}]]` matches a
#   call when the CALLER matches `caller_patterns` AND the call (as a
#   "Module.function/arity" string) matches `call_patterns`. The only
#   exclusion knob, `opts[:except]`, filters by CALLER pattern
#   (`forbidden_call_rule_matches?/3` in reach's
#   `Reach.Check.Architecture`) — there is no callee-side / call-pattern
#   exclusion. So a rule shaped "forbid Harness.AgentAdapter.* from calling
#   Harness.* EXCEPT Harness.AgentAdapter.*" cannot be written: any pattern
#   broad enough to catch a stray `Harness.Dashboard.foo()` (e.g. call
#   pattern "Harness.*") also matches this package's OWN legitimate
#   `Harness.AgentAdapter.*` calls, and there is no way to carve those back
#   out on the callee side. `boundaries.internal` doesn't fit either — it
#   flags INBOUND calls into a marked-internal module from disallowed
#   callers, not outbound calls a module makes to a forbidden namespace.
#
#   Given that gap, this file deliberately carries NO `calls:` section rather
#   than one that looks like it enforces the invariant but silently matches
#   nothing (or worse, false-positives on this package's own self-calls). The
#   actual backstop for "don't reference a monorepo-only module" is the
#   compiler: this repo depends on nothing named `Harness.*` other than its
#   own modules, so any stray `Harness.Dashboard.foo()` etc. fails to compile
#   (undefined function/module) long before reach would ever run. If reach
#   later grows callee-side negation, revisit.
[
  boundaries: [
    # The consumer-facing surface: the behaviour itself, the driver entry
    # point (`Harness.AgentAdapter.Driver.run/3`, the `Descripex`-annotated
    # api()), the six concrete adapters a caller selects by module, the
    # capability/session-token lookup, and the structs that cross the public
    # boundary (Invocation in, Outcome/Run out).
    public: [
      "Harness.AgentAdapter",
      "Harness.AgentAdapter.Driver",
      "Harness.AgentAdapter.Registry",
      "Harness.AgentAdapter.Invocation",
      "Harness.AgentAdapter.Outcome",
      "Harness.AgentAdapter.Capabilities",
      "Harness.AgentAdapter.Run",
      "Harness.AgentAdapter.Claude",
      "Harness.AgentAdapter.Codex",
      "Harness.AgentAdapter.Cursor",
      "Harness.AgentAdapter.Grok",
      "Harness.AgentAdapter.Antigravity",
      "Harness.AgentAdapter.Pi"
    ]
  ],
  smells: [
    # `--smells` is advisory unless strict is set (reach 2.8.2 config.ex
    # ~L351); this makes every `mix reach.check --arch --smells` invocation
    # gate rather than print theatre.
    strict: true,
    behaviour_candidate: [
      # This detector fires on "N modules expose the same public callbacks;
      # consider extracting a behaviour" — which is precisely what this package
      # already IS. `Harness.AgentAdapter` is the extracted behaviour, and each
      # adapter declares it through `use Harness.AgentAdapter`. Reach only
      # cancels the finding via `Reach.MacroFact.explained_callbacks/2`, whose
      # `explained_callbacks` data is populated for a hardcoded set of
      # frameworks (Phoenix/Ecto/Ash) — there is no config knob to register a
      # project's own `__using__` macro, so a custom behaviour can never be
      # explained away. The finding is therefore unfixable-by-design here:
      # complying with it would mean extracting the behaviour a second time.
      #
      # Scoped to the adapter modules only. A same-shape group anywhere else in
      # the package still reports.
      ignore: [
        modules: [
          "Harness.AgentAdapter.Claude",
          "Harness.AgentAdapter.Codex",
          "Harness.AgentAdapter.Cursor",
          "Harness.AgentAdapter.Grok",
          "Harness.AgentAdapter.Antigravity",
          "Harness.AgentAdapter.Pi",
          "Harness.AgentAdapter.Testing.NoncompliantAdapter"
        ]
      ]
    ]
  ]
]
