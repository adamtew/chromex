defmodule Chromex do
  @moduledoc """
  Documentation for Chromex.
  """
  alias Chromex.Debugger
  alias Chromex.WebSocketServer
  alias Chromex.Id
  alias Chromex.ResponseServer

  # use Application

  # def start(_type, _args) do
  def start() do
    {:ok, pid} = Debugger.start(socket(), %{port: 9516})
    Id.start_link()
    ResponseServer.start_link()
    WebSocketServer.start_link(pid)
    Debugger.enable_page()
  end

  def navigate_to(url) do
    Debugger.navigate_to(url)
  end

  def html() do
    Debugger.get_html()
  end

  def get do
    HTTPoison.get!("http://localhost:9516/json")
    |> Map.get(:body)
    |> Poison.decode!
    |> List.first()
  end

  def socket() do
    HTTPoison.get!("http://localhost:9516/json")
    |> Map.get(:body)
    |> Poison.decode!
    |> List.first()
    |> Map.get("webSocketDebuggerUrl")
  end
end
