defmodule Librarian.Responders.InventoryTest do
  use ExUnit.Case
  alias Librarian.{Admins, Library}
  alias Librarian.Responders.Inventory

  setup do
    Supervisor.terminate_child(Librarian.Supervisor, :library)
    Supervisor.restart_child(Librarian.Supervisor, :library)
    Supervisor.terminate_child(Librarian.Supervisor, :admin)
    Supervisor.restart_child(Librarian.Supervisor, :admin)
    :ok
  end

  test "librarian inventory should return a message if the inventory is empty" do
    text = Inventory.call(nil, "123", SlackSimulator.slack)
    assert text =~ "My library inventory is currently empty. Please add some resources with `librarian add RESOURCE`."
  end

  test "librarian inventory should return a message if the inventory is empty and an admin is set" do
    Admins.set_id("456")
    text = Inventory.call(nil, "123", SlackSimulator.slack)
    assert text =~ "My library inventory is currently empty. Please have an admin (<@456>) add some resources with `librarian add RESOURCE`."
  end

  test "librarian inventory should return a list of checked out resources" do
    Library.set_availability("baznich")
    Library.set_availability("foobar", "123")
    text = Inventory.call(nil, "123", SlackSimulator.slack)
    assert text =~ "My current library inventory includes:\n• *Resource*: *User*\n• baznich: Available\n• foobar: bob"
  end

  test ".aliases" do
    assert Enum.member?(Inventory.aliases, "inventory")
    assert Enum.member?(Inventory.aliases, "status")
  end

end
