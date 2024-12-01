defmodule Mix.Tasks.Day0 do
  use Mix.Task
  require Timer
  require InputUtils

  @input "input.txt"

  defp parse_input() do
    __ENV__.file
    |> InputUtils.read_lines(@input)
  end

  defp part_one(_data) do
    :noop
  end

  defp part_two(_data) do
    :noop
  end

  def run(_) do
    data = parse_input()
    p1_result = Timer.measure(fn -> part_one(data) end, "P1")
    p2_result = Timer.measure(fn -> part_two(data) end, "P2")
    IO.puts("Part one: #{p1_result}.")
    IO.puts("Part two: #{p2_result}.")
  end
end
