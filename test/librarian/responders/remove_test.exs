defmodule Librarian.Responders.RemoveTest do
  use ExUnit.Case
  alias Librarian.{Admins, Library}
  alias Librarian.Responders.Remove

  setup do
    Supervisor.terminate_child(Librarian.Supervisor, :library)
    Supervisor.restart_child(Librarian.Supervisor, :library)
    Supervisor.terminate_child(Librarian.Supervisor, :admin)
    Supervisor.restart_child(Librarian.Supervisor, :admin)
    :ok
  end

  test "librarian remove resourse will delete the resource from the library" do
    Library.set_availability("foobar")
    text = Remove.call("foobar", "123", SlackSimulator.slack)
    assert text =~ "I removed foobar from the library."
  end

  test "librarian remove resourse will delete the resource from the library if the owner" do
    Library.set_availability("foobar", "123")
    text = Remove.call("foobar", "123", SlackSimulator.slack)
    assert text =~ "I removed foobar from the library."
  end

  test "librarian remove resouce should notify the user if the resource is not in the library" do
    text = Remove.call("foobar", "123", SlackSimulator.slack)
    assert text =~ "I do not have foobar in my library."
  end

  test "librarian remove resouce should notify the user if they do not have correct permissions" do
    Library.set_availability("foobar")
    Admins.set_id("456")
    text = Remove.call("foobar", "123", SlackSimulator.slack)
    assert text =~ "You are not allowed to remove resources. Please ask an admin (<@456>) to do this for you."
  end

  test ".aliases" do
    assert Enum.member?(Remove.aliases, "remove")
    assert Enum.member?(Remove.aliases, "rm")
  end

end
