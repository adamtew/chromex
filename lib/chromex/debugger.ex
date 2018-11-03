defmodule Chromex.Debugger do
  use WebSockex
  require Logger
  alias Chromex.Id
  alias Chromex.WebSocketServer
  alias Chromex.ResponseServer

  @moduledoc ~S"""
  Sample usage connecting to a devtools remote-debugging page to orchestrate the browser and receive network events on the socket directly.
  Example Usage With a Chrome Remote Debugging Enabled Instance (or driver), and using Poison to decode/encode the remote-protocol message passing (assuming you have started chrome with a remote debugging port 55171, and have the WebSocket address for the page/tab in question)

  ```
  Debugger.start("ws://127.0.0.1:55171/devtools/page/18569def-3e03-4d67-a5b9-ca6a0ee0db77", %{port: 55171})
  ```
  """
     
  def start(url, state) do
    {:ok, pid} = WebSockex.start(url, __MODULE__, state)
    # resp = WebSockex.send_frame(pid, {:text, Poison.encode!(%{id: 1, method: "Page.navigate", params: %{url: "http://www.google.com"}})})
    # Logger.info(fn -> "response: #{inspect(resp)}" end)
    # WebSockex.send_frame(pid, {:text, Poison.encode!(%{id: 1, method: "Network.enable", params: %{}})})
    # WebSockex.send_frame(pid, {:text, Poison.encode!(%{id: 2, method: "Runtime.enable", params: %{}})})
    # WebSockex.send_frame(pid, {:text, Poison.encode!(%{id: 3, method: "Page.enable", params: %{}})})
    {:ok, pid}
  end

  def enable_page() do
    id = Id.use()
    payload = %{
      id: id,
      method: "Page.enable",
      params: %{}
    }
    |> Poison.encode!()
    WebSockex.send_frame(WebSocketServer.get_pid(), {:text, payload})
    wait_for_response(id)
  end

  def navigate_to(url) do
    id = Id.use()
    payload = %{
      id: id,
      method: "Page.navigate",
      params: %{url: url}
    }
    |> Poison.encode!()
    WebSockex.send_frame(WebSocketServer.get_pid(), {:text, payload})
    wait_for_response(id)
  end

  def wait_for_page_load() do
    # This may be really useful
    # https://chromedevtools.github.io/devtools-protocol/tot/Network#event-loadingFinished
    :timer.sleep(3000)
  end

  def get_html() do
    id = Id.use()
    payload = %{
      id: id,
      method: "Runtime.evaluate",
      params: %{expression: "document.documentElement.outerHTML"}
    }
    |> Poison.encode!()
    WebSockex.send_frame(WebSocketServer.get_pid(), {:text, payload})
    wait_for_response(id)
  end

  @timeout_script "setTimeout(function(){document.write('something')}, 5000);"
  @delete_script "delete window.navigator['webdriver'];"
  @override_getter_script  "Object.defineProperty(navigator, 'webdriver', { get: () => undefined,});"
  @set_undefined_script  "Object.defineProperty(navigator, 'webdriver', undefined);"
  @verify "setTimeout(function(){console.log('injected')}, 5000);"
  @script "#{@override_getter_script};#{@verify}"
  # @script "setTimeout(function(){document.write('something')}, 5000)"
  # @script "window.navigator.webdriver = false"
  def inject_js() do
    id = Id.use()
    payload = %{
      id: id,
      method: "Page.addScriptToEvaluateOnNewDocument",
      params: %{source: @script}
    }
    |> Poison.encode!()
    WebSockex.send_frame(WebSocketServer.get_pid(), {:text, payload})
    wait_for_response(id)
  end

  def check_webdriver() do
    id = Id.use()
    payload = %{
      id: id,
      method: "Runtime.evaluate",
      params: %{expression: "window.navigator.webdriver"}
    }
    |> Poison.encode!()
    WebSockex.send_frame(WebSocketServer.get_pid(), {:text, payload})
    wait_for_response(id)
  end

  def run_js(js) do
    id = Id.use()
    payload = %{
      id: id,
      method: "Runtime.evaluate",
      params: %{expression: js}
    }
    |> Poison.encode!()
    WebSockex.send_frame(WebSocketServer.get_pid(), {:text, payload})
    wait_for_response(id)
  end

  def screenshot() do
    id = Id.use()
    filepath = "/Users/adamtew/git/adamtew/chromex/#{id}"
    payload = %{
      id: id,
      method: "Page.captureScreenshot",
      params: %{}
    }
    |> Poison.encode!()
    WebSockex.send_frame(WebSocketServer.get_pid(), {:text, payload})
    response = wait_for_response(id)
    img = response["result"]["data"]
    File.write(filepath, img)
  end

  def wait_for_response(id) do
    case ResponseServer.get_response(id) do
      nil ->
        :timer.sleep(1000)
        wait_for_response(id)
      response -> response
    end

  end

  def command(pid, id, method, params \\ %{}) do
    WebSockex.send_frame(pid, {:text, Poison.encode!(%{id: id, method: method, params: params})})
  end

  def terminate(reason, state) do
    IO.puts("WebSockex for remote debbugging on port #{state.port} terminating with reason: #{inspect reason}")
    exit(:normal)
  end

  def handle_frame({_type, msg}, state) do
    item = Poison.decode!(msg)
    return_value = check_response_type(item)
    ResponseServer.store_response(item["id"], return_value)
    {:ok, return_value}
  end

  def check_response_type(%{"result" => %{"result" => %{"type" => "string", "value" => value}}}) do
    value
  end
  def check_response_type(%{"result" => %{"frameId" => frame_id}}) do
    frame_id
  end
  def check_response_type(msg) do
    msg
  end
  
end
