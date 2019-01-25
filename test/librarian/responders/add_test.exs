defmodule Librarian.Responders.AddTest do
  use ExUnit.Case, async: true

  alias Librarian.{Admins, Library}
  alias Librarian.Responders.Add

  setup do
    Supervisor.terminate_child(Librarian.Supervisor, :library)
    Supervisor.restart_child(Librarian.Supervisor, :library)
    Supervisor.terminate_child(Librarian.Supervisor, :admin)
    Supervisor.restart_child(Librarian.Supervisor, :admin)
    :ok
  end

  test "librarian add resourse adds the resource to library" do
    text = Add.call("foobar", "123", SlackSimulator.slack)
    assert text =~ "I added foobar to the library."
    assert Library.availability_of("foobar") =~ "Available"
  end

  test "librarian add resouce should notify the user when already in the library" do
    Library.set_availability("foobar")
    text = Add.call("foobar", "123", SlackSimulator.slack)
    assert text =~ "I already have foobar in my library."
  end

  test "librarian add resouce should notify the user if not an admin" do
    Library.set_availability("foobar")
    Admins.set_id("U456")
    text = Add.call("foobar", "123", SlackSimulator.slack)
    assert text =~ "You are not allowed to add resources. Please ask an admin (<@U456>) to do this for you."
  end

  test ".aliases" do
    assert Enum.member?(Add.aliases, "add")
  end
end
