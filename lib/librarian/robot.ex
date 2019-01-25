defmodule Librarian.Robot do
  @moduledoc """

  Responsible for delegating messages addressed to the librarian to the
  appropriate responder.

  """

  use Slack
  use Combine
  require Logger

  defmodule State do
    defstruct [:msg_parser]
  end

  @doc """
  Handle connecting to slack.

  Returns `{:ok, unchanged_state}`
  """
  def handle_connect(slack, _state) do
    Logger.info "Connected as #{slack.me.name} (#{slack.me.id})"
    {:ok, %State{msg_parser: build_parser(slack.me)}}
  end

  @doc """
  Handle slack events.

  We only care about messages so just black hole the rest.

  Returns `{:ok, unchanged_state}`
  """
  def handle_event(message = %{type: "message", text: msg_txt}, slack, state = %State{msg_parser: parser}) do
    Logger.debug "handling #{msg_txt}"

    case Combine.parse(msg_txt, parser) do
      {:error, reasons} ->
        Logger.debug "ignoring because #{inspect(reasons)}"

      [_, command, args]->
        lookup_handler(command)
        |> execute(args, message.user, slack)
        |> send_message(message.channel, slack)

    end

   {:ok, state}
  end
  def handle_event(_, _, state), do: {:ok, state}

  @doc """
  Handle messages in mail box. This should never get called.

  Returns `{:ok, unchanged_state}`
  """
  def handle_info(_, _, state), do: {:ok, state}

  @doc """
  Returns list of responders.
  """
  def responders do
    [
      Librarian.Responders.Add,
      Librarian.Responders.Checkout,
      Librarian.Responders.Inventory,
      Librarian.Responders.Rename,
      Librarian.Responders.Remove,
      Librarian.Responders.Return,
      Librarian.Responders.Help,
    ]
  end

  defp lookup_handler(cmd_name) do
    responders
    |> Enum.find(Librarian.Responders.Help, &(&1.aliases |> Enum.member?(cmd_name)))
    |> (fn responder -> Logger.debug "found handler #{responder}"; responder end).()
  end

  defp execute(handler, args, requester, slack) do
    handler.call(args, requester, slack)
  end

  defp build_parser(my_info) do
    ignore(whitespace)
    |> salutation(my_info)
    |> ignore(whitespace)
    |> label(word, "command")
    |> ignore(whitespace)
    |> label(word_of(~r/.*/), "arguments")
  end

  defp at_userid(%{id: uid}) do
    string("<@#{uid}>")
  end

  defp username(%{name: username}) do
    string(username)
  end

  defp whitespace do
    many(either(space, tab))
  end

  defp salutation(parser, my_info) do
    parser
    |> either(at_userid(my_info),
              username(my_info))
  end
end
