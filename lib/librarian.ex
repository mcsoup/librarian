defmodule Librarian do
  use Application
  use Slack

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(ConCache, [[], [name: Librarian.Library]], id: :library),
      worker(ConCache, [[], [name: Librarian.Admins]],  id: :admin)
    ]

    opts = [strategy: :one_for_one, name: Librarian.Supervisor]
    Supervisor.start_link(children, opts)
    initialize_caches
    Slack.Bot.start_link(Librarian.Robot, [], token)
  end

  def initialize_caches do
    case Mix.env do
      :test -> nil
      _ ->
        Librarian.Library.initialize
        Librarian.Admins.initialize
    end
  end

  def token, do: System.get_env("SLACK_BOT_TOKEN")

  def version do
    {:ok, vsn} = :application.get_key(:librarian, :vsn)
    List.to_string(vsn)
  end

end
