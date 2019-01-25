defmodule Librarian.Responders.Checkout do
  alias Librarian.{Admins, Library}

  def usage do
    "`checkout RESOURCE` : will checkout the RESOURCE from the library\n"
    <> "      - aliases: co\n"
  end

  def aliases, do: ["checkout", "co"]

  def call(resource, requester, _slack) do
    checkout_message_builder(resource, requester)
  end

  defp checkout_message_builder(resource, user) do
    if Library.has_resource(resource) do
      Library.availability_of(resource)
      |> checkout_message(resource, user)
    else
      checkout_message("N/A", resource, user)
    end
  end

  defp checkout_message("N/A", resource, _) do
    "I do not have #{resource} in my library. "
    <> case Admins.admin_list do
      [] -> "Please add it "
      _  -> "Please have an admin (#{Admins.admin_string}) add it for you "
    end
    <> "using `add` command."
  end

  defp checkout_message("Available", resource, user) do
    Library.set_availability(resource, user)
    "I checked out #{resource} for you"
  end
  defp checkout_message(owner, resource, _), do: "I cannot checkout #{resource}, because <@#{owner}> has it reserved."
end
