defmodule Librarian.Responders.Rename do
  alias Librarian.Library
  alias Librarian.Admins
  use Combine
  require Logger
  
  def usage, do: "`rename RESOURCE to NEW_NAME` : will rename the RESOURCE in the library to the NEW_NAME"

  def aliases, do: ["rename"]

  def call(args, requester, _slack) do
    with {:ok, {resource, new_name}} <- parse_args(args) do
      Logger.debug "renaming #{resource} to #{new_name}"
      rename_message_builder(resource, new_name, requester)
    else
      {:error,_ } -> "i don't understand #{inspect(args)}. usage: #{usage}" 
    end
  end

  defp parse_args(args) do
    with [from, to] <- Combine.parse(args, args_parser) do
      {:ok, {from, to}}
    else
      {:error, _} = err -> err
    end
  end

  defp args_parser do
    word_of(~r/.*(?= +to)/i)
    |> ignore(spaces)
    |> ignore(word_of(~r/to/i))
    |> ignore(spaces)
    |> word_of(~r/.*/)
  end

  defp rename_message_builder(resource, new_name, user) do
    cond do
      !Admins.allowed?(user) ->
        "You are not allowed to rename resources. Please ask an admin (#{Admins.admin_string}) to do this for you."
      Library.has_resource(resource) ->
        Library.availability_of(resource)
        |> rename_message(resource, new_name, user)
      true ->
        "I do not have #{resource} in my library. Please add the new resource with `librarian add #{new_name}`."
    end
  end

  defp rename_message("Available", resource, new_name, _), do: rename_message(nil, resource, new_name, nil)
  defp rename_message(owner, resource, new_name, user) when owner == user do
    rename_resource(resource, new_name, user)
    "I changed the name of #{resource} to #{new_name} for you."
  end
  defp rename_message(owner, resource, _, _), do: "I cannot change the name of #{resource} because <@#{owner}> has it checked out."

  defp rename_resource(resource, new_name, user) do
    Library.remove(resource)
    Library.set_availability(new_name, user)
  end
end
