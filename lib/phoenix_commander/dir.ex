defmodule PhoenixCommander.Dir do
  def ls(path) do
    case File.ls(path) do
      {:ok, entries} ->
        {dirs, files} = Enum.split_with(entries, &File.dir?(path(path, &1)))

        [".."] ++ Enum.sort(dirs) ++ Enum.sort(files)

      _ ->
        [".."]
    end
  end

  def path(path, new_directory) do
    Path.expand(path <> "/" <> new_directory)
  end
end
