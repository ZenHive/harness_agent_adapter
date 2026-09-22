defmodule Harness.AgentAdapter.Testing.ProcessFixtureTest do
  use ExUnit.Case, async: true

  alias Harness.AgentAdapter.OSProcess
  alias Harness.AgentAdapter.Testing.ProcessFixture

  describe "spawn_sleep/0" do
    test "opens a live port with a reachable OS process behind it" do
      {port, os_pid} = ProcessFixture.spawn_sleep()

      assert is_port(port)
      assert is_integer(os_pid)
      assert Port.info(port)
      assert {_output, 0} = System.cmd("kill", ["-0", Integer.to_string(os_pid)], stderr_to_stdout: true)
    end

    test "hands out a distinct process per call" do
      {_port_a, pid_a} = ProcessFixture.spawn_sleep()
      {_port_b, pid_b} = ProcessFixture.spawn_sleep()

      assert pid_a != pid_b
    end
  end

  describe "await_dead/2" do
    test "returns :ok once the process is gone" do
      {port, os_pid} = ProcessFixture.spawn_sleep()
      monitor = Port.monitor(port)

      OSProcess.sigkill(os_pid)
      assert_receive {:DOWN, ^monitor, :port, ^port, :normal}, 1_000

      assert ProcessFixture.await_dead(os_pid) == :ok
    end

    test "polls while the process is still alive rather than reading once" do
      {_port, os_pid} = ProcessFixture.spawn_sleep()

      # Killed only after await_dead is already polling: a single read would
      # see a live process, so passing here proves the retry loop runs.
      spawn(fn ->
        Process.sleep(60)
        OSProcess.sigkill(os_pid)
      end)

      assert ProcessFixture.await_dead(os_pid) == :ok
    end

    test "flunks when the retry budget runs out on a still-live process" do
      {_port, os_pid} = ProcessFixture.spawn_sleep()

      assert_raise ExUnit.AssertionError, ~r/OS process #{os_pid} was not killed/, fn ->
        ProcessFixture.await_dead(os_pid, 0)
      end
    end
  end
end
