defmodule Mix.Tasks.Day2 do
  use Mix.Task
  require Timer
  require InputUtils

  @input "input.txt"

  defp parse_input() do
    __ENV__.file
    |> InputUtils.read_lines(@input)
    |> Enum.reduce([], fn line, acc ->
      row =
        line
        |> String.split(~r/\s/, trim: true)
        |> Enum.map(&String.to_integer/1)

      [row | acc]
    end)
    |> Enum.reverse()
  end

  defp dampen(report, index, fun), do: fun.(List.delete_at(report, index))

  defp in_range?(deltas), do: not Enum.any?(deltas, &(abs(&1) not in 1..3))

  defp all_positive?(deltas), do: Enum.all?(deltas, &(&1 > 0))

  defp all_negative?(deltas), do: Enum.all?(deltas, &(&1 < 0))

  defp stable?(report) do
    report
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.map(fn [left, right] -> right - left end)
    |> (&(in_range?(&1) and (all_positive?(&1) or all_negative?(&1)))).()
  end

  defp part_one(data), do: Enum.count(data, &stable?/1)

  defp part_two(data) do
    data
    |> Enum.count(fn report ->
      0..(Enum.count(report) - 1)
      |> Enum.any?(fn index -> dampen(report, index, &stable?/1) end)
    end)
  end

  def run(_) do
    data = parse_input()
    p1_result = Timer.measure(fn -> part_one(data) end, "Part 1")
    p2_result = Timer.measure(fn -> part_two(data) end, "Part 2")
    IO.puts("| Part one: #{p1_result} |")
    IO.puts("| Part two: #{p2_result} |")
  end
end
