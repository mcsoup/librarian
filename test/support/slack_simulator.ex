defmodule SlackSimulator do
  def slack, do: %{me: me, users: users}
  def me, do: %{name: name}
  def name, do: "librarian"
  def users, do: %{"123" => %{name: "bob"}}
end
