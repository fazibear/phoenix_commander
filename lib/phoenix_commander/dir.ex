defmodule PhoenixCommander.Dir do
  def new_path(path, new_directory) do
    new = path(path, new_directory)

    if File.dir?(new) do
      {:ok, new}
    else
      :error
    end
  end

  def path(path, new_directory) do
    Path.expand(path <> "/" <> new_directory)
  end

  def ls(path) do
    case File.ls(path) do
      {:ok, entries} ->
        {dirs, files} = Enum.split_with(entries, &File.dir?(path(path, &1)))

        [{"..", :up}] ++
          (dirs |> Enum.sort() |> Enum.map(&dirs/1)) ++
          (files |> Enum.sort() |> Enum.map(&files(&1, path)))

      _ ->
        [".."]
    end
  end

  defp dirs(dir) do
    {dir, :dir}
  end

  defp files(file, path) do
    case File.stat(path(path, file)) do
      {:ok, opts} -> {file, opts.size}
      _ -> {file, 0}
    end
  end
end
