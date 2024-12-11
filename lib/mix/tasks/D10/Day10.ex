defmodule Mix.Tasks.Day10 do
  require Timer
  require InputUtils

  @input "sample3.txt"

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

  def is_neighbor?({[cx, cy], current_cell}, {[nx, ny], next_cell}, visited) do
    next_cell - current_cell === 1 and
      abs(cx - nx) + abs(cy - ny) === 1 and
      not MapSet.member?(visited, [nx, ny])
  end

  def traverse([], _, _visited, path), do: Enum.reverse(path)

  def traverse([current = {[cx, cy], _cell} | tail], positions, visited, path) do
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

  def count_junctions([], _, counts), do: counts

  def count_junctions([current = {[x, y], cell} | path], positions, counts) do
    neighbors = Enum.filter(positions, fn next -> is_neighbor?(current, next, MapSet.new()) end)

    counts =
      Map.update(counts, {[x, y], cell}, length(neighbors), fn current_count ->
        IO.inspect("ALARM!")
        length(neighbors) + current_count
      end)

    count_junctions(path, positions, counts)
  end

  defp part_one(data) do
    data.starts
    |> Enum.map(fn start ->
      traverse([start], Map.to_list(data.grid), MapSet.new(), [])
      |> Enum.filter(fn {_, cell} -> cell === 9 end)
      |> Enum.count()
    end)
    |> Enum.sum()
  end

  defp part_two(data) do
    data.starts
    |> Enum.map(fn start ->
      [start]
      |> traverse(Map.to_list(data.grid), MapSet.new(), [])
      |> Kernel.then(fn path -> count_junctions(path, path, %{}) end)
      |> IO.inspect()

      # |> Map.to_list()
      # |> Enum.map(fn {[x, y], count} -> count end)
      # |> Enum.sum()
      # |> Kernel.then(fn sum -> sum - 9 end)
      # |> Enum.frequencies_by(fn {[_, _], cell} -> cell end)

      # |> count_alternative_paths(MapSet.new(), 0)

      # |> IO.inspect()
    end)

    # |> Enum.sum()
  end

  def run(_) do
    data = Timer.measure(fn -> parse_input() end, "Input")
    p1_result = Timer.measure(fn -> part_one(data) end, "Part 1")
    p2_result = Timer.measure(fn -> part_two(data) end, "Part 2")
    # IO.puts("| Part one: #{p1_result} |")
    # IO.puts("| Part two: #{p2_result} |")
  end
end
