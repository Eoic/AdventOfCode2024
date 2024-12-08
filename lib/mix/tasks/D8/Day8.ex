defmodule Mix.Tasks.Day8 do
  require Timer
  require InputUtils

  @input "input.txt"

  defp parse_input() do
    __ENV__.file
    |> InputUtils.read_lines(@input)
    |> Enum.reduce(%{width: 0, height: 0, antennas: %{}}, fn row, state = %{:height => y} ->
      row
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.reduce(state, fn {cell, x}, state ->
        antennas =
          if cell !== ".",
            do: Map.update(state.antennas, cell, [[x, y]], &[[x, y] | &1]),
            else: state.antennas

        %{state | width: x + 1, antennas: antennas}
      end)
      |> Map.update(:height, y + 1, &(&1 + 1))
    end)
  end

  defp valid_position?([x, y], size) do
    x >= 0 and y >= 0 and x < size.width and y < size.height
  end

  defp resonate([dx, dy], [cx, cy], size, positions) do
    [x, y] = [cx - dx, cy - dy]

    if valid_position?([x, y], size),
      do: resonate([dx, dy], [x, y], size, [[x, y] | positions]),
      else: positions
  end

  defp collect_antinodes([], _, _, antinodes), do: antinodes

  defp collect_antinodes([[cx, cy] | tail], size, resonate?, antinodes) do
    antinodes =
      tail
      |> Enum.flat_map(fn [sx, sy] ->
        [dx1, dy1] = [sx - cx, sy - cy]
        [dx2, dy2] = [cx - sx, cy - sy]
        antinodes = [[cx - dx1, cy - dy1], [sx - dx2, sy - dy2]]

        resonant_antinodes =
          if resonate? do
            left_resonances = resonate([dx1, dy1], [cx, cy], size, [])
            right_resonances = resonate([dx2, dy2], [sx, sy], size, [])
            [[cx, cy] | left_resonances] ++ [[sx, sy] | right_resonances]
          else
            []
          end

        antinodes ++ resonant_antinodes
      end)
      |> Enum.concat(antinodes)

    collect_antinodes(tail, size, resonate?, antinodes)
  end

  defp find_all_antinodes(data, resonate) do
    size = %{width: data.width, height: data.height}

    data.antennas
    |> Map.values()
    |> Enum.flat_map(fn positions ->
      collect_antinodes(positions, size, resonate, [])
    end)
    |> Enum.filter(fn position -> valid_position?(position, size) end)
    |> Enum.uniq()
    |> Enum.count()
  end

  defp part_one(data), do: find_all_antinodes(data, false)

  defp part_two(data), do: find_all_antinodes(data, true)

  def run(_) do
    data = parse_input()
    p1_result = Timer.measure(fn -> part_one(data) end, "Part 1")
    p2_result = Timer.measure(fn -> part_two(data) end, "Part 2")
    IO.puts("| Part one: #{p1_result} |")
    IO.puts("| Part two: #{p2_result} |")
  end
end
