defmodule Librarian.Responders.Remove do
  alias Librarian.Library
  alias Librarian.Admins

  def usage do
    "`remove RESOURCE` : will remove the RESOURCE from the library\n"
    <> "      - aliases: rm\n"
  end

  def aliases, do: ["remove", "rm"]

  def call(resource, requester, _slack) do
    remove_message_builder(resource, requester)
  end

  defp remove_message_builder(resource, user) do
    cond do
      !Admins.allowed?(user) ->
        "You are not allowed to remove resources. Please ask an admin (#{Admins.admin_string}) to do this for you."
      true ->
        Library.availability_of(resource)
        |> remove_resource(resource)
        |> remove_message(resource, user)
    end
  end

  defp remove_resource("Available", resource), do: Library.remove(resource)
  defp remove_resource(owner, _), do: owner

  defp remove_message(:ok, resource, _), do: "I removed #{resource} from the library."
  defp remove_message(:error, resource, _), do: "I do not have #{resource} in my library."
  defp remove_message(owner, resource, user) when owner == user do
    remove_resource("Available", resource)
    |> remove_message(resource, user)
  end
  defp remove_message(owner, resource, _), do: "I cannot remove #{resource}, because <@#{owner}> has it checked out."
end
