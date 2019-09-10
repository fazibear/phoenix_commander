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
    <pre><b phx-click="cd" phx-value="<%= encode(%{panel: 1, cd: ".."}) %>"><%= ".." |> line() |> raw() %></b><b phx-click="cd" phx-value="<%= encode(%{panel: 2, cd: ".."}) %>"><%= ".." |> line() |> raw() %></b></pre>
    <%= for n <- 0..22 do %>
      <pre><b phx-click="cd" phx-value="<%= encode(%{panel: 1, cd: @panel_1.content |> Enum.at(n)}) %>"><%= @panel_1.content |> Enum.at(n) |> line() |> raw() %></b><b phx-click="cd" phx-value="<%= encode(%{panel: 2, cd: @panel_2.content |> Enum.at(n)}) %>"><%= @panel_2.content |> Enum.at(n)  |> line() |> raw() %></b></pre>
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

  def line(content) do
    content = String.slice(content, 0, 38)

    ~s[&#x2551;<b class="file">#{content}</b>#{String.duplicate(" ", 38 - String.length(content))}&#x2551;]
  end

  def bottom_line() do
    ~s[&#x255A;#{String.duplicate("&#x2550;", 38)}&#x255D;]
  end

  def mount(_session, socket) do
    panel =
      %{
        path: Path.expand(".")
      }
      |> ls()

    socket =
      socket
      |> assign(panel_1: panel)
      |> assign(panel_2: panel)

    {:ok, socket}
  end

  def handle_event("quit", _param, _socket) do
    System.halt(0)
  end

  def handle_event("cd", data, socket) do
    socket =
      case decode(data) do
        %{panel: 1, cd: cd} ->
          panel_1 = socket.assigns.panel_1

          panel_1 =
            panel_1
            |> Map.put(:path, path(panel_1.path, cd))
            |> ls()

          socket =
            socket
            |> assign(panel_1: panel_1)

        %{panel: 2, cd: cd} ->
          panel_2 = socket.assigns.panel_2

          panel_2 =
            panel_2
            |> Map.put(:path, path(panel_2.path, cd))
            |> ls()

          socket =
            socket
            |> assign(panel_2: panel_2)

        _ ->
          socket
      end

    {:noreply, socket}
  end

  defp encode(value) do
    value
    |> :erlang.term_to_binary()
    |> Base.encode64()
  end

  defp decode(value) do
    value
    |> Base.decode64()
    |> elem(1)
    |> :erlang.binary_to_term()
  end

  defp ls(panel) do
    case File.ls(panel.path) do
      {:ok, entries} ->
        {dirs, files} = Enum.split_with(entries, &File.dir?(path(panel.path, &1)))

        panel
        |> Map.put(:content, Enum.sort(dirs) ++ Enum.sort(files))

      _ ->
        panel
    end
  end

  defp path(path, param) do
    Path.expand(path <> "/" <> param)
  end
end