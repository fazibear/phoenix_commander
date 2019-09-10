defmodule PhoenixCommanderWeb.FileBrowserLive do
  use Phoenix.LiveView
  import Phoenix.HTML, only: [raw: 1]

  #
  # 25x80
  #
  #

  def render(assigns) do
    ~L"""
    <div phx-keydown="key" phx-target="window" class="phoenix_commander">
      <pre>&#x2554;&#x2550;<%= @commander.panel_1.path |> top_line(@commander.active_panel == :panel_1) |> raw() %>&#x2550;&#x2557;&#x2554;&#x2550;<%= @commander.panel_2.path |> top_line(@commander.active_panel == :panel_2) |> raw() %>&#x2550;&#x2557;</pre>
      <pre>&#x2551;<%= headers() |> raw %><% headers() |> raw() %>&#x2551;&#x2551;<%= headers() |> raw %><% headers() |> raw() %>&#x2551;</pre>
      <%= for row <- 0..21 do %>
        <pre>&#x2551;<%= raw line(:panel_1, @commander.panel_1, row, @commander.active_panel) %>&#x2551;&#x2551;<%= raw line(:panel_2, @commander.panel_2, row, @commander.active_panel) %>&#x2551;</pre>
      <% end %>
      <pre>&#x255A;<%= bottom_line() |> raw() %>&#x255D;&#x255A;<%= bottom_line() |> raw() %>&#x255D;</pre>
    </div>
    """
  end

  def top_line(title, active) do
    {_, title} = String.split_at(title, -34)
    class = "path"
    class = if active, do: class <> " active", else: class

    ~s[<b class="#{class}"> #{title} </b>#{
      String.duplicate("&#x2550;", 34 - String.length(title))
    }]
  end

  def headers do
    ~s[        <b class="header">Name</b>               &#x2502;   <b class="header">Size</b>   ]
  end

  def line(no, panel, row, active) do
    name = panel.content |> Enum.at(panel.offset + row, "") |> String.slice(0, 38)
    entry = name <> String.duplicate(" ", 38 - String.length(name))
    class = if no == active && panel.offset + row == panel.selection, do: "selected", else: ""
    cd = panel.content |> Enum.at(panel.offset + row)

    ~s[<b class="#{class}" phx-click="cd" phx-value-panel="#{no}" phx-value-cd="#{cd}">#{entry}</b>]
  end

  def bottom_line() do
    String.duplicate("&#x2550;", 38)
  end

  def mount(_session, socket) do
    {:ok, put_commander(PhoenixCommander.init(), socket)}
  end

  def handle_event("quit", _param, socket) do
    System.halt(0)

    {:noreply, socket}
  end

  def handle_event("cd", %{"panel" => panel, "cd" => cd}, socket) do
    socket =
      socket
      |> get_commander()
      |> PhoenixCommander.change_directory(panel, cd)
      |> put_commander(socket)

    {:noreply, socket}
  end

  # up
  def handle_event("key", %{"code" => "ArrowUp"}, socket) do
    socket =
      socket
      |> get_commander()
      |> PhoenixCommander.selection_up()
      |> put_commander(socket)

    {:noreply, socket}
  end

  # down
  def handle_event("key", %{"code" => "ArrowDown"}, socket) do
    socket =
      socket
      |> get_commander()
      |> PhoenixCommander.selection_down()
      |> put_commander(socket)

    {:noreply, socket}
  end

  # tab
  def handle_event("key", %{"code" => "Tab"}, socket) do
    socket =
      socket
      |> get_commander()
      |> PhoenixCommander.switch_panel()
      |> put_commander(socket)

    {:noreply, socket}
  end

  # enter
  def handle_event("key", %{"code" => "Enter"}, socket) do
    socket =
      socket
      |> get_commander()
      |> PhoenixCommander.change_directory()
      |> put_commander(socket)

    {:noreply, socket}
  end

  def handle_event("key", _data, socket) do
    # IO.inspect(data)
    {:noreply, socket}
  end

  defp get_commander(socket) do
    socket.assigns.commander
  end

  defp put_commander(commander, socket) do
    assign(socket, commander: commander)
  end
end
