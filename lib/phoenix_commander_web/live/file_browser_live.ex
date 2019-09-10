defmodule PhoenixCommanderWeb.FileBrowserLive do
  use Phoenix.LiveView
  import Phoenix.HTML, only: [raw: 1]

  #
  # 25x80
  #
  #

  def render(assigns) do
    ~L"""
    <pre><%= @panel_1.path |> top_line() |> raw() %><%= @panel_2.path |> top_line() |> raw() %></pre>
    <%= for n <- 0..22 do %>
      <pre>&#x2551;<%= raw line(1, @panel_1, n) %>&#x2551;&#x2551;<%= raw line(2, @panel_2, n) %>&#x2551;</pre>
    <% end %>
    <pre><%= bottom_line() |> raw() %><%= bottom_line() |> raw() %></pre>
    """
  end

  def top_line(title) do
    {_, title} = String.split_at(title, -34)

    ~s[&#x2554;&#x2550;<b class="path"> #{title} </b>&#x2550;#{
      String.duplicate("&#x2550;", 34 - String.length(title))
    }&#x2557;]
  end

  def line(no, panel, n) do
    name = panel.content |> Enum.at(panel.offset + n) || ""
    entry = String.slice(name, 0, 38) <> String.duplicate(" ", 38 - String.length(name))

    class = if panel.offset + n == panel.selection, do: "selected", else: ""
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
      |> assign(panel_1: panel)
      |> assign(panel_2: panel)

    {:ok, socket}
  end

  def handle_event("quit", _param, socket) do
    System.halt(0)

    {:noreply, socket}
  end

  def handle_event("cd", %{"panel" => "1", "cd" => cd}, socket) do
    panel_1 = socket.assigns.panel_1

    panel_1 =
      panel_1
      |> Map.put(:path, path(panel_1.path, cd))
      |> ls()

    socket =
      socket
      |> assign(panel_1: panel_1)

    {:noreply, socket}
  end

  def handle_event("cd", %{"panel" => "2", "cd" => cd}, socket) do
    panel_2 = socket.assigns.panel_2

    panel_2 =
      panel_2
      |> Map.put(:path, path(panel_2.path, cd))
      |> ls()

    socket =
      socket
      |> assign(panel_2: panel_2)

    {:noreply, socket}
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
