defmodule Librarian.Responders.Help do
  @moduledoc """
  Display help message. This is also the fall back for unintelligible messages.
  """

  @doc """
  Returns string describing how to use this command.
  """
  def usage do
    "`help` : show this help message"
  end


  @doc """
  Returns list of aliases for this command
  """
  def aliases, do: ~w(help)

  @doc """
    Returns help message for the librarian.
  """
  def call(_args, _requester,  %{me: me}) do
    usage_msg(me)
  end

  defp usage_msg(my_info) do
    "To use #{my_info.name} type `@#{my_info.name} COMMAND` ex: `@#{my_info.name} checkout foobar`.\n Avaliable Commands:\n"
    <> command_usages
    <> "\n\n"
    <> version_info
  end

  defp command_usages do
    (Librarian.Robot.responders)
    |> Enum.map(&(&1.usage))
    |> Enum.join("\n")
  end

  defp version_info do
    "version: #{Librarian.version}"
  end
end
