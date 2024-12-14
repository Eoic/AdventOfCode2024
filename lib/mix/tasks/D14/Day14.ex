defmodule Robot do
  @enforce_keys [:position, :velocity]
  defstruct [:position, :velocity]
end

defmodule Mix.Tasks.Day14 do
  require Timer
  require InputUtils

  @width 101
  @height 103
  @input "input.txt"
  @position_pattern ~r/p=(?<px>-?\d+),(?<py>-?\d+) v=(?<vx>-?\d+),(?<vy>-?\d+)/

  defp parse_input() do
    __ENV__.file
    |> InputUtils.read_lines(@input)
    |> Enum.to_list()
    |> Enum.reduce([], fn line, robots ->
      %{"px" => px, "py" => py, "vx" => vx, "vy" => vy} =
        Regex.named_captures(@position_pattern, line)

      position = {String.to_integer(px), String.to_integer(py)}
      velocity = {String.to_integer(vx), String.to_integer(vy)}
      [%Robot{position: position, velocity: velocity} | robots]
    end)
  end

  defp step(robot) do
    {px, py} = robot.position
    {vx, vy} = robot.velocity
    [nx, ny] = [px + vx, py + vy]
    nx = if nx < 0, do: nx + @width, else: if(nx >= @width, do: rem(nx, @width), else: nx)
    ny = if ny < 0, do: ny + @height, else: if(ny >= @height, do: rem(ny, @height), else: ny)
    %{robot | position: {nx, ny}}
  end

  def compute_safety(robots) do
    qx = floor(div(@width, 2))
    qy = floor(div(@height, 2))

    freq =
      robots
      |> Enum.frequencies_by(fn robot -> robot.position end)
      |> Map.filter(fn {{x, y}, _} -> x !== qx and y !== qy end)

    {left, right} = Enum.split_with(freq, fn {{x, _y}, _} -> x < qx end)
    {tl, bl} = Enum.split_with(left, fn {{_x, y}, _} -> y < qy end)
    {tr, br} = Enum.split_with(right, fn {{_x, y}, _} -> y < qy end)

    [tl, tr, bl, br]
    |> Enum.map(fn quadrant -> Enum.reduce(quadrant, 0, fn {_, count}, sum -> sum + count end) end)
    |> Enum.product()
  end

  defp part_one(robots) do
    0..99//1
    |> Enum.reduce(robots, fn _, robots -> Enum.map(robots, fn robot -> step(robot) end) end)
    |> compute_safety()
    |> IO.inspect()
  end

  # defp part_two(data), do: :noop

  def run(_) do
    data = Timer.measure(fn -> parse_input() end, "Input")
    p1_result = Timer.measure(fn -> part_one(data) end, "Part 1")
    # p2_result = Timer.measure(fn -> part_two(data) end, "Part 2")
    # IO.puts("| Part one: #{p1_result} |")
    # IO.puts("| Part two: #{p2_result} |")
  end
end
