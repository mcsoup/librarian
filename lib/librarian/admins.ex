defmodule Librarian.Admins do
  @cache "admins"
  use Slack

  def initialize, do: read_file |> initialize
  def initialize({:ok, text}), do: initialize(text)
  def initialize(text) when is_bitstring(text), do: String.split(text, ~r/\n/) |> initialize
  def initialize([""]), do: IO.inspect("The Admin List File is Empty")
  def initialize(list) do
    Enum.reject(list, &(&1 == ""))
    |> set_admins
  end

  def set_admins(names) do
    get_user_id_from(names)
    |> Enum.each(&set_id(&1))
  end

  def set_id(id) do
    ConCache.put(__MODULE__, @cache, admin_list ++ [id])
  end

  def admin_list do
    ConCache.get(__MODULE__, @cache) || []
  end

  def admin_string do
    "<@#{Enum.join(admin_list, ">, <@")}>"
  end

  def allowed?(user), do: admin_list == [] || Enum.member?(admin_list, user)

  def get_user_id_from(names) do
    members = Slack.Web.Users.list(%{token: Librarian.token})["members"]
    Enum.map(names, fn(name) ->
      Enum.find(members, fn(user) -> user["name"] == name end)
      |> Map.fetch("id")
      |> elem(1)
    end)
  end

  defp file_path, do: File.cwd!|> Path.join("config/admin_list")

  defp read_file do
    case File.read(file_path) do
      {:error, _} ->
        File.write(file_path, "")
        ""
      text -> text
    end
  end
end
