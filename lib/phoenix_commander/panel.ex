defmodule PhoenixCommander.Panel do
  defstruct path: Path.expand("."),
            offset: 0,
            selection: 0,
            content: PhoenixCommander.Dir.ls(Path.expand(".")),
            content_length: 21

  def change_directory(panel, new_directory) do
    new_path = PhoenixCommander.Dir.path(panel.path, new_directory)

    panel
    |> Map.put(:path, new_path)
    |> Map.put(:selection, 0)
    |> Map.put(:content, PhoenixCommander.Dir.ls(new_path))
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
