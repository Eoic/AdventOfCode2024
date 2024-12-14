defmodule Mix.Tasks.Day13 do
  require Timer
  require InputUtils

  @input "input.txt"
  @position_pattern ~r/X(\+|\=)(?<x>\d+), Y(\+|\=)(?<y>\d+)/

  defp parse_input() do
    __ENV__.file
    |> InputUtils.read_all(@input)
    |> String.split(~r/\n\n/, trim: true)
    |> Enum.reduce([], fn config, machines ->
      config
      |> String.split(~r/\n/, trim: true)
      |> Enum.map(fn line ->
        %{"x" => x, "y" => y} = Regex.named_captures(@position_pattern, line)
        %{x: String.to_integer(x), y: String.to_integer(y)}
      end)
      |> Kernel.then(fn config ->
        [
          %{
            :A => Enum.at(config, 0),
            :B => Enum.at(config, 1),
            :P => Enum.at(config, 2)
          }
          | machines
        ]
      end)
    end)
  end

  defp compute_cost(machines, offset) do
    machines
    |> Enum.reduce(0, fn machine, sum ->
      a =
        Nx.tensor(
          [
            [machine[:A][:x], machine[:B][:x]],
            [machine[:A][:y], machine[:B][:y]]
          ],
          type: {:f, 64}
        )

      b = Nx.tensor([[machine[:P][:x] + offset], [machine[:P][:y] + offset]], type: {:f, 64})

      result =
        Nx.LinAlg.solve(a, b)
        |> Nx.flatten()
        |> Nx.to_list()
        |> Enum.flat_map(fn number ->
          if abs(round(number) - number) < 0.001,
            do: [round(number)],
            else: []
        end)

      if length(result) !== 2,
        do: sum,
        else: sum + Enum.at(result, 0) * 3 + Enum.at(result, 1)
    end)
  end

  defp part_one(machines), do: compute_cost(machines, 0)

  defp part_two(machines), do: compute_cost(machines, 10_000_000_000_000)

  def run(_) do
    data = Timer.measure(fn -> parse_input() end, "Input")
    p1_result = Timer.measure(fn -> part_one(data) end, "Part 1")
    p2_result = Timer.measure(fn -> part_two(data) end, "Part 2")
    IO.puts("| Part one: #{p1_result} |")
    IO.puts("| Part two: #{p2_result} |")
  end
end
