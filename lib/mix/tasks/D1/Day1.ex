defmodule Mix.Tasks.Day1 do
  use Mix.Task
  require Timer
  require InputUtils
  require Logger

  @input "input.txt"

  defp parse_input() do
    __ENV__.file
    |> InputUtils.read_lines(@input)
    |> Enum.reduce({[], []}, fn line, acc ->
      [left, right] =
        line
        |> String.split(~r/\s/, trim: true)
        |> Enum.map(&String.to_integer/1)

      {[left | elem(acc, 0)], [right | elem(acc, 1)]}
    end)
  end

  defp part_one(data) do
    data
    |> Tuple.to_list()
    |> Enum.map(&Enum.sort/1)
    |> Enum.zip()
    |> Enum.reduce(0, &(&2 + abs(elem(&1, 0) - elem(&1, 1))))
  end

  defp part_two({left, right}) do
    freq = Enum.frequencies(right)
    Enum.reduce(left, 0, &(&2 + Map.get(freq, &1, 0) * &1))
  end

  def run(_) do
    data = Timer.measure(fn -> parse_input() end, "IO")
    p1_result = Timer.measure(fn -> part_one(data) end, "Part 1")
    p2_result = Timer.measure(fn -> part_two(data) end, "Part 2")
    IO.puts("| Part one: #{p1_result} |")
    IO.puts("| Part two: #{p2_result} |")
  end
end
