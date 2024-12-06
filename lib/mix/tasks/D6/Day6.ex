defmodule Mix.Tasks.Day6 do
  require Timer
  require InputUtils

  @input "input.txt"
  @default_direction [0, -1]
  @directions %{
    [-1, 0] => :left,
    [1, 0] => :right,
    [0, 1] => :down,
    [0, -1] => :up
  }

  defp parse_input() do
    __ENV__.file
    |> InputUtils.read_lines(@input)
    |> Enum.reduce(%{obstacles: MapSet.new(), guard: nil, height: 0}, fn line, grid ->
      line
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.reduce(grid, fn {token, x}, grid = %{:height => y} ->
        case token do
          "#" -> %{grid | :obstacles => MapSet.put(grid.obstacles, [x, y])}
          "^" -> %{grid | :guard => [x, y]}
          _ -> grid
        end
      end)
      |> Map.update(:height, 1, &(&1 + 1))
      |> Map.update(:width, String.length(line), & &1)
    end)
  end

  defp is_inside?([x, y], width, height) do
    x >= 0 and y >= 0 and x < width and y < height
  end

  defp get_tile_action([px, py], grid) do
    cond do
      MapSet.member?(grid.obstacles, [px, py]) -> :turn
      is_inside?([px, py], grid.width, grid.height) -> :walk
      true -> :stop
    end
  end

  defp turn_right(direction) do
    case direction do
      [0, -1] -> [1, 0]
      [1, 0] -> [0, 1]
      [0, 1] -> [-1, 0]
      [-1, 0] -> [0, -1]
    end
  end

  defp apply_direction([px, py], [dx, dy]), do: [px + dx, py + dy]

  defp update_extra_obstacles(
         position = [px, py],
         direction,
         obstacles,
         extra_obstacles
       ) do
    right_side_obstacle =
      case Map.get(@directions, direction) do
        :left ->
          Enum.find(obstacles, fn [_, y] -> py < y end)

        :right ->
          Enum.find(obstacles, fn [_, y] -> py > y end)

        :up ->
          Enum.find(obstacles, fn [x, _] -> px < x end)

        :down ->
          Enum.find(obstacles, fn [x, _] -> px > x end)
      end

    if right_side_obstacle,
      do: MapSet.put(extra_obstacles, apply_direction(position, direction)),
      else: extra_obstacles
  end

  defp trace_route(
         grid,
         position,
         direction,
         route,
         extra_obstacles
       ) do
    route = MapSet.put(route, position)
    next_position = apply_direction(position, direction)
    action = get_tile_action(next_position, grid)

    case action do
      :turn ->
        trace_route(grid, position, turn_right(direction), route, extra_obstacles)

      :walk ->
        extra_obstacles =
          update_extra_obstacles(position, direction, grid.obstacles, extra_obstacles)

        trace_route(grid, next_position, direction, route, extra_obstacles)

      :stop ->
        [route, extra_obstacles]
    end
  end

  defp is_looping?(grid, position, direction, visited) do
    if not MapSet.member?(visited, [position, direction]) do
      next_position = apply_direction(position, direction)

      case get_tile_action(next_position, grid) do
        :turn ->
          visited = MapSet.put(visited, [position, direction])
          is_looping?(grid, position, turn_right(direction), visited)

        :walk ->
          is_looping?(grid, next_position, direction, visited)

        :stop ->
          false
      end
    else
      true
    end
  end

  defp count_loops(grid, extra_obstacles) do
    [px, py] = grid.guard

    extra_obstacles
    |> Map.delete([[px, py - 1], @default_direction, [px, py]])
    |> Stream.filter(fn obstacle ->
      grid = %{grid | :obstacles => MapSet.put(grid.obstacles, obstacle)}
      is_looping?(grid, grid.guard, @default_direction, MapSet.new())
    end)
    |> Enum.count()
  end

  defp part_one(route), do: MapSet.size(route)

  defp part_two(grid, extra_obstacles), do: count_loops(grid, extra_obstacles)

  def run(_) do
    grid = parse_input()

    [route, extra_obstacles] =
      trace_route(grid, grid.guard, @default_direction, MapSet.new(), MapSet.new())

    p1_result = Timer.measure(fn -> part_one(route) end, "Part 1")
    p2_result = Timer.measure(fn -> part_two(grid, extra_obstacles) end, "Part 2")
    IO.puts("| Part one: #{p1_result} |")
    IO.puts("| Part two: #{p2_result} |")
  end
end
