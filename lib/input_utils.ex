defmodule InputUtils do
  def read_lines(cwd, path) do
    cwd
    |> Path.dirname()
    |> Path.join(path)
    |> File.stream!()
    |> Stream.map(&String.trim/1)
  end
end
