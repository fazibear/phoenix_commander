defmodule PhoenixCommander.Dir do
  def path(path, new_directory) do
    Path.expand(path <> "/" <> new_directory)
  end

  def ls(path) do
    case File.ls(path) do
      {:ok, entries} ->
        {dirs, files} = Enum.split_with(entries, &File.dir?(path(path, &1)))

        [{"..", :up}] ++
          (dirs |> Enum.sort() |> Enum.map(&dirs/1)) ++
          (files |> Enum.sort() |> Enum.map(&files/1))

      _ ->
        [".."]
    end
  end

  defp dirs(dir) do
    {dir, :dir}
  end

  defp files(file) do
    IO.inspect(file)

    case File.stat(file) do
      {:ok, opts} -> {file, opts.size}
      _ -> {file, 0}
    end
  end
end
