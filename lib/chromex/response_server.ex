defmodule Chromex.ResponseServer do
  use Agent

  def start_link() do
    Agent.start_link(fn -> %{0 => nil} end, name: __MODULE__)
  end

  def store_response(id, response) do
    Agent.update(__MODULE__, fn item -> Map.put(item, id, response) end)
  end

  def get_response(id) do
    Agent.get(__MODULE__, fn  item -> Map.get(item, id) end)
  end
end
