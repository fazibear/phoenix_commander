defmodule PhoenixCommander do
  defstruct active_panel: :panel_1,
            panel_1: %PhoenixCommander.Panel{},
            panel_2: %PhoenixCommander.Panel{}

  def init do
    %__MODULE__{}
  end

  def change_directory(commander) do
    panel_name = Map.get(commander, :active_panel)
    panel = Map.get(commander, panel_name)

    new_directory =
      panel
      |> Map.get(:content)
      |> Enum.at(panel.selection)

    change_directory(commander, panel_name, new_directory)
  end

  def change_directory(commander, panel, new_directory) when is_atom(panel) do
    new_panel =
      commander
      |> Map.get(panel)
      |> PhoenixCommander.Panel.change_directory(new_directory)

    Map.put(commander, panel, new_panel)
  end

  def change_directory(commander, panel, new_directory) do
    change_directory(commander, String.to_existing_atom(panel), new_directory)
  end

  def switch_panel(commander) do
    new_active_panel = if commander.active_panel == :panel_1, do: :panel_2, else: :panel_1
    Map.put(commander, :active_panel, new_active_panel)
  end

  def selection_up(commander) do
    panel = Map.get(commander, :active_panel)

    new_panel =
      commander
      |> Map.get(panel)
      |> PhoenixCommander.Panel.selection_up()

    Map.put(commander, panel, new_panel)
  end

  def selection_down(commander) do
    panel = Map.get(commander, :active_panel)

    new_panel =
      commander
      |> Map.get(panel)
      |> PhoenixCommander.Panel.selection_down()

    Map.put(commander, panel, new_panel)
  end
end
