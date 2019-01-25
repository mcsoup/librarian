defmodule Librarian.Library do
  @cache "library"

  def initialize, do: read_file |> initialize
  def initialize({:ok, text}), do: initialize(text)
  def initialize(text) when is_bitstring(text), do: String.split(text, ~r/\n/) |> initialize
  def initialize([""]), do: IO.inspect("The Resource List File is Empty")
  def initialize(resource_list) do
    ConCache.put(__MODULE__, @cache, Enum.reject(resource_list, &(&1 == ""))
                                     |> Enum.map(&{&1, nil})
                                     |> Enum.into(%{}))
  end

  def set_availability(resource), do: set_availability(resource, nil)
  def set_availability(resource, user) do
    ConCache.put(__MODULE__, @cache, Map.put(inventory, chomp(resource), user))
    write_keys_to_file
  end

  def remove(resource) do
    resource = chomp(resource)
    if Map.has_key?(inventory, resource) do
      ConCache.put(__MODULE__, @cache, Map.delete(inventory,resource))
      write_keys_to_file
      :ok
    else
      :error
    end
  end

  def availability_of(resource) do
    case inventory[chomp(resource)] do
      nil -> "Available"
      user -> user
    end
  end

  def has_resource(resource) do
    Map.has_key?(inventory, chomp(resource))
  end

  def inventory do
    ConCache.get(__MODULE__, @cache) || %{}
  end

  def chomp(resource) when is_nil(resource), do: nil
  def chomp(resource) do
    String.replace_trailing(resource, " ", "")
    |> String.replace_leading(" ", "")
    |> String.downcase
  end

  defp file_path, do: File.cwd!|> Path.join("config/resource_list")

  defp read_file do
    case File.read(file_path) do
      {:error, _} ->
        File.write(file_path, "")
        ""
      text -> text
    end
  end

  defp write_keys_to_file do
    key_string = Map.keys(inventory) |> Enum.join("\n")
    File.write(file_path, key_string)
    :ok
  end
end
