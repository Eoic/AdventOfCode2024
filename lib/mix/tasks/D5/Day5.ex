defmodule Mix.Tasks.Day5 do
  require Timer
  require InputUtils

  @input "input.txt"

  defp parse_input() do
    [rule_lines, update_lines] =
      __ENV__.file
      |> InputUtils.read_all(@input)
      |> String.trim()
      |> String.split(~r/\r\n\r\n/)

    [parse_rules(rule_lines), parse_updates(update_lines)]
  end

  defp parse_rules(rule_lines) do
    rule_lines
    |> String.split(~r/\r\n/)
    |> Enum.reduce(%{}, fn line, acc ->
      [left, right] =
        line
        |> String.split("|")
        |> Enum.map(&String.to_integer/1)

      Map.update(acc, left, [right], &[right | &1])
    end)
  end

  defp parse_updates(update_lines) do
    update_lines
    |> String.split(~r/\r\n/, trim: true)
    |> Enum.map(fn line ->
      line
      |> String.split(",", trim: true)
      |> Enum.map(&String.to_integer/1)
    end)
  end

  defp find_valid_updates([rules, updates]) do
    Enum.filter(updates, fn line -> line === Enum.sort(line, &(&2 in Map.get(rules, &1, []))) end)
  end

  defp find_invalid_updates([rules, updates]) do
    Enum.flat_map(updates, fn line ->
      sorted_line = Enum.sort(line, &(&2 in Map.get(rules, &1, [])))
      if sorted_line !== line, do: [sorted_line], else: []
    end)
  end

  defp sum_medians(updates) do
    Enum.reduce(updates, 0, &(&2 + Enum.at(&1, div(length(&1), 2))))
  end

  defp part_one(data) do
    data
    |> find_valid_updates()
    |> sum_medians()
  end

  defp part_two(data) do
    data
    |> find_invalid_updates()
    |> sum_medians()
  end

  def run(_) do
    data = parse_input()
    p1_result = Timer.measure(fn -> part_one(data) end, "Part 1")
    p2_result = Timer.measure(fn -> part_two(data) end, "Part 2")
    IO.puts("| Part one: #{p1_result} |")
    IO.puts("| Part two: #{p2_result} |")
  end
end
