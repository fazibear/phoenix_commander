defmodule PhoenixCommander.Panel do
  defstruct path: Path.expand("."),
            offset: 0,
            selection: 0,
            content: PhoenixCommander.Dir.ls(Path.expand(".")),
            content_length: 19

  def change_directory(panel, new_directory) do
    case PhoenixCommander.Dir.new_path(panel.path, new_directory) do
      {:ok, new_path} ->
        old_path = panel.path |> Path.basename()
        content = PhoenixCommander.Dir.ls(new_path)
        selection = Enum.find_index(content, fn {name, _} -> name == old_path end) || 0

        offset =
          if selection in 0..panel.content_length do
            0
          else
            selection - panel.content_length
          end

        panel
        |> Map.put(:path, new_path)
        |> Map.put(:selection, selection)
        |> Map.put(:offset, offset)
        |> Map.put(:content, content)

      _ ->
        panel
    end
  end

  def selection_up(panel) do
    selection = panel.selection - 1
    offset = panel.offset
    length = length(panel.content)
    selection = if selection < 0, do: 0, else: selection

    offset =
      unless selection >= offset && selection <= offset + panel.content_length do
        offset = offset - 1
        offset = if offset < 0, do: 0, else: offset
        if offset > length - panel.content_length, do: length - panel.content_length, else: offset
      else
        offset
      end

    panel
    |> Map.put(:selection, selection)
    |> Map.put(:offset, offset)
  end

  def selection_down(panel) do
    selection = panel.selection + 1
    offset = panel.offset
    length = length(panel.content)
    selection = if selection > length - 1, do: length - 1, else: selection

    offset =
      unless selection >= offset && selection <= offset + panel.content_length do
        offset = offset + 1
        offset = if offset < 0, do: 0, else: offset
        if offset > length - panel.content_length, do: length - panel.content_length, else: offset
      else
        offset
      end

    panel
    |> Map.put(:selection, selection)
    |> Map.put(:offset, offset)
  end
end
