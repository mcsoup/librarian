defmodule Librarian.Responders.CheckoutTest do
  use ExUnit.Case
  alias Librarian.{Admins, Library}
  alias Librarian.Responders.Checkout

  setup do
    Supervisor.terminate_child(Librarian.Supervisor, :library)
    Supervisor.restart_child(Librarian.Supervisor, :library)
    Supervisor.terminate_child(Librarian.Supervisor, :admin)
    Supervisor.restart_child(Librarian.Supervisor, :admin)
    :ok
  end

  test "librarian checkout resourse will checkout the resource for the given user" do
    Library.set_availability("foobar")
    text = Checkout.call("foobar", "123", SlackSimulator.slack)
    assert text =~ "I checked out foobar for you"
    assert Library.availability_of("foobar") =~ "123"
  end

  test "librarian co resourse should be an alias for checkout" do
    Library.set_availability("foobar")
    text = Checkout.call("foobar", "123", SlackSimulator.slack)
    assert text =~ "I checked out foobar for you"
    assert Library.availability_of("foobar") =~ "123"
  end

  test "librarian checkout resouce should notify the user who has an item checked out" do
    Library.set_availability("foobar", "123")
    text = Checkout.call("foobar", "456", SlackSimulator.slack)
    assert text =~ "I cannot checkout foobar, because <@123> has it reserved."
  end

  test "librarian checkout resourse should reply if it is not in the library" do
    text = Checkout.call("foobar", "123", SlackSimulator.slack)
    assert text =~ "I do not have foobar in my library. Please add it"
  end

  test "librarian checkout resourse should notifiy an admin if it is not in the library" do
    Admins.set_id("456")
    text = Checkout.call("foobar", "123", SlackSimulator.slack)
    assert text =~ "I do not have foobar in my library. Please have an admin (<@456>) add it"
  end

  test ".aliases" do
    assert Enum.member?(Checkout.aliases, "checkout")
    assert Enum.member?(Checkout.aliases, "co")
  end
end
