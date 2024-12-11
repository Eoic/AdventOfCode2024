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

  def apply_rule(value, stones, change) do
    cond do
      value === 0 ->
        stones
        |> Map.update(0, -change, &(&1 - change))
        |> Map.update(1, change, &(&1 + change))

      even_digits?(value) ->
        value_str = Integer.to_string(value)
        value_len = String.length(value_str)
        {left, right} = String.split_at(value_str, div(value_len, 2))

        stones
        |> Map.update(String.to_integer(left), change, fn current -> current + change end)
        |> Map.update(String.to_integer(right), change, fn current -> current + change end)
        |> Map.update(value, -change, fn current -> current - change end)

      true ->
        stones
        |> Map.update(value, -change, fn current -> current - change end)
        |> Map.update(value * 2024, change, fn current -> current + change end)
    end
  end

  @spec apply_all(:maps.iterator(any(), any()) | map()) :: any()
  def apply_all(stones) do
    stones
    |> Map.to_list()
    |> Enum.reduce(stones, fn {value, count}, stones ->
      apply_rule(value, stones, count)
    end)
  end

  def blink(stones, count) do
    0..(count - 1)//1
    |> Enum.reduce(stones, fn _, stones -> apply_all(stones) end)
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
