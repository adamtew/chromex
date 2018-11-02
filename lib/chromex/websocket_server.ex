defmodule Chromex.WebSocketServer do
  use WebSockex
  alias Chromex.Id
  def start_link(pid) do
    Agent.start_link(fn -> pid end, name: __MODULE__)
  end

  def get_pid do
    Agent.get(__MODULE__, fn pid -> pid end)
  end
end
