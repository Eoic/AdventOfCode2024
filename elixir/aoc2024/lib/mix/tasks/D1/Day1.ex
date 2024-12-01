defmodule Mix.Tasks.Day1 do
  use Mix.Task
  import InputUtils

  @input "input.txt"

  def parse_input() do
    __ENV__.file
    |> read_lines(@input)
    |> Stream.map(fn line ->
      line
      |> String.split(~r/\s/, trim: true)
      |> Enum.map(&String.to_integer/1)
    end)
    |> Stream.zip()
    |> Stream.map(fn items ->
      items
      |> Tuple.to_list()
      |> Enum.sort()
    end)
    |> Enum.to_list()
  end

  def part_one(data) do
    data
    |> Enum.zip()
    |> Enum.reduce(0, &(&2 + abs(elem(&1, 0) - elem(&1, 1))))
  end

  def part_two([left, right]) do
    freq = Enum.frequencies(right)
    Enum.reduce(left, 0, &(&2 + Map.get(freq, &1, 0) * &1))
  end

  def run(_) do
    data = parse_input()
    IO.puts("Part one: #{part_one(data)}.")
    IO.puts("Part two: #{part_two(data)}.")
  end
end
