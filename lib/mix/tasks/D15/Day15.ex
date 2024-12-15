defmodule Mix.Tasks.Day15 do
  require Timer
  require InputUtils

  @input "sample.txt"

  defp parse_map(map) do
    map
    |> String.split(~r/\n/, trim: true)
    |> Enum.reduce(%{width: 0, height: 0, grid: %{}, robot: nil}, fn line,
                                                                     map = %{:height => y} ->
      line
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.reduce(map, fn {cell, x}, map ->
        [map, grid] =
          if cell === "@" do
            map = Map.put(map, :robot, [x, y])
            [map, Map.put(map.grid, [x, y], ".")]
          else
            [map, Map.put(map.grid, [x, y], cell)]
          end

        %{map | width: x + 1, grid: grid}
      end)
      |> Map.update(:height, y + 1, &(&1 + 1))
    end)
  end

  defp parse_ops(ops) do
    ops
    |> String.split(~r/\n/)
    |> Enum.join()
    |> String.graphemes()
  end

  defp parse_input() do
    __ENV__.file
    |> InputUtils.read_all(@input)
    |> String.split(~r/\n\n/, trim: true)
    |> Kernel.then(fn [map_str, ops_str] ->
      %{
        :map => parse_map(map_str),
        :ops => parse_ops(ops_str)
      }
    end)
  end

  defp render(map, wide) do
    0..(map.height - 1)
    |> Enum.each(fn y ->
      0..(map.width - 1)
      |> Enum.each(fn x ->
        cell = Map.get(map.grid, [x, y])

        if wide === true do
          if [x, y] === map.robot do
            IO.write("@.")
          else
            if cell === "O" do
              IO.write("[]")
            else
              IO.write("#{cell}#{cell}")
            end
          end
        else
          if [x, y] === map.robot do
            IO.write("@")
          else
            IO.write(cell)
          end
        end
      end)

      IO.puts("")
    end)
  end

  defp sum_gps(map) do
    map.grid
    |> Map.filter(fn {_, cell} -> cell === "O" end)
    |> Enum.reduce(0, fn {[x, y], _}, sum -> sum + (y * 100 + x) end)
  end

  defp get_cells([x, y], [width, height], direction, grid) do
    case direction do
      "<" -> for cx <- (x - 1)..0//-1, into: [], do: {[cx, y], Map.get(grid, [cx, y])}
      ">" -> for cx <- (x + 1)..(width - 1)//1, into: [], do: {[cx, y], Map.get(grid, [cx, y])}
      "v" -> for cy <- (y + 1)..(height - 1)//1, into: [], do: {[x, cy], Map.get(grid, [x, cy])}
      "^" -> for cy <- (y - 1)..0//-1, into: [], do: {[x, cy], Map.get(grid, [x, cy])}
    end
  end

  defp try_push(robot = [rx, ry], cells, grid) do
    immediate_cell = Enum.at(cells, 0)

    case immediate_cell do
      nil ->
        [robot, grid]

      {_, "#"} ->
        [robot, grid]

      {[x, y], "O"} ->
        {_, remaining_cells} = Enum.split(cells, 1)

        {free_space, count} =
          Enum.reduce_while(remaining_cells, {nil, 0}, fn cell, {last_space, count} ->
            case cell do
              {[x, y], "."} -> {:halt, {[x, y], count + 1}}
              {_, "#"} -> {:halt, {last_space, count + 1}}
              {_, "O"} -> {:cont, {nil, count + 1}}
            end
          end)

        if free_space !== nil do
          [dx, dy] = [x - rx, y - ry]
          {pushable_cells, _} = Enum.split(cells, count)

          grid =
            pushable_cells
            |> Enum.reverse()
            |> Enum.reduce(grid, fn {[x, y], cell}, grid ->
              [nx, ny] = [x + dx, y + dy]

              grid
              |> Map.put([x, y], ".")
              |> Map.put([nx, ny], cell)
            end)

          [[rx + dx, ry + dy], grid]
        else
          [robot, grid]
        end

      {[x, y], "."} ->
        [[x, y], grid]
    end
  end

  defp part_one(%{:map => map, :ops => ops}) do
    ops
    |> Enum.reduce(map, fn op, map ->
      visible_cells = get_cells(map.robot, [map.width, map.height], op, map.grid)
      [robot, grid] = try_push(map.robot, visible_cells, map.grid)
      %{map | grid: grid, robot: robot}
    end)
    |> sum_gps()
  end

  defp part_two(%{:map => map, :ops => ops}) do
    IO.puts("--- Initial, ---")
    render(map, true)
    IO.puts("---")
  end

  def run(_) do
    data = parse_input()
    part_two(data)
    # p1_result = Timer.measure(fn -> part_one(data) end, "Part 1")
    # p2_result = Timer.measure(fn -> part_two(data) end, "Part 2")
    # IO.puts("| Part one: #{p1_result} |")
    # IO.puts("| Part two: #{p2_result} |")
  end
end
