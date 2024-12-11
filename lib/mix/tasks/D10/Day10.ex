defmodule Mix.Tasks.Day10 do
  require Timer
  require InputUtils

  @input "sample2.txt"

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

  # def get_lowest_unvisited(positions, visited) do
  #   Enum.find(positions, fn position -> not MapSet.member?(visited, position) end)
  # end

  def traverse([], _, _visited, path), do: Enum.reverse(path)

  def traverse([current = {[cx, cy], cell} | tail], positions, visited, path) do
    if cell === 9 do
      IO.inspect(["Visited 9", [cx, cy]])
    end

    if MapSet.member?(visited, [cx, cy]) do
      traverse(tail, positions, visited, path)
    else
      visited = MapSet.put(visited, [cx, cy])

      neighbors =
        positions
        |> Enum.filter(fn next -> is_neighbor?(current, next, visited) end)
        |> Enum.sort_by(fn {[_x, _y], cell} -> cell end)

      if length(neighbors) === 0 and cell !== 9 do
        IO.inspect(["Dead end at", {[cx, cy], cell}], charlists: :as_lists)
      end

      traverse(tail ++ neighbors, positions, visited, [current | path])
    end
  end

  # def trace_path(current, positions, visited, path) do
  #   visited = MapSet.put(visited, current)
  #   next = Enum.find(positions, fn next -> is_neighbor?(current, next, MapSet.new()) end)

  #   if next === nil do
  #     {[current | path], visited}
  #   else
  #     trace_path(next, positions, visited, [current | path])
  #   end
  # end

  # def count_alternative_paths(path, visited, alt_path_count) do
  #   unvisited = get_lowest_unvisited(path, visited)

  #   if unvisited === nil do
  #     alt_path_count
  #   else
  #     {alt_path, visited} = trace_path(unvisited, path, visited, [])
  #     IO.inspect(alt_path)
  #     count_alternative_paths(path, visited, alt_path_count + 1)
  #   end
  # end

  def count_junctions([], _, counts), do: counts

  def count_junctions([current = {[x, y], cell} | path], positions, counts) do
    neighbors = Enum.filter(positions, fn next -> is_neighbor?(current, next, MapSet.new()) end)

    counts =
      Map.update(counts, [x, y], length(neighbors), fn current_count ->
        length(neighbors)
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
      # |> Kernel.then(fn path -> count_junctions(path, path, %{}) end)
      # |> Map.to_list()
      # |> Enum.map(fn {[x, y], count} -> count end)
      # |> Enum.sum()
      # |> Kernel.then(fn sum -> sum - 9 end)
      # |> Enum.frequencies_by(fn {[_, _], cell} -> cell end)
      |> IO.inspect()

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
