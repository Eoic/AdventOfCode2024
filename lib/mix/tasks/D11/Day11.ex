defmodule Mix.Tasks.Day11 do
  require Timer
  require InputUtils

  @input "input.txt"

  defp parse_input() do
    __ENV__.file
    |> InputUtils.read_all(@input)
    |> String.split(~r/\s/, trim: true)
    |> Enum.map(&String.to_integer/1)
    |> Enum.reduce(%{}, fn stone, stones ->
      Map.update(stones, stone, 1, &(&1 + 1))
    end)
  end

  defp even_digits?(value) do
    value
    |> Integer.to_string()
    |> String.length()
    |> rem(2)
    |> Kernel.===(0)
  end

  defp apply_rule({value, count}, stones) do
    cond do
      value === 0 ->
        stones
        |> Map.update(0, -count, &(&1 - count))
        |> Map.update(1, count, &(&1 + count))

      even_digits?(value) ->
        value_str = Integer.to_string(value)
        value_len = String.length(value_str)
        {left, right} = String.split_at(value_str, div(value_len, 2))

        stones
        |> Map.update(String.to_integer(left), count, &(&1 + count))
        |> Map.update(String.to_integer(right), count, &(&1 + count))
        |> Map.update(value, -count, fn current -> current - count end)

      true ->
        stones
        |> Map.update(value, -count, &(&1 - count))
        |> Map.update(value * 2024, count, &(&1 + count))
    end
  end

  defp apply_all(_, stones) do
    Enum.reduce(stones, stones, &apply_rule/2)
  end

  defp blink(stones, count) do
    Enum.reduce(0..(count - 1)//1, stones, &apply_all/2)
  end

  defp count_stones(stones, blinks) do
    stones
    |> blink(blinks)
    |> Map.filter(fn {_, count} -> count > 0 end)
    |> Map.to_list()
    |> Enum.reduce(0, fn {_, count}, sum -> sum + count end)
  end

  defp part_one(stones), do: count_stones(stones, 25)

  defp part_two(stones), do: count_stones(stones, 75)

  def run(_) do
    data = Timer.measure(fn -> parse_input() end, "Input")
    p1_result = Timer.measure(fn -> part_one(data) end, "Part 1")
    p2_result = Timer.measure(fn -> part_two(data) end, "Part 2")
    IO.puts("| Part one: #{p1_result} |")
    IO.puts("| Part two: #{p2_result} |")
  end
end
