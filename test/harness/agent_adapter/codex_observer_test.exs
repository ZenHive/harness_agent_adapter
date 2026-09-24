defmodule Harness.AgentAdapter.Codex.ObserverTest do
  use ExUnit.Case, async: true

  alias Harness.AgentAdapter.Codex.Observer

  test "observation is explicit and cannot inherit autonomous permissions or resume" do
    assert {:ok, {"codex", argv, []}} = Observer.command("/tmp/observer", "selected-model", "evidence")
    assert ["exec", "--cd", "/tmp/observer" | _] = argv
    assert argv |> Enum.chunk_every(2, 1, :discard) |> Enum.member?(["--sandbox", "read-only"])
    assert argv |> Enum.chunk_every(2, 1, :discard) |> Enum.member?(["--model", "selected-model"])

    for option <- ["--ignore-user-config", "--ignore-rules", "--ephemeral", "mcp_servers={}", "features.hooks=false"],
        do: assert(option in argv)

    refute "--dangerously-bypass-approvals-and-sandbox" in argv
    refute "resume" in argv
    assert {:error, :invalid_observer_invocation} = Observer.command("/tmp/observer", nil, "evidence")
    assert {:error, :invalid_observer_invocation} = Observer.command("/tmp/observer", "", "evidence")
  end
end
