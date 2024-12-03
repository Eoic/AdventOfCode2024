defmodule Mix.Tasks.Day3 do
  require InputUtils

  @input "input.txt"
  @mul_pattern ~r/mul\((?<left>\d+),(?<right>\d+)\)/
  @cond_mul_pattern ~r/mul\((?<left>\d+),(?<right>\d+)\)|(do\(\))|(don\'t\(\))/

  defp parse_input(), do: InputUtils.read_all(__ENV__.file, @input)

  defp multiply(token) do
    %{"left" => left, "right" => right} = Regex.named_captures(@mul_pattern, token)
    String.to_integer(left) * String.to_integer(right)
  end

  defp part_one(data) do
    @mul_pattern
    |> Regex.scan(data)
    |> Enum.reduce(0, fn [match | _], total ->
      %{"left" => left, "right" => right} = Regex.named_captures(@mul_pattern, match)
      total + String.to_integer(left) * String.to_integer(right)
    end)
  end

  defp part_two(data) do
    @cond_mul_pattern
    |> Regex.scan(data)
    |> Enum.reduce(%{is_enabled: true, total: 0}, fn [token | _], state ->
      cond do
        String.starts_with?(token, "do()") ->
          %{state | is_enabled: true}

        String.starts_with?(token, "don't()") ->
          %{state | is_enabled: false}

        String.starts_with?(token, "mul") and state.is_enabled ->
          %{state | total: state.total + multiply(token)}

        true ->
          state
      end
    end)
    |> Map.get(:total)
  end

  def run(_) do
    data = parse_input()
    p1_result = Timer.measure(fn -> part_one(data) end, "Part 1")
    p2_result = Timer.measure(fn -> part_two(data) end, "Part 2")
    IO.puts("| Part one: #{p1_result} |")
    IO.puts("| Part two: #{p2_result} |")
  end
end
