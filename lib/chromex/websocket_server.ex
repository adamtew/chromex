defmodule Chromex.WebSocketServer do
  use WebSockex
  def start_link(url, state) do
    {:ok, pid} = WebSockex.start(url, __MODULE__, state)
    Agent.start_link(fn -> pid end, name: __MODULE__)
  end

  def get_pid do
    Agent.get(__MODULE__, fn pid -> pid end)
  end
end
