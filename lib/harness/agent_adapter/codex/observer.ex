defmodule Harness.AgentAdapter.Codex.Observer do
  @moduledoc "Explicit read-only Codex execution, isolated from coding configuration."

  @doc "Builds a fresh observation command; cwd must be a caller-owned empty directory."
  @spec command(String.t(), String.t(), String.t()) :: {:ok, {String.t(), [String.t()], list()}} | {:error, atom()}
  def command(cwd, model, prompt) when is_binary(cwd) and is_binary(model) and is_binary(prompt) and model != "" do
    {:ok,
     {"codex",
      [
        "exec",
        "--cd",
        cwd,
        "--json",
        "--output-schema",
        Path.join(cwd, "response.schema.json"),
        "--ignore-user-config",
        "--ignore-rules",
        "--ephemeral",
        "--skip-git-repo-check",
        "--sandbox",
        "read-only",
        "-c",
        ~s(approval_policy="never"),
        "-c",
        "project_doc_max_bytes=0",
        "-c",
        "features.shell_tool=false",
        "-c",
        "features.hooks=false",
        "-c",
        "features.apps=false",
        "-c",
        "features.skills=false",
        "-c",
        "features.multi_agent=false",
        "-c",
        ~s(web_search="disabled"),
        "-c",
        "mcp_servers={}",
        "--model",
        model,
        "--",
        prompt
      ], []}}
  end

  def command(_, _, _), do: {:error, :invalid_observer_invocation}
end
