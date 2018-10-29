defmodule Chromex.IdServer do
  use Agent

  def start_ling(_) do
    Agent.start_link(fn -> MapSet.new end, name: __MODULE__)
  end
end
