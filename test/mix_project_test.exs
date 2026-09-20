defmodule Harness.AgentAdapter.MixProjectTest do
  use ExUnit.Case, async: true

  import ExUnit.CaptureIO

  alias Harness.AgentAdapter.MixProject

  # Before (origin/main):
  #   check.dispatch = format, compile, credo, doctor, sobelow
  #   ci             = format, compile, credo, doctor, ex_dna, reach, sobelow,
  #                    test.json --cover --cover-threshold 85, dialyzer
  #   precommit.full = ci, agents.check
  # After: dispatch is format + compile only; ci depends on check.dispatch and
  # keeps every former QA step (including coverage threshold and sobelow --exit).

  describe "alias graph" do
    test "check.dispatch is format and compile only" do
      assert expand(:"check.dispatch") == [
               "format --check-formatted",
               "compile --warnings-as-errors"
             ]
    end

    test "check.dispatch does not run full-project analyzers or the suite" do
      dispatch = expand(:"check.dispatch")

      for needle <- [
            "credo",
            "doctor",
            "sobelow",
            "dialyzer",
            "reach",
            "ex_dna",
            "test.json",
            "--cover",
            "agents.check"
          ] do
        refute Enum.any?(dispatch, &String.contains?(&1, needle)),
               "check.dispatch must not include #{needle}: #{inspect(dispatch)}"
      end
    end

    test "ci depends on check.dispatch and retains every full-QA step" do
      assert hd(alias_steps(:ci)) == "check.dispatch"

      assert expand(:ci) == [
               "format --check-formatted",
               "compile --warnings-as-errors",
               "credo --strict --ignore TagTODO,TagFIXME",
               "doctor --raise",
               "ex_dna --max-clones 0",
               "reach.check --arch --smells",
               "sobelow --skip --exit low",
               "cmd env MIX_ENV=test mix test.json --cover --cover-threshold 85 --exclude integration",
               "dialyzer"
             ]
    end

    test "precommit.full is ci plus the AGENTS.md freshness gate" do
      assert alias_steps(:"precommit.full") == ["ci", "agents.check"]
      assert expand(:"precommit.full") == expand(:ci) ++ expand(:"agents.check")
    end
  end

  describe "sync-agents-md lookup" do
    test "search order is operator checkout, then Claude marketplace, then grok cache" do
      assert MixProject.sync_agents_md_search_locations() == [
               "~/_DATA/code/claude-marketplace/scripts/sync-agents-md.sh",
               "~/.claude/plugins/marketplaces/zenhive/scripts/sync-agents-md.sh",
               "~/.grok/marketplace-cache/*/scripts/sync-agents-md.sh"
             ]
    end

    test "candidates start with the operator checkout, then the zenhive plugin copy" do
      [operator, zenhive | rest] = MixProject.sync_agents_md_candidates()

      assert operator ==
               Path.expand("~/_DATA/code/claude-marketplace/scripts/sync-agents-md.sh")

      assert zenhive ==
               Path.expand("~/.claude/plugins/marketplaces/zenhive/scripts/sync-agents-md.sh")

      assert Enum.all?(rest, &String.contains?(&1, "/.grok/marketplace-cache/"))
      assert Enum.all?(rest, &String.ends_with?(&1, "/scripts/sync-agents-md.sh"))
    end

    test "runs the first existing executable and does not skip" do
      winner = fixture_script!("echo ran:$1")
      later = fixture_script!("echo later; exit 1")

      output =
        capture_io(fn ->
          assert :ok =
                   MixProject.agents_check(
                     ["--check"],
                     ["/absent/operator/sync-agents-md.sh", winner, later]
                   )
        end)

      assert output =~ "ran:--check"
      refute output =~ "[skip] AGENTS.md freshness check"
      refute output =~ "later"
    end

    test "skips loudly and returns success when no copy exists" do
      looked_in = [
        "/missing/operator/sync-agents-md.sh",
        "/missing/zenhive/sync-agents-md.sh"
      ]

      output =
        capture_io(fn ->
          assert :ok = MixProject.agents_check(["--check"], looked_in, looked_in)
        end)

      assert output =~ "[skip] AGENTS.md freshness check"
      assert output =~ "/missing/operator/sync-agents-md.sh"
      assert output =~ "not found"
    end

    test "a failing script (stale AGENTS.md) fails the mix task" do
      script = fixture_script!("echo STALE: ./AGENTS.md has drifted from CLAUDE.md; exit 1")

      error =
        assert_raise Mix.Error, fn ->
          capture_io(fn -> MixProject.agents_check(["--check"], [script]) end)
        end

      assert Exception.message(error) =~ "AGENTS.md freshness check failed"
      assert Exception.message(error) =~ "exited 1"
    end
  end

  describe "CLAUDE.md alias inventory" do
    test "imports verification-policy and names the slim dispatch vs full QA aliases" do
      claude = File.read!("CLAUDE.md")

      assert claude =~ "@~/.claude/includes/verification-policy.md"
      assert claude =~ "`mix check.dispatch`"
      assert claude =~ "`mix ci`"
      assert claude =~ "`mix precommit.full`"
      assert claude =~ "format + compile"
      refute claude =~ "## Verification scope"
    end
  end

  defp alias_steps(name) do
    Mix.Project.config()
    |> Keyword.fetch!(:aliases)
    |> Keyword.fetch!(name)
  end

  defp expand(name) when is_atom(name) do
    Enum.flat_map(alias_steps(name), &expand_step/1)
  end

  defp expand_step(step) when is_binary(step) do
    aliases = Mix.Project.config()[:aliases]
    key = String.to_atom(step)

    case Keyword.fetch(aliases, key) do
      {:ok, nested} -> Enum.flat_map(nested, &expand_step/1)
      :error -> [step]
    end
  end

  defp expand_step(fun) when is_function(fun), do: [fun]

  defp fixture_script!(body) do
    path = Path.join(System.tmp_dir!(), "sync-agents-md-#{System.unique_integer([:positive])}.sh")
    File.write!(path, "#!/bin/sh\n#{body}\n")
    File.chmod!(path, 0o700)
    on_exit(fn -> File.rm(path) end)
    path
  end
end
