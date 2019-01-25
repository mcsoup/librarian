defmodule Librarian.Responders.Return do
  alias Librarian.{Admins, Library}
  use Combine

  def usage do
    "`return [OPTION] RESOURCE` : will return the RESOURCE to the library if it is not checked out\n"
    <> "      - aliases: checkin, ci\n"
    <> "      -f, --force\n"
    <> "            force the return of the RESOURCE\n"
  end

  def aliases, do: ~w(return checkin ci)

  def call(args, requester, slack) do
    {force, resource} = case Combine.parse(args, args_parser) do
                          [nil, resource] -> {false, resource}
                          [_force_flag, resource] -> {true, resource}
                        end

    return_message_builder(resource, requester, force, slack)
  end

  defp args_parser do
    option(
      either(
        string("-f"),
        string("--force")
      )
      |> ignore(spaces)
    ) |> label(word_of(~r/.*/), "resource")
  end

  defp return_message_builder(resource, user, force, slack) do
    if Library.has_resource(resource) do
      Library.availability_of(resource)
      |> return_message(resource, user, force)
    else
      return_message("N/A", resource, slack)
    end
  end

  defp return_message("N/A", resource, slack) do
    "I do not have #{resource} in my library. Please "
    <> case Admins.admin_list do
      [] -> ""
      _  -> "have an admin (#{Admins.admin_string}) "
    end
    <> "add it with `#{slack.me.name} add #{resource}`."
  end
  defp return_message("Available", resource, _, _) do
    "Someone already returned #{resource} to my library."
  end
  defp return_message(owner, resource, user, _) when owner == user do
    make_available(resource)
    "I returned #{resource} for you."
  end
  defp return_message(owner, resource, _, true) do
    make_available(resource)
    "I stole #{resource} from <@#{owner}> and returned it to my library."
  end
  defp return_message(owner, resource, _, _), do: "You cannot return #{resource}, because <@#{owner}> has it checked out."

  defp make_available(resource), do: Library.set_availability(resource)
end
