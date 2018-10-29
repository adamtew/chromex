defmodule Chromex.Id do
  use Agent

  def start_link(_) do
    Agent.start_link(fn -> 1 end, name: __MODULE__)
  end

  def use() do
    id = current_id()
    increment_id()
    id
  end


  def current_id() do
    Agent.get(__MODULE__, fn id -> id end)
  end

  def increment_id() do
    Agent.update(__MODULE__, fn id -> id + 1 end)
  end

end
