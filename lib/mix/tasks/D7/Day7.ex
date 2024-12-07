defmodule Mix.Tasks.Day7 do
  require Timer
  require InputUtils

  @input "input.txt"

  defp parse_input() do
    __ENV__.file
    |> InputUtils.read_lines(@input)
    |> Enum.reduce([], fn line, equations ->
      [result, tokens] = String.split(line, ":", trim: true)

      numbers =
        tokens
        |> String.split(" ", trim: true)
        |> Enum.map(&String.to_integer/1)

      [[numbers, String.to_integer(result)] | equations]
    end)
  end

  defp generate_ops(position, size, ops_base, ops_cache) do
    if Map.has_key?(ops_cache, [position, size]) do
      [Map.get(ops_cache, [position, size]), ops_cache]
    else
      ops =
        position
        |> Integer.to_string(ops_base)
        |> String.pad_leading(size, "0")
        |> String.graphemes()
        |> Enum.map(fn bit ->
          cond do
            bit === "0" -> &Kernel.+/2
            bit === "1" -> &Kernel.*/2
            bit === "2" -> &String.to_integer("#{&1}#{&2}")
          end
        end)

      [ops, Map.put(ops_cache, [position, size], ops)]
    end
  end

  defp evaluate([first | rest], ops) do
    rest
    |> Enum.with_index()
    |> Enum.reduce(first, fn {current, index}, prev ->
      Enum.at(ops, index).(prev, current)
    end)
  end

  defp solve_equation([variables, target], ops_base, ops_cache) do
    size = length(variables) - 1

    [result, ops_cache] =
      0..(trunc(:math.pow(ops_base, size)) - 1)
      |> Enum.reduce_while([0, ops_cache], fn position, [_, ops_cache] ->
        [ops, ops_cache] = generate_ops(position, size, ops_base, ops_cache)
        result = evaluate(variables, ops)

        if result === target,
          do: {:halt, [result, ops_cache]},
          else: {:cont, [0, ops_cache]}
      end)

    [result, ops_cache]
  end

  defp sum_solved(equations, ops_base) do
    [result, _] =
      equations
      |> Enum.reduce([0, Map.new()], fn equation, [total, ops_cache] ->
        [result, ops_cache] = solve_equation(equation, ops_base, ops_cache)
        [total + result, ops_cache]
      end)

    result
  end

  defp part_one(equations), do: sum_solved(equations, 2)

  defp part_two(equations), do: sum_solved(equations, 3)

  def run(_) do
    data = parse_input()
    p1_result = Timer.measure(fn -> part_one(data) end, "Part 1")
    p2_result = Timer.measure(fn -> part_two(data) end, "Part 2")
    IO.puts("| Part one: #{p1_result} |")
    IO.puts("| Part two: #{p2_result} |")
  end
end
