defmodule Mix.Tasks.Day10 do
  require Timer
  require InputUtils

  @input "sample1.txt"

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

  def is_valid_next?({[x, y], cell}, {[next_x, next_y], next_cell}, visited) do
    next_cell - cell === 1 and
      abs(x - next_x + (y - next_y)) === 1 and
      not MapSet.member?(visited, {[next_x, next_y], next_cell})
  end

  # def traverse(_, [], visited), do: visited

  # def traverse(current, remaining, visited) do
  #   visited = [current | visited]
  #   next_position = Enum.find(remaining, fn next -> is_valid_next?(current, next, visited) end)

  #   if next_position do
  #     remaining = Enum.filter(remaining, fn item -> next_position !== item end)
  #     traverse(next_position, remaining, visited)
  #   else
  #     visited
  #   end
  # end

  # def traverse(_, [], visited, branch_starts), do: [visited, branch_starts]

  # def traverse(current, remaining, visited, branch_starts) do
  #   visited = MapSet.put(visited, current)
  #   next_positions = Enum.filter(remaining, fn next -> is_valid_next?(current, next, visited) end)

  #   [next_position, branch_starts] =
  #     if length(next_positions) > 0 do
  #       [hd(next_positions), branch_starts ++ tl(next_positions)]
  #     else
  #       [nil, branch_starts]
  #     end

  #   if next_position do
  #     remaining = Enum.filter(remaining, fn item -> next_position !== item end)
  #     traverse(next_position, remaining, visited, branch_starts)
  #   else
  #     [visited, branch_starts]
  #   end
  # end

  def traverse_bfs([], _, _visited, path), do: path

  def traverse_bfs([current | tail], positions, visited, path) do
    [visited, path] =
      if not MapSet.member?(visited, current) do
        visited = MapSet.put(visited, current)
        [visited, path]
      else
        [visited, path]
      end

    path = [current | path]
    next_positions = Enum.filter(positions, fn next -> is_valid_next?(current, next, visited) end)
    to_visit = tail ++ next_positions
    traverse_bfs(to_visit, positions, visited, path)
  end

  defp part_one(data) do
    [Enum.at(data.starts, 0)]
    |> Enum.map(fn start ->
      traverse_bfs([start], Map.to_list(data.grid), MapSet.new(), [])
      # |> MapSet.filter(fn {[_, _], cell} -> cell === 9 end)

      # |> MapSet.size()

      # |> map_size()
    end)
    |> IO.inspect()

    :noop
  end

  defp part_two(data) do
  end

  def run(_) do
    data = Timer.measure(fn -> parse_input() end, "Input")
    p1_result = Timer.measure(fn -> part_one(data) end, "Part 1")
    # p2_result = Timer.measure(fn -> part_two(data) end, "Part 2")
    # IO.puts("| Part one: #{p1_result} |")
    # IO.puts("| Part two: #{p2_result} |")
  end
end
