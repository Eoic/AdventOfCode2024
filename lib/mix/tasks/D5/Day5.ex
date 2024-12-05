defmodule Mix.Tasks.Day5 do
  require Timer
  require InputUtils

  @input "input.txt"

  defp parse_input() do
    [rule_lines, update_lines] =
      __ENV__.file
      |> InputUtils.read_all(@input)
      |> String.split(~r/\n\n/)

    [parse_rules(rule_lines), parse_updates(update_lines)]
  end

  defp parse_rules(rule_lines) do
    rule_lines
    |> String.split(~r/\n/)
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
    |> String.split(~r/\n/, trim: true)
    |> Enum.map(fn line ->
      line
      |> String.split(~r/\,/)
      |> Enum.map(&String.to_integer/1)
    end)
  end

  defp find_split_updates([rules, updates]) do
    Enum.reduce(updates, %{valid: [], invalid: []}, fn line, groups ->
      sorted_line = Enum.sort(line, &(&2 in Map.get(rules, &1, [])))

      if line === sorted_line,
        do: %{groups | valid: [line | Map.get(groups, :valid)]},
        else: %{groups | invalid: [sorted_line | Map.get(groups, :invalid)]}
    end)
  end

  defp sum_medians(updates), do: Enum.reduce(updates, 0, &(&2 + Enum.at(&1, div(length(&1), 2))))

  def run(_) do
    %{:valid => valid, :invalid => invalid} = find_split_updates(parse_input())
    p1_result = Timer.measure(fn -> sum_medians(valid) end, "Part 1")
    p2_result = Timer.measure(fn -> sum_medians(invalid) end, "Part 2")
    IO.puts("| Part one: #{p1_result} |")
    IO.puts("| Part two: #{p2_result} |")
  end
end
