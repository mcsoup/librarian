defmodule Librarian.Mixfile do
  use Mix.Project

  @semver_regex ~r/^v?(?:0|[1-9]\d*)\.(?:0|[1-9]\d*)\.(?:0|[1-9]\d*)(?:-[\da-z\-]+(?:\.[\da-z\-]+)*)?(?:\+[\da-z\-]+(?:\.[\da-z\-]+)*)?$/i

  defmacro git_version do
    quote do
      case System.cmd("git", ["describe", "--tags"], stderr_to_stdout: true) do
        {desc, 0} ->
          ver = desc |> String.trim |> String.replace_prefix("v", "")
          if String.match?(ver, @semver_regex) do
            ver
          else
            "0.0.1-bad-tag"
          end
        {_, _} -> raise "Not able to retrieve git description for versioning project"
      end
    end
  end

  def project do
    [app: :librarian,
     version: git_version,
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     elixirc_paths: elixirc_paths(Mix.env),
     deps: deps()]
  end

  def application do
    [applications: [:con_cache, :logger, :slack, :httpoison],
     mod: {Librarian, []}]
  end

  defp deps do
    [
      {:con_cache, "~> 0.11.1"},
      {:slack, "~> 0.12.0"},
      {:httpoison, "~> 0.9"},
      {:combine, "~> 0.9"},
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]
end
