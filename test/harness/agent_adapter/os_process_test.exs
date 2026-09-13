defmodule Harness.AgentAdapter.OSProcessTest do
  use ExUnit.Case, async: false

  alias Harness.AgentAdapter.OSProcess
  alias Harness.AgentAdapter.Run
  alias Harness.AgentAdapter.Testing.ProcessFixture

  @grace_ms 50

  setup do
    previous = Application.get_env(:harness_agent_adapter, :run, [])

    Application.put_env(
      :harness_agent_adapter,
      :run,
      Keyword.put(previous, :terminate_grace_ms, @grace_ms)
    )

    on_exit(fn -> Application.put_env(:harness_agent_adapter, :run, previous) end)
    :ok
  end

  defp run_for(port, os_pid) do
    %Run{
      ref: make_ref(),
      adapter: __MODULE__,
      port: port,
      os_pid: os_pid,
      started_at: System.monotonic_time()
    }
  end

  describe "os_pid/1" do
    test "returns the OS pid behind a live port" do
      {port, os_pid} = ProcessFixture.spawn_sleep()

      assert is_integer(os_pid)
      assert OSProcess.os_pid(port) == os_pid
    end

    test "returns nil once the port has closed" do
      {port, _os_pid} = ProcessFixture.spawn_sleep()
      OSProcess.close(port)

      assert OSProcess.os_pid(port) == nil
    end
  end

  describe "close/1" do
    test "closes the port and is idempotent" do
      {port, _os_pid} = ProcessFixture.spawn_sleep()

      assert OSProcess.close(port) == :ok
      refute Port.info(port)

      # Idempotent — the killed OS process can close the port first.
      assert OSProcess.close(port) == :ok
    end
  end

  describe "flush/1" do
    test "drains queued port messages from the mailbox" do
      port =
        Port.open({:spawn_executable, "/bin/echo"}, [
          :binary,
          :exit_status,
          :hide,
          {:args, ["hi"]}
        ])

      # Let the data + exit_status messages land in the mailbox.
      Process.sleep(50)

      assert OSProcess.flush(port) == :ok
      refute_received {^port, _message}
    end
  end

  describe "kill/1" do
    test "terminates the OS process, closes the port, and is idempotent" do
      {port, os_pid} = ProcessFixture.spawn_sleep()
      run = run_for(port, os_pid)

      assert OSProcess.kill(run) == :ok
      refute Port.info(port)
      assert ProcessFixture.await_dead(os_pid) == :ok

      # Idempotent — safe on a run that has already ended.
      assert OSProcess.kill(run) == :ok
    end

    test "gracefully escalates and quiesces a TERM-trapping descendant tree" do
      log = Path.join(System.tmp_dir!(), "haa-terminate-#{System.unique_integer([:positive])}")
      on_exit(fn -> File.rm(log) end)

      child_script = """
      trap 'echo child-term >> #{log}' TERM
      sh -c "trap 'echo leaf-term >> #{log}' TERM; while :; do :; done" &
      wait
      """

      root_script = """
      trap 'echo root-term >> #{log}' TERM
      sh -c "$1" &
      wait
      """

      port =
        Port.open({:spawn_executable, "/bin/sh"}, [
          :binary,
          :exit_status,
          :hide,
          {:args, ["-c", root_script, "haa-child", child_script]}
        ])

      root = OSProcess.os_pid(port)
      descendants = await_descendants(root, 2)
      run = run_for(port, root)
      started = System.monotonic_time(:millisecond)
      assert OSProcess.kill(run) == :ok
      elapsed = System.monotonic_time(:millisecond) - started

      # TERM-trapping processes survive SIGTERM, so the grace window must elapse
      # before SIGKILL. Immediate SIGKILL would return in a handful of ms.
      assert elapsed >= @grace_ms - 10

      assert File.read!(log) =~ "root-term"
      assert File.read!(log) =~ "child-term"
      assert File.read!(log) =~ "leaf-term"
      refute_os_alive(root)
      for pid <- descendants, do: refute_os_alive(pid)
    end
  end

  describe "kill_tree/1" do
    test "is idempotent for nil and dead pids" do
      assert OSProcess.kill_tree(nil) == :ok
      {_port, os_pid} = ProcessFixture.spawn_sleep()
      assert OSProcess.kill_tree(os_pid) == :ok
      assert OSProcess.kill_tree(os_pid) == :ok
    end

    test "reaps a TERM-ignoring grandchild before returning" do
      file = grandchild_file()

      child_script = """
      trap '' TERM
      sh -c 'echo $$ > #{file}; trap "" TERM; while :; do :; done' &
      wait
      """

      root_script = """
      sh -c "$1" &
      wait
      """

      port =
        Port.open({:spawn_executable, "/bin/sh"}, [
          :binary,
          :exit_status,
          :hide,
          {:args, ["-c", root_script, "haa-tree", child_script]}
        ])

      root = OSProcess.os_pid(port)
      grandchild = await_pid_file(file)
      on_exit(fn -> OSProcess.kill_tree(root) end)

      assert OSProcess.kill_tree(root) == :ok
      OSProcess.close(port)
      refute_os_alive(root)
      refute_os_alive(grandchild)
    end
  end

  defp grandchild_file do
    path = Path.join(System.tmp_dir!(), "haa-tree-#{System.unique_integer([:positive])}.pid")
    on_exit(fn -> reap_pid_file(path) end)
    path
  end

  defp reap_pid_file(path) do
    with {:ok, contents} <- File.read(path),
         {pid, ""} <- Integer.parse(String.trim(contents)) do
      System.cmd("kill", ["-KILL", Integer.to_string(pid)], stderr_to_stdout: true)
    else
      _missing -> :ok
    end

    File.rm(path)
  end

  defp await_pid_file(path, tries \\ 80)
  defp await_pid_file(path, 0), do: flunk("grandchild pid file #{path} never appeared")

  defp await_pid_file(path, tries) do
    case File.read(path) do
      {:ok, contents} ->
        case Integer.parse(String.trim(contents)) do
          {pid, ""} -> pid
          _other -> sleep_and_retry(path, tries)
        end

      {:error, _reason} ->
        sleep_and_retry(path, tries)
    end
  end

  defp sleep_and_retry(path, tries) do
    Process.sleep(10)
    await_pid_file(path, tries - 1)
  end

  defp await_descendants(root, count, tries \\ 80)
  defp await_descendants(root, _count, 0), do: flunk("descendants of #{root} never appeared")

  defp await_descendants(root, count, tries) do
    {output, 0} = System.cmd("ps", ["-axo", "pid=,ppid="], stderr_to_stdout: true)

    table =
      Map.new(String.split(output, "\n", trim: true), fn line ->
        [pid, ppid] = String.split(line)
        {String.to_integer(pid), String.to_integer(ppid)}
      end)

    descendants = Enum.filter(Map.keys(table), &descendant?(&1, root, table))

    if length(descendants) < count do
      Process.sleep(10)
      await_descendants(root, count, tries - 1)
    else
      descendants
    end
  end

  defp descendant?(pid, root, table) do
    case Map.get(table, pid) do
      ^root -> true
      nil -> false
      0 -> false
      parent -> descendant?(parent, root, table)
    end
  end

  defp refute_os_alive(pid) do
    {_output, code} = System.cmd("kill", ["-0", Integer.to_string(pid)], stderr_to_stdout: true)
    assert code != 0, "expected pid #{pid} to be dead once kill_tree/1 returned"
  end
end
