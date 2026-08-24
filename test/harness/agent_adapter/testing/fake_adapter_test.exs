defmodule Harness.AgentAdapter.Testing.FakeAdapterTest do
  use ExUnit.Case, async: true

  alias Harness.AgentAdapter.Invocation
  alias Harness.AgentAdapter.Testing.FakeAdapter
  alias Harness.AgentAdapter.Testing.FakeModelAdapter

  # Every branch the fixture's command table declares, in the `adapter_opts`
  # shape a caller selects it with. A branch missing from this list is a branch
  # nothing proves is spawnable.
  @branches [
    :echo,
    {:echo, "verbatim argv"},
    :stdin_eof,
    :write,
    :capture_model,
    :capture_github_env,
    :capture_rmap_path,
    :snapshot_worktree,
    :write_then_hang,
    :break_git,
    :detach_head,
    :move_cwd_aside,
    {:write_then_wait_for_file, "/tmp/harness-gate"},
    {:write_status_by_task, ["red-1"]},
    {:write_and_pollute_checkout, "/tmp/harness-checkout"},
    {:write_sibling_and_move_cwd, "/tmp/harness-sibling"},
    :sleep,
    :exit_code,
    :burst,
    :flood,
    :missing,
    :repair_noop,
    :recovery_clean,
    :recovery_dead,
    {:audit, "abc1234"},
    {:audit_capture_prompt, "abc1234"},
    {:audit_capture_rmap_path, "abc1234"},
    {:audit_cold_check_by_warm_marker, "abc1234"},
    {:audit_cold_check_green, "abc1234"},
    {:review, "approve"},
    {:review, "reject"},
    {:review_with_fix, "approve"},
    {:review_with_proposals, "approve"},
    {:review_capture_prompt, "approve"},
    {:review_capture_model, "approve"},
    {:review_capture_rmap_path, "approve"},
    {:review_capture_reprompt, "approve"},
    {:review_miss_then, "approve"},
    {:review_miss_then_sleep, "token"},
    {:review_malformed_then, "approve"},
    {:review_count_then, :miss},
    {:review_count_then, :malformed},
    {:review_fix_miss_then, "approve"},
    {:review_by_task, ["7"]},
    {:review_if_file, "/tmp/harness-marker"},
    {:review_verdict_by_file, "/tmp/harness-marker"},
    :review_malformed
  ]

  defp invocation(attrs \\ []) do
    struct!(
      %Invocation{prompt: "fixture prompt", cwd: System.tmp_dir!(), log_tag: "fixture"},
      attrs
    )
  end

  describe "build_command/1 — the branch table" do
    for branch <- @branches do
      test "#{inspect(branch)} resolves to a spawnable command" do
        branch = unquote(Macro.escape(branch))

        assert {:ok, {executable, argv, env}} =
                 FakeAdapter.build_command(invocation(adapter_opts: [command: branch]))

        assert is_binary(executable) and executable != ""
        assert Enum.all?(argv, &is_binary/1)
        assert env == []
      end
    end

    test "defaults to :echo when adapter_opts names no branch" do
      assert {:ok, {"/bin/echo", ["harness-test"], []}} = FakeAdapter.build_command(invocation())
    end

    test "passes {:echo, text} through as one argv element, unsplit" do
      assert {:ok, {"/bin/echo", ["two words; and a semicolon"], []}} =
               FakeAdapter.build_command(invocation(adapter_opts: [command: {:echo, "two words; and a semicolon"}]))
    end
  end

  describe "build_command/1 — branch selection" do
    test "prefers :recovery_command over :command on a -recovery log tag" do
      opts = [command: :write, recovery_command: :recovery_dead]

      assert {:ok, {"/bin/sh", ["-c", recovery_script | _], []}} =
               FakeAdapter.build_command(invocation(log_tag: "run-7-recovery", adapter_opts: opts))

      assert {:ok, {"/bin/sh", ["-c", implement_script], []}} =
               FakeAdapter.build_command(invocation(log_tag: "run-7", adapter_opts: opts))

      assert recovery_script =~ ".harness/recovery.json"
      assert implement_script =~ "agent_output.txt"
    end

    test "falls back to :command on a -recovery log tag with no recovery branch" do
      assert {:ok, {"/bin/sh", ["-c", script], []}} =
               FakeAdapter.build_command(invocation(log_tag: "run-7-recovery", adapter_opts: [command: :write]))

      assert script =~ "agent_output.txt"
    end

    test "{:review_by_task, ids} rejects a listed id and approves the rest" do
      reject = review_verdict_for("7", ["7"])
      approve = review_verdict_for("8", ["7"])

      assert reject["verdict"] == "reject"
      assert approve["verdict"] == "approve"
    end

    test ":operator_steer forwards the steer prompt only on a resumed run" do
      opts = [command: :operator_steer]

      assert {:ok, {"/bin/sh", ["-c", _script, "harness-fake", "steer me"], []}} =
               FakeAdapter.build_command(invocation(session: :resume, prompt: "steer me", adapter_opts: opts))

      assert {:ok, {"/bin/sh", ["-c", first_attempt], []}} =
               FakeAdapter.build_command(invocation(session: nil, adapter_opts: opts))

      assert first_attempt =~ "attempt.txt"
    end

    test ":capture_model passes the pinned model as a positional parameter" do
      assert {:ok, {"/bin/sh", ["-c", _script, "harness-fake", "some-model"], []}} =
               FakeAdapter.build_command(invocation(model: "some-model", adapter_opts: [command: :capture_model]))

      assert {:ok, {"/bin/sh", ["-c", _script, "harness-fake", ""], []}} =
               FakeAdapter.build_command(invocation(adapter_opts: [command: :capture_model]))
    end
  end

  describe "build_command/1 — permission modes and env" do
    test "accepts every declared permission mode" do
      for mode <- FakeAdapter.capabilities().permission_modes do
        assert {:ok, _command} = FakeAdapter.build_command(invocation(permission_mode: mode))
      end
    end

    test "rejects an undeclared permission mode instead of falling back" do
      assert {:error, {:unsupported_permission_mode, :nope}} =
               FakeAdapter.build_command(invocation(permission_mode: :nope))
    end

    test "threads caller env additions and scrubs into the returned env" do
      assert {:ok, {_executable, _argv, env}} =
               FakeAdapter.build_command(invocation(env: %{"SET" => "yes", "SCRUB" => false}))

      assert {"SET", "yes"} in env
      assert {"SCRUB", false} in env
    end
  end

  describe "capability declarations" do
    test "FakeAdapter is honestly model-incapable and injects no rules" do
      assert FakeAdapter.capabilities().model_families == []
      assert FakeAdapter.capabilities().session_resume
      assert FakeAdapter.rule_channel() == :none
    end

    test "FakeModelAdapter is the model-capable twin sharing the command table" do
      assert FakeModelAdapter.capabilities().model_families == :any
      assert FakeModelAdapter.rule_channel() == :none

      inv = invocation(model: "pinned-model", adapter_opts: [command: :capture_model])

      assert FakeModelAdapter.build_command(inv) == FakeAdapter.build_command(inv)
    end
  end

  describe "verdict payload helpers" do
    test "review_report/1 and review_ratings/0 are what the artifact carries" do
      verdict = review_verdict_for("1", [])

      assert verdict["report"] == FakeAdapter.review_report("approve")
      assert verdict["ratings"] == FakeAdapter.review_ratings()
    end
  end

  # Digs the verdict JSON out of the argv {:review_by_task, _} builds for a
  # reviewer invocation whose log tag is "<item id>-review".
  defp review_verdict_for(item_id, reject_ids) do
    assert {:ok, {"/bin/sh", ["-c", _script, "harness-fake", json], []}} =
             FakeAdapter.build_command(
               invocation(
                 log_tag: "#{item_id}-review",
                 adapter_opts: [command: {:review_by_task, reject_ids}]
               )
             )

    Jason.decode!(json)
  end
end
