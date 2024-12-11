defmodule Mix.Tasks.Day10 do
  require Timer
  require InputUtils

  @input "input.txt"

  defp parse_input() do
    __ENV__.file
    |> InputUtils.read_all(@input)
    |> String.split(~r/\n/)
    |> Enum.reduce(%{width: 0, height: 0, grid: %{}, starts: []}, fn row, map = %{:height => y} ->
      row
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.reduce(map, fn {cell, x}, map ->
        cell = String.to_integer(cell)

        map =
          if cell == 0 do
            %{map | starts: [{[x, y], 0} | map.starts]}
          else
            %{map | grid: Map.put(map.grid, [x, y], cell)}
          end

        %{map | width: x + 1}
      end)
      |> Map.update(:height, y + 1, &(&1 + 1))
    end)
    |> Kernel.then(fn map -> %{map | width: map.width + 1} end)
  end

  def is_neighbor?({[x, y], cell}, {[next_x, next_y], next_cell}, visited) do
    next_cell - cell === 1 and
      abs(x - next_x) + abs(y - next_y) === 1 and
      not MapSet.member?(visited, [next_x, next_y])
  end

  def traverse([], _, _visited, path), do: path

  def traverse([current = {[cx, cy], _} | tail], positions, visited, path) do
    if MapSet.member?(visited, [cx, cy]) do
      traverse(tail, positions, visited, path)
    else
      visited = MapSet.put(visited, [cx, cy])

      neighbors =
        positions
        |> Enum.filter(fn next -> is_neighbor?(current, next, visited) end)
        |> Enum.sort_by(fn {[_x, _y], cell} -> cell end)

      traverse(tail ++ neighbors, positions, visited, [current | path])
    end
  end

  # defp part_one(data) do
  #   data.starts
  #   |> Enum.map(fn start ->
  #     # IO.inspect(start, label: "Start")
  #     traverse([start], Map.to_list(data.grid), MapSet.new(), [])
  #     |> Enum.filter(fn {[x, y], cell} -> cell === 9 end)
  #     |> Enum.count()

  #     # |> MapSet.filter(fn {[x, y], c} -> c === 9 end)
  #     # |> MapSet.size()
  #     # |> IO.inspect()

  #     # |> Map.filter(fn {[x, y], 9} -> [x, y] end)
  #   end)
  #   |> Enum.sum()
  #   |> IO.inspect()

  #   # |> IO.inspect()

  #   :noop
  # end

  defp part_two(data) do
    IO.inspect(data.starts |> length())

    data.starts
    |> Enum.map(fn start ->
      # IO.inspect(start, label: "Start")
      traverse([start], Map.to_list(data.grid), MapSet.new(), [])
      |> Enum.frequencies_by(fn {[x, y], cell} -> cell end)
      |> Map.to_list()
      |> Enum.map(fn {k, el} -> el end)
      |> Enum.count()

      # |> Enum.filter(fn {[x, y], cell} -> cell === 9 end)
      # |> Enum.count()

      # |> MapSet.filter(fn {[x, y], c} -> c === 9 end)
      # |> MapSet.size()
      # |> IO.inspect()

      # |> Map.filter(fn {[x, y], 9} -> [x, y] end)
    end)
    |> Enum.sum()
    |> IO.inspect()

    # |> IO.inspect()

    :noop
  end

  def run(_) do
    data = Timer.measure(fn -> parse_input() end, "Input")
    # p1_result = Timer.measure(fn -> part_one(data) end, "Part 1")
    p2_result = Timer.measure(fn -> part_two(data) end, "Part 2")
    # IO.puts("| Part one: #{p1_result} |")
    # IO.puts("| Part two: #{p2_result} |")
  end
end
