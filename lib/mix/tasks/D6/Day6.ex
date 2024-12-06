defmodule Mix.Tasks.Day6 do
  require Timer
  require InputUtils

  @input "sample.txt"
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
      tiles = String.graphemes(line)

      tiles
      |> Enum.with_index()
      |> Enum.reduce(grid, fn {token, x}, grid = %{:obstacles => obstacles, :height => y} ->
        case token do
          "#" -> %{grid | :obstacles => MapSet.put(obstacles, [x, y])}
          "^" -> %{grid | :guard => [x, y]}
          _ -> grid
        end
      end)
      |> Map.update(:height, 1, &(&1 + 1))
      |> Map.update(:width, length(tiles), & &1)
    end)
  end

  def is_inside_map?([x, y], width, height) do
    x >= 0 and y >= 0 and x < width and y < height
  end

  def get_tile_action([px, py], obstacles, width, height) do
    cond do
      MapSet.member?(obstacles, [px, py]) -> :turn
      is_inside_map?([px, py], width, height) -> :walk
      true -> :stop
    end
  end

  def turn_right(direction) do
    case direction do
      [0, -1] -> [1, 0]
      [1, 0] -> [0, 1]
      [0, 1] -> [-1, 0]
      [-1, 0] -> [0, -1]
    end
  end

  def apply_direction([px, py], [dx, dy]), do: [px + dx, py + dy]

  def update_extra_obstacles(position = [px, py], direction = [dx, dy], obstacles, loops) do
    right_side_obstacle =
      case Map.get(@directions, direction, nil) do
        :left ->
          Enum.find(obstacles, fn [_, y] -> py < y end)

        :right ->
          Enum.find(obstacles, fn [_, y] -> py > y end)

        :up ->
          Enum.find(obstacles, fn [x, _] -> px < x end)

        :down ->
          Enum.find(obstacles, fn [x, _] -> px > x end)
      end

    if right_side_obstacle do
      [ox, oy] = apply_direction(position, direction)

      if MapSet.member?(loops, [[ox, oy], [dx, dy], [px, py]]) do
        loops
      else
        MapSet.put(loops, [[ox, oy], [dx, dy], [px, py]])
      end
    else
      loops
    end
  end

  def solve_route(
        obstacles,
        width,
        height,
        position,
        direction,
        route,
        loops
      ) do
    route = MapSet.put(route, position)
    next_position = apply_direction(position, direction)
    action = get_tile_action(next_position, obstacles, width, height)

    case action do
      :turn ->
        solve_route(obstacles, width, height, position, turn_right(direction), route, loops)

      :walk ->
        loops = update_extra_obstacles(position, direction, obstacles, loops)

        solve_route(
          obstacles,
          width,
          height,
          next_position,
          direction,
          route,
          loops
        )

      :stop ->
        [route, loops]
    end
  end

  def solve_loop_route(
        obstacles,
        width,
        height,
        position,
        direction,
        visited,
        is_first_time
      ) do
    if not is_first_time and MapSet.member?(visited, [position, direction]) do
      true
    else
      next_position = apply_direction(position, direction)
      action = get_tile_action(next_position, obstacles, width, height)

      case action do
        :turn ->
          visited = MapSet.put(visited, [position, direction])

          solve_loop_route(
            obstacles,
            width,
            height,
            position,
            turn_right(direction),
            visited,
            false
          )

        :walk ->
          solve_loop_route(
            obstacles,
            width,
            height,
            next_position,
            direction,
            visited,
            false
          )

        :stop ->
          false
      end
    end
  end

  def traverse(%{
        :obstacles => obstacles,
        :width => width,
        :height => height,
        :guard => guard
      }) do
    solve_route(obstacles, width, height, guard, [0, -1], MapSet.new(), MapSet.new())
  end

  defp count_loops(
         %{
           :obstacles => obstacles,
           :width => width,
           :height => height,
           :guard => guard
         },
         extra_obstacles
       ) do
    [px, py] = guard
    extra_obstacles = Map.delete(extra_obstacles, [[px, py - 1], [0, -1], [px, py]])

    Enum.flat_map(extra_obstacles, fn [obstacle, direction, position] ->
      obstacles = MapSet.put(obstacles, obstacle)
      is_looping = solve_loop_route(obstacles, width, height, guard, [0, -1], MapSet.new(), true)

      if is_looping do
        [obstacle]
      else
        []
      end
    end)
    |> Enum.uniq()
    |> Enum.count()
  end

  defp part_one(route) do
    MapSet.size(route)
  end

  defp part_two(map, loops) do
    count_loops(map, loops)
  end

  def run(_) do
    map = parse_input()
    [route, extra_obstacles] = traverse(map)
    p1_result = Timer.measure(fn -> part_one(route) end, "Part 1")
    p2_result = Timer.measure(fn -> part_two(map, extra_obstacles) end, "Part 2")
    IO.puts("| Part one: #{p1_result} |")
    IO.puts("| Part two: #{p2_result} |")
  end
end
