defmodule Harness.AgentAdapter.Testing.GitFixtureTest do
  use ExUnit.Case, async: true

  alias Harness.AgentAdapter.Testing.GitFixture

  describe "init_repo/1" do
    test "creates a git repo on main with one commit and a local identity" do
      repo = GitFixture.init_repo()

      assert File.dir?(Path.join(repo, ".git"))
      assert File.read!(Path.join(repo, "README.md")) == "harness git fixture\n"
      assert String.trim(GitFixture.git!(repo, ["rev-parse", "--abbrev-ref", "HEAD"])) == "main"
      assert String.trim(GitFixture.git!(repo, ["config", "user.email"])) == "harness-test@example.com"
      assert GitFixture.git!(repo, ["status", "--porcelain"]) == ""
    end

    test "hands out a distinct path per call, so parallel fixtures cannot collide" do
      assert GitFixture.init_repo() != GitFixture.init_repo()
    end

    test "labels the tmp directory with :name without giving up uniqueness" do
      first = GitFixture.init_repo(name: "labelled")
      second = GitFixture.init_repo(name: "labelled")

      assert Path.basename(first) =~ ~r/^harness-labelled-/
      assert first != second
    end
  end

  describe "init_with_origin/1" do
    test "pushes main to a bare origin the clone can fetch from" do
      %{origin: origin, repo: repo} = GitFixture.init_with_origin()

      assert String.trim(GitFixture.git!(repo, ["remote", "get-url", "origin"])) == origin

      assert String.trim(GitFixture.git!(repo, ["rev-parse", "HEAD"])) ==
               String.trim(GitFixture.git!(repo, ["rev-parse", "origin/main"]))

      # A real remote, not a stub: a second commit ff-pushes and origin advances.
      File.write!(Path.join(repo, "second.txt"), "second\n")
      GitFixture.git!(repo, ["add", "second.txt"])
      GitFixture.git!(repo, ["commit", "-q", "-m", "second"])
      GitFixture.git!(repo, ["push", "-q", "origin", "main"])

      assert String.trim(GitFixture.git!(repo, ["rev-parse", "HEAD"])) ==
               String.trim(GitFixture.git!(origin, ["rev-parse", "main"]))
    end
  end

  describe "tmp_base/1" do
    test "reserves a unique, not-yet-created path under the system tmp dir" do
      base = GitFixture.tmp_base()

      refute File.exists?(base)
      assert Path.dirname(base) == Path.expand(System.tmp_dir!())
      assert base != GitFixture.tmp_base()
    end

    test "hands back a path a caller can create and then own" do
      base = GitFixture.tmp_base(name: "scratch")

      File.mkdir_p!(base)

      assert File.ls!(base) == []
      assert Path.basename(base) =~ ~r/^harness-scratch-/
    end
  end

  describe "git!/2" do
    test "returns the command's output on success" do
      repo = GitFixture.init_repo()

      assert GitFixture.git!(repo, ["log", "--oneline"]) =~ "init"
    end

    test "raises with the command and its output on a non-zero exit" do
      repo = GitFixture.init_repo()

      assert_raise RuntimeError, ~r/git rev-parse --verify does-not-exist failed \(\d+\)/, fn ->
        GitFixture.git!(repo, ["rev-parse", "--verify", "does-not-exist"])
      end
    end
  end
end
