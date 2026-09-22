# Audit of bca03d2

Date: 2026-09-22. Integrated revision: `bca03d29dbe27c76cd4adb3c17c8877405229900`.
Reviewed range: `ecfcb4ccbaa09d1f6e7f8a75e17bf75bcce8ed68..bca03d29dbe27c76cd4adb3c17c8877405229900`.
Commits: 8fe709f, f477030, 68b620e, 361eb09, 87ac093, bca03d2.

## Hygiene

Reviewed the settings cleanup, previous audit, roadmap transitions, CLAUDE/AGENTS instructions, Mix alias graph, marketplace lookup and its tests. The cleanup leaves the marketplace catalog deliberately available. Dispatch now runs format/compile; every former analyzer remains reachable through ci/precommit.full. Lookup preserves operator/Claude/Grok precedence and propagates generator failure. No dead code, debug output, naming defect or consumer CHANGELOG gap was found in the delivered changes. No reviewer rejections were supplied, so there is no false-rejection finding.

Two findings, both fixed forward:

1. AGENTS.md was stale from transitive harness-workflow include changes (generator instructions and graceful-shutdown recovery documentation). The newly landed fallback correctly ran the installed Claude marketplace script and exposed the drift. Regenerated using that script; no manual generated-file edits.
2. Full QA exposed an existing race in process_fixture_test.exs: SIGKILL can terminate the port before Port.close, raising ArgumentError. The reporter's retry also failed; the one isolated rerun passed. Replaced the redundant close with a port monitor established before SIGKILL and an assertion of its DOWN message. The existing assertion of OS process death remains.

Inspected the existing roadmap and supplied prior QA evidence before repair filing. Task 2 already fixes lookup, so it was not reopened or duplicated. Filed **task 3** with `rmap new --from-stdin` for the two small inline repairs, then marked done with `rmap status` after focused checks passed. Routing: codex / gpt-6-astra. No independent-review verification flag was set. No outstanding repair is deferred.

## Integrated QA: failed

Configured command: `mix precommit.full`. All configured checks were attempted/completed at the original integrated revision before any tracked edits. First invocation exited 1 because the cold tree lacked dependencies. `mix deps.get` succeeded without changing mix.lock; the second invocation reached the suite and stopped on its failure (exit 1). Ran the remaining Dialyzer and freshness checks separately to collect independent outcomes.

| Check | Result |
| --- | --- |
| Format / compile --warnings-as-errors | Passed; dependency-only compiler warnings retained below |
| Credo --strict --ignore TagTODO,TagFIXME | Passed: 48 files, 348 mods/funs, no issues |
| Doctor --raise | Passed: 24 modules; documentation, moduledoc and spec coverage 100% |
| ex_dna --max-clones 0 | Passed: 23 files, clone budget 0/0 |
| reach.check --arch --smells | Passed: architecture OK, no smells; strict smells configured |
| sobelow --skip --exit low | Completed successfully; expected missing-router warning for this non-Phoenix library |
| test.json --cover --cover-threshold 85 --exclude integration | Failed: 342 passed, 1 failed, 7 excluded, 350 total; coverage 91.07% (561/616), threshold met; seed 552999 |
| mix dialyzer (separate continuation) | Passed: zero errors, zero skips, zero unnecessary skips; cold PLTs built |
| mix agents.check (separate continuation) | Failed: STALE; selected installed Claude marketplace generator, not a missing-script skip |

The configured suite explicitly excludes seven integration tests; live agent-provider conformance was not run and no live-provider success is claimed. No operator server/database was used. Original QA remains **failed**, even though both observed defects were repaired. No full-suite rerun was used to overwrite the integrated result.

## Repair validation

- One pre-fix isolated rerun: `MIX_ENV=test mix test.json test/harness/agent_adapter/testing/process_fixture_test.exs:26`: 1 passed, 4 excluded (seed 809297), supporting the race diagnosis.
- `bash /home/harness/.claude/plugins/marketplaces/zenhive/scripts/sync-agents-md.sh`: generated AGENTS.md.
- `mix format test/harness/agent_adapter/testing/process_fixture_test.exs`: passed.
- `mix compile --warnings-as-errors`: passed.
- `MIX_ENV=test mix test.json test/harness/agent_adapter/testing/process_fixture_test.exs test/mix_project_test.exs`: 15 passed, zero failures/exclusions (seed 638684).
- `mix agents.check`: OK, AGENTS.md is up to date.
- `git diff --check`: passed.

The following captured command output is persisted here because temporary logs do not survive worktree cleanup. The machine summary is in .harness/audit.json and is not committed.

## Evidence: mix precommit.full (cold dependencies missing)

```text
Unchecked dependencies for environment dev:
* descripex (Hex package)
  the dependency is not available, run "mix deps.get"
* ex_unit_json (Hex package)
  the dependency is not available, run "mix deps.get"
* jason (Hex package)
  the dependency is not available, run "mix deps.get"
* ex_ast (Hex package)
  the dependency is not available, run "mix deps.get"
* styler (Hex package)
  the dependency is not available, run "mix deps.get"
* ex_slop (Hex package)
  the dependency is not available, run "mix deps.get"
* mix_audit (Hex package)
  the dependency is not available, run "mix deps.get"
* bandit (Hex package)
  the dependency is not available, run "mix deps.get"
* sobelow (Hex package)
  the dependency is not available, run "mix deps.get"
* dialyzer_json (Hex package)
  the dependency is not available, run "mix deps.get"
* ex_dna (Hex package)
  the dependency is not available, run "mix deps.get"
* ex_doc (Hex package)
  the dependency is not available, run "mix deps.get"
* doctor (Hex package)
  the dependency is not available, run "mix deps.get"
* tidewave (Hex package)
  the dependency is not available, run "mix deps.get"
* reach (Hex package)
  the dependency is not available, run "mix deps.get"
* dialyxir (Hex package)
  the dependency is not available, run "mix deps.get"
* credo (Hex package)
  the dependency is not available, run "mix deps.get"
** (Mix) Can't continue due to errors on dependencies
```

## Evidence: mix deps.get

```text
Resolving Hex dependencies...
Resolution completed in 0.054s
Unchanged:
  bandit 1.12.5
  bunt 1.0.0
  circular_buffer 1.1.0
  credo 1.7.19
  decimal 3.1.1
  descripex 1.0.0
  dialyxir 1.4.8
  dialyzer_json 0.2.1
  doctor 0.23.0
  earmark_parser 1.4.46
  erlex 0.2.9
  ex_ast 0.13.1
  ex_dna 1.5.4
  ex_doc 0.40.4
  ex_slop 0.4.4
  ex_unit_json 0.6.1
  file_system 1.1.1
  hpax 1.0.4
  jason 1.4.5
  json_spec 1.2.0
  libgraph 0.16.0
  makeup 1.2.2
  makeup_elixir 1.0.1
  makeup_erlang 1.1.0
  mime 2.0.7
  mix_audit 2.1.5
  nimble_parsec 1.4.2
  plug 1.20.3
  plug_crypto 2.2.0
  reach 2.8.4
  sobelow 0.15.0
  sourceror 1.12.2
  styler 1.12.2
  telemetry 1.4.2
  thousand_island 1.5.0
  tidewave 0.9.0
  websock 0.5.3
  websock_adapter 0.6.0
  yamerl 0.10.0
  yaml_elixir 2.12.2
* Getting descripex (Hex package)
* Getting jason (Hex package)
* Getting ex_unit_json (Hex package)
* Getting dialyzer_json (Hex package)
* Getting styler (Hex package)
* Getting credo (Hex package)
* Getting ex_slop (Hex package)
* Getting dialyxir (Hex package)
* Getting ex_doc (Hex package)
* Getting doctor (Hex package)
* Getting sobelow (Hex package)
* Getting ex_dna (Hex package)
* Getting ex_ast (Hex package)
* Getting reach (Hex package)
* Getting mix_audit (Hex package)
* Getting tidewave (Hex package)
* Getting bandit (Hex package)
* Getting hpax (Hex package)
* Getting plug (Hex package)
* Getting telemetry (Hex package)
* Getting thousand_island (Hex package)
* Getting websock (Hex package)
* Getting mime (Hex package)
* Getting plug_crypto (Hex package)
* Getting circular_buffer (Hex package)
* Getting websock_adapter (Hex package)
* Getting yaml_elixir (Hex package)
* Getting yamerl (Hex package)
* Getting libgraph (Hex package)
* Getting sourceror (Hex package)
* Getting decimal (Hex package)
* Getting earmark_parser (Hex package)
* Getting makeup_elixir (Hex package)
* Getting makeup_erlang (Hex package)
* Getting makeup (Hex package)
* Getting nimble_parsec (Hex package)
* Getting erlex (Hex package)
* Getting bunt (Hex package)
* Getting file_system (Hex package)
* Getting json_spec (Hex package)
You have added/upgraded packages you could sponsor, run `mix hex.sponsor` to learn more
```

## Evidence: mix precommit.full (after dependency bootstrap)

```text
==> earmark_parser
Compiling 2 files (.xrl)
Compiling 1 file (.yrl)
Compiling 3 files (.erl)
Compiling 32 files (.ex)
Generated earmark_parser app
==> file_system
Compiling 7 files (.ex)
Generated file_system app
==> ex_unit_json
Compiling 13 files (.ex)
Generated ex_unit_json app
==> mime
Compiling 1 file (.ex)
Generated mime app
==> circular_buffer
Compiling 1 file (.ex)
Generated circular_buffer app
==> bunt
Compiling 2 files (.ex)
Generated bunt app
==> plug_crypto
Compiling 5 files (.ex)
Generated plug_crypto app
==> hpax
Compiling 4 files (.ex)
Generated hpax app
==> harness_agent_adapter
===> Analyzing applications...
===> Compiling yamerl
/data/postgresql/harness/worktrees/harness_agent_adapter/landing/run-1790039477904-68e1b9de/deps/yamerl/src/yamerl_node_binary.erl:65:9: Warning: 'catch ...' is deprecated; please use 'try ... catch ... end' instead.
Compile directive 'nowarn_deprecated_catch' can be used to suppress
warnings in selected modules.
%   65|    case catch base64:decode(Text) of
%     |         ^

/data/postgresql/harness/worktrees/harness_agent_adapter/landing/run-1790039477904-68e1b9de/deps/yamerl/src/yamerl_node_binary.erl:72:9: Warning: 'catch ...' is deprecated; please use 'try ... catch ... end' instead.
Compile directive 'nowarn_deprecated_catch' can be used to suppress
warnings in selected modules.
%   72|    case catch base64:decode(Text) of
%     |         ^

    ┌─ src/yamerl_node_binary.erl:
    │
 65 │     case catch base64:decode(Text) of
    │          ╰── Warning: 'catch ...' is deprecated; please use 'try ... catch ... end' instead.
Compile directive 'nowarn_deprecated_catch' can be used to suppress
warnings in selected modules.

    ┌─ src/yamerl_node_binary.erl:
    │
 72 │     case catch base64:decode(Text) of
    │          ╰── Warning: 'catch ...' is deprecated; please use 'try ... catch ... end' instead.
Compile directive 'nowarn_deprecated_catch' can be used to suppress
warnings in selected modules.


/data/postgresql/harness/worktrees/harness_agent_adapter/landing/run-1790039477904-68e1b9de/deps/yamerl/src/yamerl_constr.erl:801:5: Warning: 'catch ...' is deprecated; please use 'try ... catch ... end' instead.
Compile directive 'nowarn_deprecated_catch' can be used to suppress
warnings in selected modules.
%  801|     catch Mod:module_info(),
%     |     ^

     ┌─ src/yamerl_constr.erl:
     │
 801 │      catch Mod:module_info(),
     │      ╰── Warning: 'catch ...' is deprecated; please use 'try ... catch ... end' instead.
Compile directive 'nowarn_deprecated_catch' can be used to suppress
warnings in selected modules.


==> styler
Compiling 17 files (.ex)
Generated styler app
==> erlex
Compiling 1 file (.xrl)
Compiling 1 file (.yrl)
Compiling 2 files (.erl)
Compiling 2 files (.ex)
Generated erlex app
==> sourceror
Compiling 20 files (.ex)
Generated sourceror app
==> json_spec
Compiling 2 files (.ex)
Generated json_spec app
==> descripex
Compiling 6 files (.ex)
Generated descripex app
==> decimal
Compiling 4 files (.ex)
Generated decimal app
==> jason
Compiling 10 files (.ex)
Generated jason app
==> sobelow
Compiling 51 files (.ex)
Generated sobelow app
==> ex_ast
Compiling 36 files (.ex)
Generated ex_ast app
==> yaml_elixir
Compiling 6 files (.ex)
Generated yaml_elixir app
==> mix_audit
Compiling 16 files (.ex)
Generated mix_audit app
==> dialyzer_json
Compiling 4 files (.ex)
     warning: :dialyzer.format_warning/1 is undefined (module :dialyzer is not available or is yet to be defined)
     │
 134 │     :dialyzer.format_warning({:warn, {~c"", 0}, {warning_type, args}})
     │               ~
     │
     └─ lib/dialyzer_json/warning_encoder.ex:134:15: DialyzerJson.WarningEncoder.format_raw_message/2

     warning: :dialyzer.run/1 is undefined (module :dialyzer is not available or is yet to be defined)
     │
 333 │       :dialyzer.run(args)
     │                 ~
     │
     └─ lib/mix/tasks/dialyzer_json.ex:333:17: Mix.Tasks.Dialyzer.Json.run_dialyzer/0

Generated dialyzer_json app
==> libgraph
Compiling 15 files (.ex)
Generated libgraph app
==> nimble_parsec
Compiling 4 files (.ex)
Generated nimble_parsec app
==> makeup
Compiling 15 files (.ex)
Generated makeup app
==> makeup_elixir
Compiling 6 files (.ex)
Generated makeup_elixir app
==> makeup_erlang
Compiling 4 files (.ex)
Generated makeup_erlang app
==> ex_doc
Compiling 30 files (.ex)
Generated ex_doc app
==> harness_agent_adapter
===> Analyzing applications...
===> Compiling telemetry
==> thousand_island
Compiling 18 files (.ex)
Generated thousand_island app
==> doctor
Compiling 17 files (.ex)
    warning: this clause of defp valid_moduledoc?/2 is never used (or it will always fail/warn when invoked)
    │
 96 │   defp valid_moduledoc?(%ModuleReport{is_protocol_implementation: true}, _config), do: true
    │        ~
    │
    └─ lib/reporters/module_explain.ex:96:8: Doctor.Reporters.ModuleExplain.valid_moduledoc?/2

     warning: this clause of defp valid_doc_coverage?/2 is never used (or it will always fail/warn when invoked)
     │
 103 │   defp valid_doc_coverage?(%ModuleReport{is_protocol_implementation: true}, _config), do: true
     │        ~
     │
     └─ lib/reporters/module_explain.ex:103:8: Doctor.Reporters.ModuleExplain.valid_doc_coverage?/2

Generated doctor app
==> dialyxir
Compiling 70 files (.ex)
Generated dialyxir app
==> credo
Compiling 257 files (.ex)
Generated credo app
==> ex_slop
Compiling 45 files (.ex)
Generated ex_slop app
==> ex_dna
Compiling 36 files (.ex)
Generated ex_dna app
==> reach
Compiling 287 files (.ex)
Generated reach app
==> plug
Compiling 1 file (.erl)
Compiling 42 files (.ex)
Generated plug app
==> websock
Compiling 1 file (.ex)
Generated websock app
==> bandit
Compiling 54 files (.ex)
Generated bandit app
==> websock_adapter
Compiling 4 files (.ex)
Generated websock_adapter app
==> tidewave
Compiling 19 files (.ex)
Generated tidewave app
==> harness_agent_adapter
Compiling 23 files (.ex)
Generated harness_agent_adapter app
Checking 48 source files ...

Please report incorrect results: https://github.com/rrrene/credo/issues

Analysis took 0.1 seconds (0.00s to load, 0.1s running 98 checks on 48 files)
348 mods/funs, found no issues.

Use `mix credo explain` to explain issues, `mix credo --help` for options.
Doctor file found. Loading configuration.
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Doc Cov  Spec Cov  Module                                   File                                                      Functions  No Docs  No Specs  Module Doc  Struct Spec
100%     100%      Harness.AgentAdapter                     lib/harness/agent_adapter.ex                              14         0        0         Yes         N/A        
100%     100%      Harness.AgentAdapter.Antigravity         lib/harness/agent_adapter/antigravity.ex                  5          0        0         Yes         N/A        
N/A      N/A       Harness.AgentAdapter.Capabilities        lib/harness/agent_adapter/capabilities.ex                 0          0        0         Yes         Yes        
100%     100%      Harness.AgentAdapter.Claude              lib/harness/agent_adapter/claude.ex                       3          0        0         Yes         N/A        
100%     100%      Harness.AgentAdapter.Codex               lib/harness/agent_adapter/codex.ex                        3          0        0         Yes         N/A        
100%     100%      Harness.AgentAdapter.Cursor              lib/harness/agent_adapter/cursor.ex                       3          0        0         Yes         N/A        
100%     100%      Harness.AgentAdapter.Driver              lib/harness/agent_adapter/driver.ex                       1          0        0         Yes         N/A        
100%     100%      Harness.AgentAdapter.Grok                lib/harness/agent_adapter/grok.ex                         3          0        0         Yes         N/A        
N/A      N/A       Harness.AgentAdapter.Invocation          lib/harness/agent_adapter/invocation.ex                   0          0        0         Yes         Yes        
100%     100%      Harness.AgentAdapter.OSProcess           lib/harness/agent_adapter/os_process.ex                   6          0        0         Yes         N/A        
N/A      N/A       Harness.AgentAdapter.Outcome             lib/harness/agent_adapter/outcome.ex                      0          0        0         Yes         Yes        
100%     100%      Harness.AgentAdapter.Pi                  lib/harness/agent_adapter/pi.ex                           3          0        0         Yes         N/A        
100%     100%      Harness.AgentAdapter.Registry            lib/harness/agent_adapter/registry.ex                     2          0        0         Yes         N/A        
N/A      N/A       Harness.AgentAdapter.RuleDelivery        lib/harness/agent_adapter/rule_delivery.ex                0          0        0         Yes         Yes        
100%     100%      Harness.AgentAdapter.RulesInjection      lib/harness/agent_adapter/rules_injection.ex              5          0        0         Yes         N/A        
N/A      N/A       Harness.AgentAdapter.Run                 lib/harness/agent_adapter/run.ex                          0          0        0         Yes         Yes        
100%     100%      Harness.AgentAdapter.Testing.Conformanc  lib/harness/agent_adapter/testing/conformance_case.ex     1          0        0         Yes         N/A        
N/A      N/A       Harness.AgentAdapter.Testing.Conformanc  lib/harness/agent_adapter/testing/conformance_case.ex     0          0        0         Yes         N/A        
100%     100%      Harness.AgentAdapter.Testing.FakeAdapte  lib/harness/agent_adapter/testing/fake_adapter.ex         5          0        0         Yes         N/A        
100%     100%      Harness.AgentAdapter.Testing.FakeModelA  lib/harness/agent_adapter/testing/fake_model_adapter.ex   2          0        0         Yes         N/A        
100%     100%      Harness.AgentAdapter.Testing.GitFixture  lib/harness/agent_adapter/testing/git_fixture.ex          4          0        0         Yes         N/A        
100%     100%      Harness.AgentAdapter.Testing.Noncomplia  lib/harness/agent_adapter/testing/noncompliant_adapter.e  3          0        0         Yes         N/A        
100%     100%      Harness.AgentAdapter.Testing.ProcessFix  lib/harness/agent_adapter/testing/process_fixture.ex      2          0        0         Yes         N/A        
100%     100%      Harness.AgentAdapter.Watchdog            lib/harness/agent_adapter/watchdog.ex                     5          0        0         Yes         Yes        
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Summary:

Passed Modules: 24
Failed Modules: 0
Total Doc Coverage: 100.0%
Total Moduledoc Coverage: 100.0%
Total Spec Coverage: 100.0%

Doctor validation has passed!

  ✓ No code duplication detected (23 files)

  Detection time:     42ms

  Clone budget:       0/0

Analyzing project...
Analysis scope: MIX_ENV=dev; roots=lib, src; files=23

────────────────────────────────────────
  Architecture Policy
────────────────────────────────────────
  OK

────────────────────────────────────────
  Cross-Function Smell Detection
────────────────────────────────────────
  (no issues)
WARNING: Sobelow cannot find the router. If this is a Phoenix application
please use the `--router` flag to specify the router's location.

##############################################
#                                            #
#          Running Sobelow - v0.15.0         #
#  Created by Griffin Byatt - @griffinbyatt  #
#     NCC Group - https://nccgroup.trust     #
#                                            #
##############################################

... SCAN COMPLETE ...

==> file_system
Compiling 7 files (.ex)
Generated file_system app
==> ex_unit_json
Compiling 13 files (.ex)
Generated ex_unit_json app
==> bunt
Compiling 2 files (.ex)
Generated bunt app
==> harness_agent_adapter
===> Analyzing applications...
===> Compiling yamerl
/data/postgresql/harness/worktrees/harness_agent_adapter/landing/run-1790039477904-68e1b9de/deps/yamerl/src/yamerl_node_binary.erl:65:9: Warning: 'catch ...' is deprecated; please use 'try ... catch ... end' instead.
Compile directive 'nowarn_deprecated_catch' can be used to suppress
warnings in selected modules.
%   65|    case catch base64:decode(Text) of
%     |         ^

/data/postgresql/harness/worktrees/harness_agent_adapter/landing/run-1790039477904-68e1b9de/deps/yamerl/src/yamerl_node_binary.erl:72:9: Warning: 'catch ...' is deprecated; please use 'try ... catch ... end' instead.
Compile directive 'nowarn_deprecated_catch' can be used to suppress
warnings in selected modules.
%   72|    case catch base64:decode(Text) of
%     |         ^

    ┌─ src/yamerl_node_binary.erl:
    │
 65 │     case catch base64:decode(Text) of
    │          ╰── Warning: 'catch ...' is deprecated; please use 'try ... catch ... end' instead.
Compile directive 'nowarn_deprecated_catch' can be used to suppress
warnings in selected modules.

    ┌─ src/yamerl_node_binary.erl:
    │
 72 │     case catch base64:decode(Text) of
    │          ╰── Warning: 'catch ...' is deprecated; please use 'try ... catch ... end' instead.
Compile directive 'nowarn_deprecated_catch' can be used to suppress
warnings in selected modules.


/data/postgresql/harness/worktrees/harness_agent_adapter/landing/run-1790039477904-68e1b9de/deps/yamerl/src/yamerl_constr.erl:801:5: Warning: 'catch ...' is deprecated; please use 'try ... catch ... end' instead.
Compile directive 'nowarn_deprecated_catch' can be used to suppress
warnings in selected modules.
%  801|     catch Mod:module_info(),
%     |     ^

     ┌─ src/yamerl_constr.erl:
     │
 801 │      catch Mod:module_info(),
     │      ╰── Warning: 'catch ...' is deprecated; please use 'try ... catch ... end' instead.
Compile directive 'nowarn_deprecated_catch' can be used to suppress
warnings in selected modules.


==> styler
Compiling 17 files (.ex)
Generated styler app
==> erlex
Compiling 2 files (.erl)
Compiling 2 files (.ex)
Generated erlex app
==> sourceror
Compiling 20 files (.ex)
Generated sourceror app
==> json_spec
Compiling 2 files (.ex)
Generated json_spec app
==> descripex
Compiling 6 files (.ex)
Generated descripex app
==> decimal
Compiling 4 files (.ex)
Generated decimal app
==> jason
Compiling 10 files (.ex)
Generated jason app
==> sobelow
Compiling 51 files (.ex)
Generated sobelow app
==> ex_ast
Compiling 36 files (.ex)
Generated ex_ast app
==> yaml_elixir
Compiling 6 files (.ex)
Generated yaml_elixir app
==> mix_audit
Compiling 16 files (.ex)
Generated mix_audit app
==> dialyzer_json
Compiling 4 files (.ex)
     warning: :dialyzer.format_warning/1 is undefined (module :dialyzer is not available or is yet to be defined)
     │
 134 │     :dialyzer.format_warning({:warn, {~c"", 0}, {warning_type, args}})
     │               ~
     │
     └─ lib/dialyzer_json/warning_encoder.ex:134:15: DialyzerJson.WarningEncoder.format_raw_message/2

     warning: :dialyzer.run/1 is undefined (module :dialyzer is not available or is yet to be defined)
     │
 333 │       :dialyzer.run(args)
     │                 ~
     │
     └─ lib/mix/tasks/dialyzer_json.ex:333:17: Mix.Tasks.Dialyzer.Json.run_dialyzer/0

Generated dialyzer_json app
==> libgraph
Compiling 15 files (.ex)
Generated libgraph app
==> doctor
Compiling 17 files (.ex)
    warning: this clause of defp valid_moduledoc?/2 is never used (or it will always fail/warn when invoked)
    │
 96 │   defp valid_moduledoc?(%ModuleReport{is_protocol_implementation: true}, _config), do: true
    │        ~
    │
    └─ lib/reporters/module_explain.ex:96:8: Doctor.Reporters.ModuleExplain.valid_moduledoc?/2

     warning: this clause of defp valid_doc_coverage?/2 is never used (or it will always fail/warn when invoked)
     │
 103 │   defp valid_doc_coverage?(%ModuleReport{is_protocol_implementation: true}, _config), do: true
     │        ~
     │
     └─ lib/reporters/module_explain.ex:103:8: Doctor.Reporters.ModuleExplain.valid_doc_coverage?/2

Generated doctor app
==> dialyxir
Compiling 70 files (.ex)
Generated dialyxir app
==> credo
Compiling 257 files (.ex)
Generated credo app
==> ex_slop
Compiling 45 files (.ex)
Generated ex_slop app
==> ex_dna
Compiling 36 files (.ex)
Generated ex_dna app
==> reach
Compiling 287 files (.ex)
Generated reach app
==> harness_agent_adapter
Compiling 23 files (.ex)
Generated harness_agent_adapter app
{"coverage":{"covered_lines":561,"modules":[{"covered_lines":77,"file":"lib/harness/agent_adapter.ex","module":"Harness.AgentAdapter","percentage":85.56,"uncovered_lines":[97,247,490,491,492,522,531,539,547,577,600,607,614]},{"covered_lines":13,"file":"lib/harness/agent_adapter/antigravity.ex","module":"Harness.AgentAdapter.Antigravity","percentage":92.86,"uncovered_lines":[94]},{"covered_lines":0,"file":"lib/harness/agent_adapter/capabilities.ex","module":"Harness.AgentAdapter.Capabilities","percentage":100.0,"uncovered_lines":[]},{"covered_lines":10,"file":"lib/harness/agent_adapter/claude.ex","module":"Harness.AgentAdapter.Claude","percentage":100.0,"uncovered_lines":[]},{"covered_lines":13,"file":"lib/harness/agent_adapter/codex.ex","module":"Harness.AgentAdapter.Codex","percentage":100.0,"uncovered_lines":[]},{"covered_lines":9,"file":"lib/harness/agent_adapter/cursor.ex","module":"Harness.AgentAdapter.Cursor","percentage":100.0,"uncovered_lines":[]},{"covered_lines":44,"file":"lib/harness/agent_adapter/driver.ex","module":"Harness.AgentAdapter.Driver","percentage":91.67,"uncovered_lines":[1,187,213,230]},{"covered_lines":9,"file":"lib/harness/agent_adapter/grok.ex","module":"Harness.AgentAdapter.Grok","percentage":100.0,"uncovered_lines":[]},{"covered_lines":0,"file":"lib/harness/agent_adapter/invocation.ex","module":"Harness.AgentAdapter.Invocation","percentage":100.0,"uncovered_lines":[]},{"covered_lines":55,"file":"lib/harness/agent_adapter/os_process.ex","module":"Harness.AgentAdapter.OSProcess","percentage":93.22,"uncovered_lines":[136,176,179,193]},{"covered_lines":0,"file":"lib/harness/agent_adapter/outcome.ex","module":"Harness.AgentAdapter.Outcome","percentage":100.0,"uncovered_lines":[]},{"covered_lines":9,"file":"lib/harness/agent_adapter/pi.ex","module":"Harness.AgentAdapter.Pi","percentage":100.0,"uncovered_lines":[]},{"covered_lines":4,"file":"lib/harness/agent_adapter/registry.ex","module":"Harness.AgentAdapter.Registry","percentage":100.0,"uncovered_lines":[]},{"covered_lines":0,"file":"lib/harness/agent_adapter/rule_delivery.ex","module":"Harness.AgentAdapter.RuleDelivery","percentage":100.0,"uncovered_lines":[]},{"covered_lines":76,"file":"lib/harness/agent_adapter/rules_injection.ex","module":"Harness.AgentAdapter.RulesInjection","percentage":91.57,"uncovered_lines":[121,144,189,201,272,281,295]},{"covered_lines":0,"file":"lib/harness/agent_adapter/run.ex","module":"Harness.AgentAdapter.Run","percentage":100.0,"uncovered_lines":[]},{"covered_lines":2,"file":"lib/harness/agent_adapter/testing/conformance_case.ex","module":"Harness.AgentAdapter.Testing.ConformanceCase","percentage":100.0,"uncovered_lines":[]},{"covered_lines":19,"file":"lib/harness/agent_adapter/testing/conformance_case.ex","module":"Harness.AgentAdapter.Testing.ConformanceCase.RuleDelivery","percentage":95.0,"uncovered_lines":[59]},{"covered_lines":100,"file":"lib/harness/agent_adapter/testing/fake_adapter.ex","module":"Harness.AgentAdapter.Testing.FakeAdapter","percentage":100.0,"uncovered_lines":[]},{"covered_lines":3,"file":"lib/harness/agent_adapter/testing/fake_model_adapter.ex","module":"Harness.AgentAdapter.Testing.FakeModelAdapter","percentage":75.0,"uncovered_lines":[18]},{"covered_lines":32,"file":"lib/harness/agent_adapter/testing/git_fixture.ex","module":"Harness.AgentAdapter.Testing.GitFixture","percentage":96.97,"uncovered_lines":[106]},{"covered_lines":4,"file":"lib/harness/agent_adapter/testing/noncompliant_adapter.ex","module":"Harness.AgentAdapter.Testing.NoncompliantAdapter","percentage":80.0,"uncovered_lines":[18]},{"covered_lines":13,"file":"lib/harness/agent_adapter/testing/process_fixture.ex","module":"Harness.AgentAdapter.Testing.ProcessFixture","percentage":92.86,"uncovered_lines":[81]},{"covered_lines":69,"file":"lib/harness/agent_adapter/watchdog.ex","module":"Harness.AgentAdapter.Watchdog","percentage":76.67,"uncovered_lines":[108,141,148,169,172,192,193,194,203,205,208,209,212,213,265,310,316,320,321,322,323]}],"threshold":85.0,"threshold_met":true,"total_lines":616,"total_percentage":91.07},"retry":{"confirmed":1,"flaky":0,"passes":1,"ran":true,"retried":1},"seed":552999,"summary":{"duration_us":2046419,"excluded":7,"failed":1,"flaky":0,"invalid":0,"passed":342,"result":"failed","skipped":0,"total":350},"tests":[{"duration_us":5115,"failures":[{"kind":"error","message":"argument error","stacktrace":[{"app":"erts","arity":1,"file":"nil","function":"port_close","line":"nil","module":":erlang"},{"app":"nil","arity":1,"file":"test/harness/agent_adapter/testing/process_fixture_test.exs","function":"test await_dead/2 returns :ok once the process is gone","line":30,"module":"Harness.AgentAdapter.Testing.ProcessFixtureTest"}]}],"file":"test/harness/agent_adapter/testing/process_fixture_test.exs","line":26,"module":"Harness.AgentAdapter.Testing.ProcessFixtureTest","name":"test await_dead/2 returns :ok once the process is gone","state":"failed","tags":{"test_group":""}}],"version":1}** (exit) 2
    (mix 1.20.2) lib/mix/tasks/cmd.ex:135: Mix.Tasks.Cmd.run/1
    (mix 1.20.2) lib/mix/task.ex:502: anonymous fn/3 in Mix.Task.run_task/5
    (mix 1.20.2) lib/mix/task.ex:576: Mix.Task.run_alias/6
    (mix 1.20.2) lib/mix/cli.ex:129: Mix.CLI.run_task/2
    /home/harness/.asdf/installs/elixir/1.20.2-otp-29/bin/mix:7: (file)
```

## Evidence: mix dialyzer

```text
Finding suitable PLTs
Checking PLT...
[:asn1, :bandit, :circular_buffer, :compiler, :crypto, :decimal, :descripex, :eex, :elixir, :ex_unit, :harness_agent_adapter, :hpax, :jason, :json_spec, :kernel, :logger, :mime, :plug, :plug_crypto, :public_key, :ssl, :stdlib, :telemetry, :thousand_island, :tidewave, :websock, :websock_adapter]
Looking up modules in dialyxir_erlang-29.0.3_elixir-1.20.2_deps-dev.plt
Looking up modules in dialyxir_erlang-29.0.3_elixir-1.20.2.plt
Looking up modules in dialyxir_erlang-29.0.3.plt
Finding applications for dialyxir_erlang-29.0.3.plt
Finding modules for dialyxir_erlang-29.0.3.plt
Creating dialyxir_erlang-29.0.3.plt
Looking up modules in dialyxir_erlang-29.0.3.plt
Removing 3 modules from dialyxir_erlang-29.0.3.plt
Checking 19 modules in dialyxir_erlang-29.0.3.plt
Adding 204 modules to dialyxir_erlang-29.0.3.plt
done in 0m13.92s
Finding applications for dialyxir_erlang-29.0.3_elixir-1.20.2.plt
Finding modules for dialyxir_erlang-29.0.3_elixir-1.20.2.plt
Copying dialyxir_erlang-29.0.3.plt to dialyxir_erlang-29.0.3_elixir-1.20.2.plt
Looking up modules in dialyxir_erlang-29.0.3_elixir-1.20.2.plt
Checking 223 modules in dialyxir_erlang-29.0.3_elixir-1.20.2.plt
Adding 271 modules to dialyxir_erlang-29.0.3_elixir-1.20.2.plt
done in 0m8.72s
Finding applications for dialyxir_erlang-29.0.3_elixir-1.20.2_deps-dev.plt
Finding modules for dialyxir_erlang-29.0.3_elixir-1.20.2_deps-dev.plt
Copying dialyxir_erlang-29.0.3_elixir-1.20.2.plt to dialyxir_erlang-29.0.3_elixir-1.20.2_deps-dev.plt
Looking up modules in dialyxir_erlang-29.0.3_elixir-1.20.2_deps-dev.plt
Checking 494 modules in dialyxir_erlang-29.0.3_elixir-1.20.2_deps-dev.plt
Adding 491 modules to dialyxir_erlang-29.0.3_elixir-1.20.2_deps-dev.plt
done in 0m30.06s
ignore_warnings: .dialyzer_ignore.exs

Starting Dialyzer
[
  check_plt: false,
  init_plt: ~c"priv/plts/dialyxir_erlang-29.0.3_elixir-1.20.2_deps-dev.plt",
  files: [~c"/data/postgresql/harness/worktrees/harness_agent_adapter/landing/run-1790039477904-68e1b9de/_build/dev/lib/harness_agent_adapter/ebin/Elixir.Harness.AgentAdapter.Antigravity.beam",
   ~c"/data/postgresql/harness/worktrees/harness_agent_adapter/landing/run-1790039477904-68e1b9de/_build/dev/lib/harness_agent_adapter/ebin/Elixir.Harness.AgentAdapter.Capabilities.beam",
   ~c"/data/postgresql/harness/worktrees/harness_agent_adapter/landing/run-1790039477904-68e1b9de/_build/dev/lib/harness_agent_adapter/ebin/Elixir.Harness.AgentAdapter.Claude.beam",
   ~c"/data/postgresql/harness/worktrees/harness_agent_adapter/landing/run-1790039477904-68e1b9de/_build/dev/lib/harness_agent_adapter/ebin/Elixir.Harness.AgentAdapter.Codex.beam",
   ~c"/data/postgresql/harness/worktrees/harness_agent_adapter/landing/run-1790039477904-68e1b9de/_build/dev/lib/harness_agent_adapter/ebin/Elixir.Harness.AgentAdapter.Cursor.beam",
   ...],
  ...
]
Total errors: 0, Skipped: 0, Unnecessary Skips: 0
done in 0m2.06s
done (passed successfully)
```

## Evidence: mix agents.check (integrated revision)

```text
STALE: ./AGENTS.md has drifted from CLAUDE.md (+@-imports) — run sync-agents-md.sh
** (Mix) AGENTS.md freshness check failed (/home/harness/.claude/plugins/marketplaces/zenhive/scripts/sync-agents-md.sh exited 1)
```

## Evidence: Isolated pre-fix test

```text
{"version":1,"seed":809297,"summary":{"invalid":0,"total":5,"failed":0,"result":"passed","excluded":4,"skipped":0,"passed":1,"duration_us":26082},"tests":[]}
```

## Evidence: Generator

```text
Wrote ./AGENTS.md
```

## Evidence: Focused repair tests

```text
{"seed":638684,"summary":{"duration_us":122529,"excluded":0,"failed":0,"invalid":0,"passed":15,"result":"passed","skipped":0,"total":15},"tests":[],"version":1}
```

## Evidence: Freshness after repair

```text
OK: ./AGENTS.md is up to date
```
