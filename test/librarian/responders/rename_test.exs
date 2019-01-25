defmodule Librarian.Responders.RenameTest do
  use ExUnit.Case
  alias Librarian.{Admins, Library}
  alias Librarian.Responders.Rename

  setup do
    Supervisor.terminate_child(Librarian.Supervisor, :library)
    Supervisor.restart_child(Librarian.Supervisor, :library)
    Supervisor.terminate_child(Librarian.Supervisor, :admin)
    Supervisor.restart_child(Librarian.Supervisor, :admin)
    :ok
  end

  test "librarian rename resourse should rename the resource to a new name" do
    Library.set_availability("foo")
    text = Rename.call("foo to bar", "123", SlackSimulator.slack)
    assert text =~ "I changed the name of foo to bar for you."
    assert Library.has_resource("bar") == true
    assert Library.has_resource("foo") == false
  end

  test "librarian rename resourse should rename the resource to a new name when the user is the owner" do
    Library.set_availability("foo", "123")
    text = Rename.call("foo to bar", "123", SlackSimulator.slack)
    assert text =~ "I changed the name of foo to bar for you."
    assert Library.has_resource("bar") == true
    assert Library.has_resource("foo") == false
  end

  test "librarian rename resourse should tell the user to add the new_name if the resource doesn't exist" do
    text = Rename.call("foo to bar", "123", SlackSimulator.slack)
    assert text =~ "I do not have foo in my library. Please add the new resource with `librarian add bar`."
    assert Library.has_resource("bar") == false
  end

  test "librarian rename resourse should not rename the resource if it checked out by another user" do
    Library.set_availability("foo", "123")
    text = Rename.call("foo to bar", "456", SlackSimulator.slack)
    assert text =~ "I cannot change the name of foo because <@123> has it checked out."
    assert Library.has_resource("foo") == true
    assert Library.has_resource("bar") == false
  end

  test "librarian rename resourse should not rename the resource if the user is not an admin" do
    Library.set_availability("foo")
    Admins.set_id("456")
    text = Rename.call("foo to bar", "123", SlackSimulator.slack)
    assert text =~ "You are not allowed to rename resources. Please ask an admin (<@456>) to do this for you."
    assert Library.has_resource("foo") == true
    assert Library.has_resource("bar") == false
  end

  test "rename should handle malformed request gracefully" do
    resp = Rename.call("this is not valid", "123", SlackSimulator.slack)

    assert resp =~ "rename RESOURCE to NEW_NAME"
  end

  test ".aliases" do
    assert Enum.member?(Rename.aliases, "rename")
  end

end
