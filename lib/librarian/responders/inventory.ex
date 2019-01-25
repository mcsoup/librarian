defmodule Librarian.Responders.Inventory do
  alias Librarian.{Admins, Library}
  require Slack.Lookups

  def usage do
    "`inventory` : will return an itemized list of all resources in the library and who has them checked out\n"
    <> "      - aliases: status\n"
  end

  def aliases, do: ["inventory", "status"]

  def call(_args, _requester, slack), do: inventory_message_builder(slack)

  defp inventory_message_builder(slack) do
    Library.inventory
    |> inventory_message(slack)
  end

  defp inventory_message(map, slack) when map == %{} do
    "My library inventory is currently empty. Please "
    <> case Admins.admin_list do
      [] -> ""
      _  -> "have an admin (#{Admins.admin_string}) "
    end
    <> "add some resources with `#{slack.me.name} add RESOURCE`."
  end
  defp inventory_message(map, slack) do
    "My current library inventory includes:\n• *Resource*: *User*"
    |> stringify_inventory(map, slack)
  end

  defp stringify_inventory(preamble, map, slack) do
    [preamble | Enum.map(map, fn {resource, user} -> "#{resource}: #{format_user(user, slack)}" end)]
    |> Enum.join("\n• ")
  end

  defp format_user(nil, _), do: "Available"
  defp format_user(user, slack) do
    slack.users[user].name
  end
end
