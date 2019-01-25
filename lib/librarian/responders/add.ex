defmodule Librarian.Responders.Add do
  alias Librarian.Library
  alias Librarian.Admins

  def usage, do: "`add RESOURCE` : will add the RESOURCE to the library\n"

  def aliases, do: ["add"]

  def call(resource, requester, _slack) do
    addition_message_builder(resource, requester)
  end

  defp addition_message_builder(resource, requester) do
    cond do
      !Admins.allowed?(requester) ->
        "You are not allowed to add resources. Please ask an admin (#{Admins.admin_string}) to do this for you."
      Library.has_resource(resource) ->
        "I already have #{resource} in my library."
      true ->
        add_resource(resource)
        "I added #{resource} to the library."
    end
  end

  defp add_resource(resource), do: Library.set_availability(resource)
end
