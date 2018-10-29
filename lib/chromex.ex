defmodule Chromex do
  @moduledoc """
  Documentation for Chromex.
  """

  def get do
    HTTPoison.get!("http://localhost:9516/json")
    |> Map.get(:body)
    |> Poison.decode!
    |> List.first()
    # |> Map.get("id")
    # |> Map.get"webSocketDebuggerUrl")

  end

  def socket() do
    HTTPoison.get!("http://localhost:9516/json")
    |> Map.get(:body)
    |> Poison.decode!
    |> List.first()
    |> Map.get("webSocketDebuggerUrl")
  end
end
