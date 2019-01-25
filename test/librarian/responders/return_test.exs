defmodule Librarian.Responders.ReturnTest do
  use ExUnit.Case
  alias Librarian.{Admins, Library}
  alias Librarian.Responders.Return

  setup do
    Supervisor.terminate_child(Librarian.Supervisor, :library)
    Supervisor.restart_child(Librarian.Supervisor, :library)
    Supervisor.terminate_child(Librarian.Supervisor, :admin)
    Supervisor.restart_child(Librarian.Supervisor, :admin)
    :ok
  end

  test "librarian return resourse will notify the user if the resource has already been returned" do
    Library.set_availability("foobar")
    text = Return.call("foobar", "123", SlackSimulator.slack)
    assert text =~ "Someone already returned foobar to my library."
  end

  test "librarian return resouce should notify the user who has an item checked out" do
    Library.set_availability("foobar", "456")
    text = Return.call("foobar", "123", SlackSimulator.slack)
    assert text =~ "You cannot return foobar, because <@456> has it checked out."
    assert Library.availability_of("foobar") =~ "456"
  end

  test "librarian force return resouce should force the resource back into the library" do
    Library.set_availability("foobar", "456")
    text = Return.call("--force foobar", "123", SlackSimulator.slack)
    assert text =~ "I stole foobar from <@456> and returned it to my library."
    assert Library.availability_of("foobar") =~ "Available"
  end

  test "librarian checkin resouce should be an alias for return" do
    Library.set_availability("foobar", "123")
    text = Return.call("foobar", "123", SlackSimulator.slack)
    assert text =~ "I returned foobar for you."
    assert Library.availability_of("foobar") =~ "Available"
  end

  test "librarian ci resouce should be an alias for return" do
    Library.set_availability("foobar", "123")
    text = Return.call("foobar", "123", SlackSimulator.slack)
    assert text =~ "I returned foobar for you."
    assert Library.availability_of("foobar") =~ "Available"
  end

  test "librarian return resourse should reply if it is not in the library" do
    text = Return.call("foobar", "123", SlackSimulator.slack)
    assert text =~ "I do not have foobar in my library."
  end

  test "librarian return resourse should notify an admin if it is not in the library" do
    Admins.set_id("456")
    text = Return.call("foobar", "123", SlackSimulator.slack)
    assert text =~ "I do not have foobar in my library."
  end

  test ".aliases" do
    assert Enum.member?(Return.aliases, "return")
    assert Enum.member?(Return.aliases, "checkin")
    assert Enum.member?(Return.aliases, "ci")
  end

end
