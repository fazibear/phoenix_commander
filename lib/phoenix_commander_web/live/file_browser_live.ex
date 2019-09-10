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
      <pre><%= @panel_1.path |> top_line() |> raw() %><%= @panel_2.path |> top_line() |> raw() %></pre>
      <%= for n <- 0..22 do %>
        <pre>&#x2551;<%= raw line(1, @panel_1, n, @active) %>&#x2551;&#x2551;<%= raw line(2, @panel_2, n, @active) %>&#x2551;</pre>
      <% end %>
      <pre><%= bottom_line() |> raw() %><%= bottom_line() |> raw() %></pre>
    </div>
    """
  end

  def top_line(title) do
    {_, title} = String.split_at(title, -34)

    ~s[&#x2554;&#x2550;<b class="path"> #{title} </b>&#x2550;#{
      String.duplicate("&#x2550;", 34 - String.length(title))
    }&#x2557;]
  end

  def line(no, panel, n, active) do
    name = panel.content |> Enum.at(panel.offset + n, "") |> String.slice(0, 38)
    entry = name <> String.duplicate(" ", 38 - String.length(name))
    class = if no == active && panel.offset + n == panel.selection, do: "selected", else: ""
    cd = panel.content |> Enum.at(panel.offset + n)

    ~s[<b class="#{class}" phx-click="cd" phx-value-panel="#{no}" phx-value-cd="#{cd}">#{entry}</b>]
  end

  def bottom_line() do
    ~s[&#x255A;#{String.duplicate("&#x2550;", 38)}&#x255D;]
  end

  def mount(_session, socket) do
    panel =
      %{
        path: Path.expand("."),
        offset: 0,
        selection: 2
      }
      |> ls()

    socket =
      socket
      |> assign(active: 1)
      |> assign(panel_1: panel)
      |> assign(panel_2: panel)

    {:ok, socket}
  end

  def handle_event("quit", _param, socket) do
    System.halt(0)

    {:noreply, socket}
  end

  def handle_event("cd", %{"panel" => panel, "cd" => cd}, socket) do
    socket =
      case panel do
        "1" ->
          assign(socket, panel_1: cd(socket.assigns.panel_1, cd))

        "2" ->
          assign(socket, panel_2: cd(socket.assigns.panel_2, cd))

        _ ->
          socket
      end

    {:noreply, socket}
  end

  # up
  def handle_event("key", %{"code" => "ArrowUp"}, socket) do
    socket =
      case socket.assigns.active do
        1 ->
          assign(socket, panel_1: key_up(socket.assigns.panel_1))

        2 ->
          assign(socket, panel_2: key_up(socket.assigns.panel_2))

        _ ->
          socket
      end

    {:noreply, socket}
  end

  # down
  def handle_event("key", %{"code" => "ArrowDown"}, socket) do
    socket =
      case socket.assigns.active do
        1 ->
          assign(socket, panel_1: key_down(socket.assigns.panel_1))

        2 ->
          assign(socket, panel_2: key_down(socket.assigns.panel_2))

        _ ->
          socket
      end

    {:noreply, socket}
  end

  # tab
  def handle_event("key", %{"code" => "Tab"}, socket) do
    active = if socket.assigns.active == 1, do: 2, else: 1

    socket =
      socket
      |> assign(active: active)

    {:noreply, socket}
  end

  # enter
  def handle_event("key", %{"code" => "Enter"}, socket) do
    socket =
      case socket.assigns.active do
        1 ->
          cd = Enum.at(socket.assigns.panel_1.content, socket.assigns.panel_1.selection)
          assign(socket, panel_1: cd(socket.assigns.panel_1, cd))

        2 ->
          cd = Enum.at(socket.assigns.panel_2.content, socket.assigns.panel_2.selection)
          assign(socket, panel_2: cd(socket.assigns.panel_2, cd))

        _ ->
          socket
      end

    {:noreply, socket}
  end

  def handle_event("key", _data, socket) do
    # IO.inspect(data)
    {:noreply, socket}
  end

  defp cd(panel, cd) do
    panel
    |> Map.put(:path, path(panel.path, cd))
    |> Map.put(:selection, 0)
    |> ls()
  end

  defp key_down(panel) do
    selection = panel.selection + 1
    offset = panel.offset
    length = length(panel.content)
    selection = if selection > length - 1, do: length - 1, else: selection

    offset =
      unless selection >= offset && selection <= offset + 22 do
        offset = offset + 1
        offset = if offset < 0, do: 0, else: offset
        if offset > length - 22, do: length - 22, else: offset
      else
        offset
      end

    panel
    |> Map.put(:selection, selection)
    |> Map.put(:offset, offset)
  end

  defp key_up(panel) do
    selection = panel.selection - 1
    offset = panel.offset
    length = length(panel.content)
    selection = if selection < 0, do: 0, else: selection

    offset =
      unless selection >= offset && selection <= offset + 22 do
        offset = offset - 1
        offset = if offset < 0, do: 0, else: offset
        if offset > length - 22, do: length - 22, else: offset
      else
        offset
      end

    panel
    |> Map.put(:selection, selection)
    |> Map.put(:offset, offset)
  end

  defp ls(panel) do
    case File.ls(panel.path) do
      {:ok, entries} ->
        {dirs, files} = Enum.split_with(entries, &File.dir?(path(panel.path, &1)))

        panel
        |> Map.put(:content, [".."] ++ Enum.sort(dirs) ++ Enum.sort(files))

      _ ->
        panel
    end
  end

  defp path(path, param) do
    Path.expand(path <> "/" <> param)
  end
end
